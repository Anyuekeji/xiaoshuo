//
//  AYGlobleConfig.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/20.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYGlobleConfig.h"

@implementation AYGlobleConfig
singleton_implementation(AYGlobleConfig)
-(void)updateTaskStatus: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
{
    if([AYUserManager isUserLogin])
    {
        [ZWNetwork post:@"HTTP_Post_Task_Finish" parameters:nil success:^(id record)
         {
             if (record && [record isKindOfClass:NSDictionary.class])
             {
                 self.advertiseTaskFinished =record[@"advert_count"]?[record[@"advert_count"] boolValue]:NO;
                 self.shareTaskFinished =record[@"share_count"]?[record[@"share_count"] boolValue]:NO;
                 self.readTaskFinished =record[@"read_count"]?[record[@"read_count"] boolValue]:NO;
                 self.questionTaskFinished =record[@"reply_count"]?[record[@"reply_count"] boolValue]:NO;

             }
             if (completeBlock) {
                 completeBlock();
             }
             
         } failure:^(LEServiceError type, NSError *error) {
             if (failureBlock) {
                 failureBlock([error localizedDescription]);
             }
         }];
    }
}
-(NSInteger)fictionMaxReadSectionNum
{
    if (_fictionMaxReadSectionNum<=0)
    {
        return 10;
    }
    return _fictionMaxReadSectionNum;
}
-(NSInteger)fictionAdvertiseFrequency
{
    if (_fictionAdvertiseFrequency<=0)
    {
        return 3;
    }
    return _fictionAdvertiseFrequency;
}

- (void) getServerTime: (void(^)(NSDate *currentDate)) completeBlock
{
    [ZWNetwork post:@"HTTP_Post_System_Time" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
                  NSDate *serverDate =record[@"system_time"]?[NSDate dateWithTimeIntervalSince1970:[record[@"system_time"] longLongValue]]:[NSDate date];
             if (completeBlock) {
                 completeBlock(serverDate);
             }
             
         }
         else
         {
             if (completeBlock) {
                 completeBlock([NSDate date]);
             }
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         if (completeBlock) {
             completeBlock([NSDate date]);
         }
     }];

}
- (void) getAdvertiseInfo: (void(^)(void)) completeBlock
{
        [ZWNetwork post:@"HTTP_Post_advertise_frequency" parameters:nil success:^(id record)
         {
             if (record && [record isKindOfClass:NSDictionary.class])
             {
                 self.fictionAdvertiseFrequency =record[@"rate"]?[record[@"rate"] integerValue]:3;
                 self.fictionMaxReadSectionNum =record[@"start_section"]?[record[@"start_section"] integerValue]:NO;
                 
             }
             if (completeBlock) {
                 completeBlock();
             }
             
         } failure:^(LEServiceError type, NSError *error) {
         
         }];
}
-(void)getInviteRuleData
{
    [ZWNetwork post:@"HTTP_Post_Invate_Rule" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             NSDictionary *loginDic = record[0];
             if (loginDic)
             {
                 
                 NSString* loginRewardNum=loginDic[@"invite_icon"];
                 [[NSUserDefaults standardUserDefaults] setObject:loginRewardNum forKey:kUserDefaultInvitaLoginReward];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
             }
             NSDictionary *chargeDic = record[1];
             if (chargeDic)
             {
                 NSString* chargeRewardNum=chargeDic[@"invite_icon"];
                 [[NSUserDefaults standardUserDefaults] setObject:chargeRewardNum forKey:kUserDefaultInvitaChargeReward];
                 [[NSUserDefaults standardUserDefaults] synchronize];
             }
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         //  occasionalHint([error localizedDescription]);
     }];
}
@end
