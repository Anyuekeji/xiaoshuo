//
//  AYFriendModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/22.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFriendModel.h"

@implementation AYFriendModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"friendName"           : @"nick_name",
             @"coinNum"           : @"icon",
             @"invateTime"           : @"invite_time",
             };
}
@end
