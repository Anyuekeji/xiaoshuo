//
//  AYReadStatisticsManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/19.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYReadStatisticsManager.h"
#import "AYRewardView.h"
#import "NSTimer+YYAdd.h"

@interface AYReadStatisticsManager()
@property(nonatomic,strong) NSDate *enterDate; //进入阅读时间
@property(nonatomic,strong) NSTimer *timer; //进入阅读时间
@property(nonatomic,assign) NSNumber *localTotalTime; //进入阅读时间
@end

@implementation AYReadStatisticsManager
singleton_implementation(AYReadStatisticsManager)
//进入阅读页
-(void)enterReadController
{
    if (![AYGlobleConfig shared].readTaskFinished) {
        [self localStatiticsTimeAviable];
        _timer = [NSTimer scheduledTimerWithTimeInterval:60 block:^(NSTimer * _Nonnull timer) {
            [self leaveReadController:NO];
        } repeats:YES];

    }
}
//离开阅读页
-(void)leaveReadController:(BOOL)leave
{
    if ([AYGlobleConfig shared].readTaskFinished)//阅读任务完成不做处理
    {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0
                                             ), ^{
        //以前累计阅读时间
        if (!self.localTotalTime) {
            self.localTotalTime =[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserReadTotalTimeDay];
        }
        [[AYGlobleConfig shared] getServerTime:^(NSDate * _Nonnull currentDate) {
            NSTimeInterval currentReadTime = [currentDate timeIntervalSinceDate:self.enterDate];
            NSInteger totalReadTme = currentReadTime;
            if (self.localTotalTime)
            {
                totalReadTme = currentReadTime+[self.localTotalTime integerValue];
            }
            if(leave)
            {
                self.localTotalTime = nil;
                [self.timer invalidate];
                self.timer = nil;
                [[NSUserDefaults standardUserDefaults] setObject:@(totalReadTme) forKey:kUserDefaultUserReadTotalTimeDay];
      
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (totalReadTme>=20*60)//累计阅读二十分钟 奖励50金币
            {
                [self requestReadReward];
            }
        }];
       
    });
    
}
//判读当前的统计时间是否有效
-(void)localStatiticsTimeAviable
{
    NSDate *localStaticsDate = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserReadCurrentDay];
    if (localStaticsDate)
    {
        [[AYGlobleConfig shared] getServerTime:^(NSDate *currentDate) {
            self.enterDate = currentDate;
            if (![self isSameDay:localStaticsDate date2:currentDate])//不是同一天
            {
                //以前的阅读的时间清零
                [self clearReadRecord];
                [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kUserDefaultUserReadCurrentDay];
            }

        }];
    }
    else
    {
        [[AYGlobleConfig shared] getServerTime:^(NSDate *currentDate) {
            self.enterDate = currentDate;
            //记录一天开始的时间
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kUserDefaultUserReadCurrentDay];
            }];
    }
}
-(void)clearReadRecord
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserReadCurrentDay];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserReadTotalTimeDay];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}
//用户读完一本书的某一章节
-(void)userReadFinishOneChapter:(NSString*)bookId  chapterId:(NSString*)chapterId
{
    //看下刚开始的阅读时间有没有记录
       NSMutableArray *readedChapter =(NSMutableArray*) [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFreeBookIdArray];
        NSString *chapterkey = [NSString stringWithFormat:@"%@_%@",bookId,chapterId];
        if (readedChapter)
        {
            if (![readedChapter containsObject:chapterkey])
            {
                NSMutableArray *chapterArray = [NSMutableArray arrayWithArray:readedChapter];
                [chapterArray safe_addObject:chapterkey];
                [[NSUserDefaults standardUserDefaults] setObject:chapterArray forKey:kUserDefaultFreeBookIdArray];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        else
        {
            readedChapter=  [NSMutableArray new];
            [readedChapter safe_addObject:chapterkey];
            [[NSUserDefaults standardUserDefaults] setObject:readedChapter forKey:kUserDefaultFreeBookIdArray];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
}
//广告解锁小说每天阅读的机会是否用完
-(BOOL)advertiseReadDayCountFinished
{
    NSArray *readArray =   [[NSUserDefaults standardUserDefaults]  objectForKey:kUserDefaultFreeBookIdArray];
    if (readArray)
    {
        if (readArray.count>=[AYGlobleConfig shared].fictionMaxReadSectionNum) {
            return YES;
        }
    }
    return NO;
}

//判读免费阅读的记录时间是否有效
-(void)localBookFreeReadStatiticsTimeAviable:(void(^)(void)) completeBlock
{
    NSDate *localStaticsDate = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFreeBookDayReadTime];
    if (localStaticsDate)
    {
        [[AYGlobleConfig shared] getServerTime:^(NSDate *currentDate) {
            if (![self isSameDay:localStaticsDate date2:currentDate])//不是同一天
            {
                //以前的阅读的时间清零
                [self clearBookFreeReadRecord];
                [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kUserDefaultFreeBookDayReadTime];
            }
            if(completeBlock)
            {
                completeBlock();
            }
        }];

    }
    else
    {
        [[AYGlobleConfig shared] getServerTime:^(NSDate *currentDate) {
                //记录一天开始的时间
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kUserDefaultFreeBookDayReadTime];
            if(completeBlock)
            {
                completeBlock();
            }
            
        }];
    }
}
-(void)clearBookFreeReadRecord
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultFreeBookDayReadTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultFreeBookIdArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - network -
-(void)requestReadReward
{
    [ZWNetwork post:@"HTTP_Post_day_Read" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class])
         {
             if (record[@"remainder"])
             {
                 AYMeModel *meModel = [AYUserManager userItem];
                 meModel.coinNum = [record[@"remainder"] stringValue];
                 [AYUserManager save];
             }
             //occasionalHint(AYLocalizedString(@"阅读20分钟奖励50"));
             dispatch_async(dispatch_get_main_queue(), ^{
                 [AYRewardView showRewardViewWithTitle:AYLocalizedString(@"完成阅读") coinStr:@"20" detail:AYLocalizedString(@"阅读20分钟奖励20") actionStr:AYLocalizedString(@"明日再来")];
                 [AYGlobleConfig shared].readTaskFinished = YES;
             });
             self.localTotalTime = nil;
             [self.timer invalidate];
             self.timer = nil;
             [self clearReadRecord];
             //以前的阅读的时间清零
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserReadCurrentDay];
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultUserReadTotalTimeDay];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
     } failure:^(LEServiceError type, NSError *error) {
     }];
}
-(void)advertiseIntoReadController
{
    [self localBookFreeReadStatiticsTimeAviable:^{
        
    }];
}
@end
