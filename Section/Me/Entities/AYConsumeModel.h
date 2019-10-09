//
//  AYConsumeModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/17.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYConsumeModel : ZWBaseModel
@property (nonatomic,strong)NSString *consumeTime;//消费时间
@property (nonatomic,strong)NSString *consumeCoinNum;//金币数
@property (nonatomic,strong)NSString *consumeProjectType;//消费项目
@property (nonatomic,strong)NSString *consumeSection; //消费在哪个章节
@property (nonatomic,strong)NSNumber *expend_type;//1解锁 2 打赏

@property (nonatomic,strong)NSString *consumeId;
@property (nonatomic,assign)NSNumber *local_time;//时间戳

@end

NS_ASSUME_NONNULL_END
