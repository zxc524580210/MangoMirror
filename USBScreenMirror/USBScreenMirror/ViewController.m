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

@interface ViewController()<AVCaptureCustomDeviceDelegate>
@property (nonatomic, strong)av_capture *avc;
@property (nonatomic, strong)NSMutableArray *array;
@property (nonatomic, strong)id<VideoRenderFactory> videoRender;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"大重构演示程序";
    self.avc = [[av_capture alloc] init];
    self.avc.delegate = self;
    self.array = [NSMutableArray array];
    [self initAVSRender];
//    [self initializeDisplayLayer];
//    [self setRenderView:self.view];
    // 注册观察者
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
    [self.view addObserver:self forKeyPath:@"frame" options:options context:nil];


    // Do any additional setup after loading the view.
}
// 回调方法。当监听对象的属性值发生改变时，就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSView *view =  object;
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

 - (void)initAVSRender
{
    self.videoRender = [AVSVideoRenderMacImpl createVideoRendererWith:self.view.frame];
    [self.videoRender setUpRenderView:self.view];
}
- (IBAction)SetUpDevice:(id)sender {
    IDevInfo *info = self.array.firstObject;
    [self.avc setUpDevice:info.uniqueId];
}
- (IBAction)start:(id)sender {
    
    [self.avc start];
}
- (IBAction)stop:(id)sender {
    [self.avc stop];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)getDeviceList:(id)sender {
    [self.avc getDeviceList:self.array];

}

- (void)captureAudioOutput:(nonnull AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer {
    
}

- (void)captureVideoOutput:(nonnull AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer {
    if (self.videoRender) {
      [self.videoRender renderSampleBuffer:sampleBuffer];
    }
    
}

@end
