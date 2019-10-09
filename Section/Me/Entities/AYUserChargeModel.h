//
//  AYUserChargeModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/17.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYUserChargeModel : ZWBaseModel
@property (nonatomic,strong)NSString *chargeTime;//充值时间
@property (nonatomic,strong)NSString *chargeCoinNum;//金币数
@property (nonatomic,strong)NSString *chargeGiveCoinNum;//赠送数
@property (nonatomic,strong)NSString *chargeName;//充值时间
@property (nonatomic,strong)NSString *charge_type;//充值或者系统赠送
@property (nonatomic,strong)NSString *chargeId;
@property (nonatomic,strong)NSString *chargeMoneyNum;
@property (nonatomic,assign)NSNumber *local_time;//时间戳
@end

NS_ASSUME_NONNULL_END
