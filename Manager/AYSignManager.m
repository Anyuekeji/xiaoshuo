//
//  AYSignManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYSignManager.h"
#import "AYSignListModel.h"

@implementation AYSignManager
singleton_implementation(AYSignManager)
//预加载签到数据
-(void)loadSignList: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Sign" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             NSArray<AYSignListModel*> *signList = [AYSignListModel itemsWithArray:record[@"res"]];
             int rewardNum = [record[@"str"] intValue];
             [[NSUserDefaults standardUserDefaults] setInteger:rewardNum forKey:kUserDefaultServenDaySignReward];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [AYSignListModel r_deleteAll];
             [AYSignListModel r_saveOrUpdates:signList];
             if(completeBlock)
             {
                 completeBlock();
             }
         }
     } failure:^(LEServiceError type, NSError *error) {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}
//预加载连续签到天数
-(void)loadUserSignNumDay: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    
    if (![AYUserManager isUserLogin]) {
        if(completeBlock)
        {
            completeBlock();
        }
        return;
    }
    [ZWNetwork post:@"HTTP_Post_Sign_Continuous" parameters:nil success:^(id record)
     {
         NSInteger day_num;
         BOOL today_sign;
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             day_num = [record[@"num"] integerValue]; //连续签到天数
             today_sign = [record[@"status"] boolValue]; //今天是否签到
         }
         else
         {
             day_num =0; //连续签到天数
             today_sign = NO; //今天是否签到
         }
         
         [[NSUserDefaults standardUserDefaults] setInteger:day_num forKey:kUserDefaultUserSignDays];
         [[NSUserDefaults standardUserDefaults] setBool:today_sign forKey:kUserDefaultUserTodaySign];
         [[NSUserDefaults standardUserDefaults] synchronize];
         if(completeBlock)
         {
             completeBlock();
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}

-(void)loadAllData: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
//    if (![AYUserManager isUserLogin]) {
//        return;
//    }
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadSignList:^{
        dispatch_group_leave(group);
        } failure:^(NSString * _Nonnull errorString) {
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求2
        [self loadUserSignNumDay:^{
            dispatch_group_leave(group);
        } failure:^(NSString * _Nonnull errorString) {
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completeBlock) {
            completeBlock();
        }
    });

}
@end
