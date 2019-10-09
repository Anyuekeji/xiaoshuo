//
//  AYUserChargeModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/17.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYUserChargeModel.h"

@implementation AYUserChargeModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"chargeTime"           : @"charge_time",
             @"chargeCoinNum"           : @"charge_icon",
             @"chargeGiveCoinNum"           : @"send_coin",
                @"chargeName"           : @"other_name",
             };
}
@end
