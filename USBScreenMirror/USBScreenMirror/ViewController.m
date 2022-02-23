//
//  ViewController.m
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2021/7/28.
//

#import "ViewController.h"
#import "av-capture.h"
#import "IDevInfo.h"
#import <objc/objc.h>
#import  <AVFoundation/AVFoundation.h>
#import "VideoRenderFactory.h"
#import "AVSVideoRenderMacImpl.h"
#import "AudioRenderMacImpl.h"

@interface ViewController()<AVCaptureCustomDeviceDelegate>
{
    NSNotificationCenter *center;
}
@property (nonatomic, strong)av_capture *avc;
@property (nonatomic, strong)NSMutableArray *array;
@property (nonatomic, strong)id<VideoRenderFactory> videoRender;
@property (nonatomic, strong)id<AudioRenderFactory> audioRender;


@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMangoMirror];
    //设置设备插拔监听
    __weak typeof(self) weakSelf = self;
    center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf startMirror];
    }];
    [center addObserverForName:AVCaptureDeviceWasDisconnectedNotification    object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf stopMirror];
    }];
}
 - (void)initMangoMirror
{
    self.avc = [[av_capture alloc] init];
    self.avc.delegate = self;
    self.array = [NSMutableArray array];
    [self initAVSRender];
    [self initAudioRender];
}
//API 放在Main Queue 的延迟操作
- (void)dispathAfterTimeInterval:(NSTimeInterval)interval block:(dispatch_block_t)block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block?block():nil;
    });
}
 - (void)initAVSRender
{
    self.videoRender = [AVSVideoRenderMacImpl createVideoRendererWith:self.view.frame];
    [self.videoRender setUpRenderView:self.view];
}
- (void)initAudioRender
{
    self.audioRender = [[AudioRenderMacImpl alloc] init];
}
- (IBAction)SetUpDevice:(id)sender {
  
}
- (IBAction)start:(id)sender {
    //录屏的延迟操作，防止异步操作打开设备失败。
    [self startMirror];
}
- (void)startMirror
{
    [self dispathAfterTimeInterval:0 block:^{
        [self.avc getDeviceList:self.array];
    }];
    [self dispathAfterTimeInterval:1 block:^{
        IDevInfo *info = self.array.firstObject;
        [self.avc setUpDevice:info.uniqueId];
    }];
    [self dispathAfterTimeInterval:2 block:^{
        [self.avc start];
        [self.audioRender start];
    }];
}
- (IBAction)stop:(id)sender {
    [self stopMirror];
}
- (void)stopMirror
{
    [self.avc stop];
    [self.videoRender cleanUp];
    [self.audioRender stop];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)getDeviceList:(id)sender {
    [self.avc getDeviceList:self.array];

}

- (void)captureAudioOutput:(nonnull AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer {
    [self.audioRender enqueSampleBuffer:sampleBuffer];
}

- (void)captureVideoOutput:(nonnull AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer {
    if (self.videoRender) {
      [self.videoRender renderSampleBuffer:sampleBuffer];
    }
    
}

@end
