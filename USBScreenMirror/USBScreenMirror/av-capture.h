//
//  av-capture.h
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2021/7/28.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AVCaptureCustomDeviceDelegate <NSObject>
- (void)captureAudioOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)captureVideoOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
@interface av_capture : NSObject
@property (nonatomic, weak)id<AVCaptureCustomDeviceDelegate>delegate;

- (void)setUpDevice:(NSString *)deviceId;
- (void)start;
- (void)stop;
- (void)getDeviceList:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
