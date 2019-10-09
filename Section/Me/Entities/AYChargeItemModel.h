//
//  AYChargeItemModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYChargeItemModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *chargeMoney; //充值金额
@property(nonatomic,strong) NSNumber<RLMInt> *chargeCoin; //充值获得的金币
@property(nonatomic,strong) NSNumber<RLMInt> *chargeGiveCoin; //充值金额赠送的金币
@property(nonatomic,strong) NSString *purProduceId; //内购产品id
@property(nonatomic,strong) NSNumber<RLMBool> *isfirst; //是否第一次冲
@property(nonatomic,strong) NSNumber<RLMBool> *invite; //是否有超级实惠
@property(nonatomic,strong) NSString *intro; //买一送一活动标记

@end

NS_ASSUME_NONNULL_END
