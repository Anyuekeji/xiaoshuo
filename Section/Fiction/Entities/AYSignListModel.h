//
//  AYSignListModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/10.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYSignListModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *sign_day;//签到天数
@property(nonatomic,strong) NSString *sign_icon;//签到奖励
@end

NS_ASSUME_NONNULL_END
