//
//  AudioRenderMacImpl.h
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2022/2/13.
//

#import <Foundation/Foundation.h>
#import "AudioRenderFactory.h"
NS_ASSUME_NONNULL_BEGIN

@interface AudioRenderMacImpl : NSObject<AudioRenderFactory>

- (void)start;
- (void)stop;
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
