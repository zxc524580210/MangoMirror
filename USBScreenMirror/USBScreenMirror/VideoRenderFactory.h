//
//  VideoRenderFactory.h
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2022/2/13.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
NS_ASSUME_NONNULL_BEGIN

@protocol VideoRenderFactory <NSObject>

+ (instancetype)createVideoRendererWith:(CGRect)frame;

- (void)setUpRenderView:(NSView *)disPlayView;
- (void)renderSampleBuffer:(CMSampleBufferRef )sampleBuffer;

@end
NS_ASSUME_NONNULL_END
