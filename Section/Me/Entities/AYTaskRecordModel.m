//
//  AYTaskRecordModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/27.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYTaskRecordModel.h"

@implementation AYTaskRecordModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"taskTime"           : @"task_time",
             @"taskCoinNum"           : @"treward_coin",
             @"task_type_name"           : @"task_type",
             @"userId"           : @"users_id",
             };
}
@end
