//
//  AVSVideoRenderMacImpl.h
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2022/2/13.
//

#import <Cocoa/Cocoa.h>
#import "VideoRenderFactory.h"
NS_ASSUME_NONNULL_BEGIN

@interface AVSVideoRenderMacImpl : NSView <VideoRenderFactory>

+ (instancetype)createVideoRendererWith:(CGRect)frame;

- (void)renderSampleBuffer:(CMSampleBufferRef )sampleBuffer;

- (void)cleanUp;

@end

NS_ASSUME_NONNULL_END
