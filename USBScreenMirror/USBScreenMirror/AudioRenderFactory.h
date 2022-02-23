//
//  AudioRenderFactory.h
//  USBScreenMirror
//
//  Created by zxc on 2022/2/22.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@protocol AudioRenderFactory <NSObject>
- (instancetype)init;
- (void)start;
- (void)stop;
- (void)destroy;
- (void)enqueSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
