//
//  AYChargeItemModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYChargeItemModel.h"

@implementation AYChargeItemModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"chargeMoney"           : @"yuenan_icon",
             @"chargeCoin"           : @"dummy_icon",
             @"chargeGiveCoin"           : @"first_send",
             @"purProduceId"           : @"applepayId",
             };
}
@end
