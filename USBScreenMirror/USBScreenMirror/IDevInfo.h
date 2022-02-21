//
//  IDevInfo.h
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2021/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IDevInfo : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * uniqueId;
- (instancetype)initWithName:(NSString *)name addUDID:(NSString *)uniqueId;
@end

NS_ASSUME_NONNULL_END
