//
//  AYTaskRecordModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/27.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYTaskRecordModel : ZWBaseModel

@property (nonatomic,strong)NSString *taskTime;//任务完成时间
@property (nonatomic,strong)NSString *taskCoinNum;//金币数
@property (nonatomic,strong)NSString *task_type_name;//充值或者系统赠送
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,assign)NSNumber *local_time;//时间戳
@end

NS_ASSUME_NONNULL_END
