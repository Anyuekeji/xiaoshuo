//
//  AYMeModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/6.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYMeModel.h"

@implementation AYMeModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"myHeadImage"           : @"avater",
             @"myId"           : @"users_id",
             };
}
@end
