//
//  AVSVideoRenderMacImpl.m
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2022/2/13.
//
#import <AVFoundation/AVFoundation.h>
#import "AVSVideoRenderMacImpl.h"
@interface AVSVideoRenderMacImpl()
@property (nonatomic, strong) AVSampleBufferDisplayLayer *avsLayer;
@end
@implementation AVSVideoRenderMacImpl
bool timebaseSet = false;

- (instancetype)initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect]) {
      
    self.avsLayer = [[AVSampleBufferDisplayLayer alloc] init];
    self.avsLayer.frame = self.frame;
    self.avsLayer.bounds = self.bounds;
    self.avsLayer.position = CGPointMake(CGRectGetMidX(frameRect), CGRectGetMidY(frameRect));
    self.avsLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.avsLayer.opaque = YES;
    self.avsLayer.backgroundColor = [NSColor blackColor].CGColor;
    [self.layer addSublayer:self.avsLayer];
  }
  return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

+ (instancetype)createVideoRendererWith:(CGRect)frame
{
  return [[AVSVideoRenderMacImpl alloc] initWithFrame:frame];
}
- (void)setUpRenderView:(NSView *)disPlayView
{
    if(self.avsLayer)
    {
        [self.avsLayer flushAndRemoveImage];
    }
    if(disPlayView.layer) // mac 的巨坑 就是这个layer 是个空值 所以需要将view的layer 赋值为新生成的layer
    {
        [disPlayView addSubview:self];
    } else {
        disPlayView.layer = self.avsLayer;
    }
}
- (void)cleanUp
{
    [self.avsLayer flushAndRemoveImage];
}
- (void)renderSampleBuffer:(CMSampleBufferRef )sampleBuffer{

    if([self.avsLayer isReadyForMoreMediaData]) {
        CFRetain(sampleBuffer);
        [self.avsLayer enqueueSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
        switch (self.avsLayer.status) {
          case AVQueuedSampleBufferRenderingStatusFailed:
            NSLog(@"### AVQueuedSampleBufferRenderingStatusFailed Failed ! ####");
            break;
          case AVQueuedSampleBufferRenderingStatusRendering:
            NSLog(@"### AVQueuedSampleBufferRenderingStatusRendering ! ####");
            break;
          default:
            NSLog(@"### AVQueuedSampleBufferRenderingStatusUnknown ! ####");
            break;
        }
    }
}
@end
