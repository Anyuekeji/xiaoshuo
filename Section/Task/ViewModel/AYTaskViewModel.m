//
//  AYTaskViewModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/8.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYTaskViewModel.h"
#import "AYTaskDayItem.h"
#import "AYBannerModel.h" //轮播model

@interface AYTaskViewModel ()
{
    
}
@property (nonatomic, strong) NSMutableArray * taskDayItemArray;//每日任务item
@property (nonatomic, strong) NSMutableArray * taskNewUserItemArray;//新手任务item
@property (nonatomic, strong) NSMutableArray * taskLanterSlideArray;//任务轮播广告
@property (nonatomic, strong) NSArray * imageArray;//每日任务item

@end
@implementation AYTaskViewModel
- (void) setUp {
    [super setUp];
    _taskDayItemArray = [NSMutableArray array];
    _taskNewUserItemArray = [NSMutableArray array];
    _taskLanterSlideArray = [NSMutableArray array];
    [self configureData];
}
-(void)configureData
{
    AYTaskDayItem *item = [AYTaskDayItem new];
    item.itmeImage = @"task_answer";
    item.itmeTitle = AYLocalizedString(@"问卷答题");
    item.itmeIntroduce = AYLocalizedString(@"奖励50金币");
    item.itemAction =AYLocalizedString(@"答题");
    item.itemFinishImage = @"task_answered";
    item.itemFinish = NO;
    [_taskNewUserItemArray safe_addObject:item];
    NSArray *imageArray = @[@"task_invite",@"task_charge_friend",@"task_adverse",@"task_share",@"task_read"];
    NSArray *finishImageArray = @[@"task_invited",@"task_charge_friended",@"task_advertised",@"task_shared_big",@"task_readed"];
    NSArray *titleArray = @[AYLocalizedString(@"邀请好友"),AYLocalizedString(@"替好友充值"),AYLocalizedString(@"看广告领金币"),AYLocalizedString(@"每日分享"),AYLocalizedString(@"每日阅读")];
    self.imageArray = imageArray;
    NSArray *actionArray = @[AYLocalizedString(@"邀请"),AYLocalizedString(@"去充值"),AYLocalizedString(@"观看"),AYLocalizedString(@"去分享"),AYLocalizedString(@"去阅读")];
    NSArray *itemFinishArray = @[@(NO),@(NO),@([AYGlobleConfig shared].advertiseTaskFinished),@([AYGlobleConfig shared].shareTaskFinished),@([AYGlobleConfig shared].readTaskFinished)];
    NSArray *introduceArray = @[AYLocalizedString(@"每邀请一个好友奖励%@"),AYLocalizedString(@"返20%金币"),AYLocalizedString(@"每看一次奖励10"),AYLocalizedString(@"首次分享奖励20"),AYLocalizedString(@"阅读20分钟奖励20")];
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AYTaskDayItem *item = [AYTaskDayItem new];
        item.itmeImage = obj;
        item.itmeTitle = titleArray[idx];
        item.itmeIntroduce = introduceArray[idx];
        item.itemAction = actionArray[idx];
        item.itemFinishImage = finishImageArray[idx];
        item.itemFinish = [itemFinishArray[idx] boolValue];
        [self.taskDayItemArray safe_addObject:item];
    }];
}

- (void) getTaskBannerDataByAction : (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [ZWNetwork post:@"HTTP_Post_Task_Banner" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             [self.taskLanterSlideArray removeAllObjects];
             NSArray *itemArray = [AYBannerModel itemsWithArray:record];
             [self.taskLanterSlideArray safe_addObjectsFromArray:itemArray];
             if (completeBlock) {
                 completeBlock();
             }
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}
#pragma mark - Table Used
- (NSInteger)numberOfSections
{
    return 2;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([AYGlobleConfig shared].questionTaskFinished) {
            return 0;
        }
        return 2;
    }
    else
    {
        return 5;
    }

}

- (id) objectForIndexPath : (NSIndexPath *) indexPath
{
    if (indexPath.section ==0)
    {
        id object = [self.taskNewUserItemArray safe_objectAtIndex:indexPath.row];
        if ( [object isKindOfClass:AYTaskDayItem.class] )
        {
            if ([AYGlobleConfig shared].questionTaskFinished) {
                return nil;
            }
            return object;
        }
        
    }
    else
    {
        id object = [self.taskDayItemArray safe_objectAtIndex:indexPath.row];
        if ( [object isKindOfClass:AYTaskDayItem.class] )
        {
            return object;
        }
    }
    return nil;
}
- (NSString*) getIndexPathTitle:(NSIndexPath*)indexPath
{
    if (self.imageArray.count>indexPath.row)
    {
        return [self.imageArray objectAtIndex:indexPath.row];
    }
    return nil;
}
-(void)updateTaskStatus
{
    NSArray *itemFinishArray = @[@(NO),@(NO),@([AYGlobleConfig shared].advertiseTaskFinished),@([AYGlobleConfig shared].shareTaskFinished),@([AYGlobleConfig shared].readTaskFinished)];
    if (![AYUserManager isUserLogin])
    {
        itemFinishArray = @[@(NO),@(NO),@(NO),@(NO),@(NO)];
        [AYGlobleConfig shared].questionTaskFinished = NO;
    }
    [self.taskDayItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AYTaskDayItem *item = (AYTaskDayItem*)obj;
        item.itemFinish = [itemFinishArray[idx] boolValue];
    }];

}
- (NSIndexPath *) indexPathForObject : (id) object
{
    for (int i =0;i<self.taskDayItemArray.count;i++) {
        AYTaskDayItem *item =[self.taskDayItemArray safe_objectAtIndex:i];
        if ([item.itmeImage isEqualToString:object]) {
            return [NSIndexPath indexPathForRow:i inSection:1];
        }
    }
    return nil;
}

#pragma mark - icaouse Used -
/**
 *  轮播图的页数
 */
- (NSUInteger) numberOfPageInRotateScrollView
{
    return [_taskLanterSlideArray count];
}
/**
 *  轮播图某一页的数据
 */
- (id) objectForPage:(NSInteger)pageIndex
{
    return [_taskLanterSlideArray safe_objectAtIndex:pageIndex];
}
@end
