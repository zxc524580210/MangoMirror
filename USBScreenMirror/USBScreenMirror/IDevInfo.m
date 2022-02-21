//
//  IDevInfo.m
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2021/7/30.
//

#import "IDevInfo.h"

@implementation IDevInfo
- (instancetype)initWithName:(NSString *)name addUDID:(NSString *)uniqueId
{
    if(self = [super init])
    {
        self.name = name;
        self.uniqueId = uniqueId;
    }
    return self;
}
@end
