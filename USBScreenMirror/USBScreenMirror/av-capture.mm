//
//  av-capture.m
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2021/7/28.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMediaIO/CMIOHardware.h>
#import "av-capture.h"
#import "IDevInfo.h"



@interface av_capture()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureDeviceInput *deviceInput;
    AVCaptureDevice *device;
    AVCaptureVideoDataOutput *videoOutput;
    AVCaptureAudioDataOutput *audioOutput;
    AVCaptureSession *session;
    
    FourCharCode fourcc;
    
    
}
@end
@implementation av_capture
- (instancetype)init
{
    if(self = [super init])
    {
        [self configDevice];
    }
    return self;
}
- (void)configDevice
{
#ifdef __MAC_10_10
    // Enable iOS device to show up as AVCapture devices
    // From WWDC video 2014 #508 at 5:34
    // https://developer.apple.com/videos/wwdc/2014/#508
    CMIOObjectPropertyAddress prop = {
        kCMIOHardwarePropertyAllowScreenCaptureDevices,
        kCMIOObjectPropertyScopeGlobal,
        kCMIOObjectPropertyElementMaster};
    UInt32 allow = 1;
    CMIOObjectSetPropertyData(kCMIOObjectSystemObject, &prop, 0, NULL,
                  sizeof(allow), &allow);
#endif
    session = [[AVCaptureSession alloc] init];
    
}
- (void)setUpDevice:(NSString *)deviceId
{
    
    device = [AVCaptureDevice deviceWithUniqueID:deviceId];
    if(device == NULL)
        return;
    NSString *localizeName = [device localizedName];
    NSString *uniqueId = [device uniqueID];
    NSString *modelId = [device  modelID];
    NSString *manufacturer = [device manufacturer];
    NSLog(@"setUpDevice name: %@,id %@,%@,%@",localizeName,uniqueId,modelId,manufacturer);
    [session beginConfiguration];
    NSError *error;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (deviceInput == nil) {
        return;
    }
    [session addInput:deviceInput];
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setAlwaysDiscardsLateVideoFrames:true];
    [videoOutput setVideoSettings:@{
        (__bridge NSString *)
        kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)}];
    [videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("Video Capture Queue", 0)];
    [session addOutput:videoOutput];
    audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_queue_create("Audio Capture Queue", 0)];
    if([session canAddOutput:audioOutput]){
        [session addOutput:audioOutput];
    }
    [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    [session commitConfiguration];
    
}

//Audio - Video Output
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if([output isEqual:audioOutput])
    {
        NSLog(@"Audio Output");
        if (self.delegate && [self.delegate respondsToSelector:@selector(captureAudioOutput:didOutputSampleBuffer:)]) {
            [self.delegate captureAudioOutput:output didOutputSampleBuffer:sampleBuffer];
        }
        
    }else
    {
//        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if(self.delegate && [self.delegate respondsToSelector:@selector(captureVideoOutput:didOutputSampleBuffer:)])
        {

            [self.delegate captureVideoOutput:output didOutputSampleBuffer:sampleBuffer];
       

        }
    }
}

- (void)getDeviceList:(NSMutableArray *)array
{
    NSArray *devicesArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed];
    if(devicesArray.count !=0 )
    {
        for (AVCaptureDevice *device  in devicesArray) {
           NSLog(@"Muxed name:%@,id %@,%@,%@", [device localizedName], [device uniqueID], [device modelID], [device manufacturer]);
           if([[device modelID] caseInsensitiveCompare:@"iOS Device"] == NSOrderedSame)
           {
               IDevInfo *devInfo = [[IDevInfo alloc] initWithName:[device localizedName] addUDID:[device uniqueID]];
               [array addObject:devInfo];
           }
        }
    }
}


- (void)start
{
    if(session)
    {
        [session startRunning];
    }
    
}
- (void)stop{
    if(session)
    {
        [session stopRunning];
    }
}
@end
