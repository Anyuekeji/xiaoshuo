//
//  AYGlobleConfig.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/20.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYGlobleConfig : NSObject
singleton_interface(AYGlobleConfig)
//更新每日任务的完成状态
-(void)updateTaskStatus: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
//获取服务器时间
- (void) getServerTime: (void(^)(NSDate *currentDate)) completeBlock;
//获取显示广告评论和每天最多能免费阅读多少章
- (void) getAdvertiseInfo: (void(^)(void)) completeBlock;

//获取邀请奖励数据
-(void)getInviteRuleData;
@property(nonatomic,assign) BOOL advertiseTaskFinished; //广告任务是否完成
@property(nonatomic,assign) BOOL shareTaskFinished; //每日分享任务是否完成
@property(nonatomic,assign) BOOL readTaskFinished; //每日阅读任务是否完成
@property(nonatomic,assign) BOOL questionTaskFinished; //问卷答题任务是否完成

@property(nonatomic,assign) NSInteger fictionAdvertiseFrequency; //免费小说插入广告的频率 没几页插入一个广告
@property(nonatomic,assign) NSInteger fictionMaxReadSectionNum; //免费小说每天最多能读几章
@end

NS_ASSUME_NONNULL_END
