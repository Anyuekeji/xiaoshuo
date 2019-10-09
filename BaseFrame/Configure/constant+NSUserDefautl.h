//
//  constant+NSUserDefautl.h
//  CallYou
//
//  Created by allen on 2017/10/8.
//  Copyright © 2017年 李雷. All rights reserved.
//

#ifndef constant_NSUserDefautl_h
#define constant_NSUserDefautl_h

static NSString * const kUserDefaultIsLogin         = @"K_UserDefault_Login_key";  //h是否登录key
static NSString * const kUserDefaultReadFontSize        = @"K_UserDefault_ReadFontSize_key";  //小说字体key
static NSString * const kUserDefaultReadBackColor        = @"K_UserDefault_ReadBackColor_key";  //小说背景颜色
static NSString * const kUserDefaultNightMode        = @"K_UserDefault_NightMode_key";  //夜晚模式
static NSString * const kUserDefaultReadFontColor        = @"K_UserDefault_ReadFontColor_key";  //小说的字体颜色


static NSString * const kUserDefaultRecommmentBookID        = @"K_UserDefault_RecommmentBookID_key";  //推荐的书籍删除的id
static NSString * const kUserDefaultUserSignDays       = @"K_UserDefault_UserSignDays_key";  //用户连续签到天数
static NSString * const kUserDefaultUserTodaySign       = @"K_UserDefault_UserTodaySign_key";  //用户今天是否签到
static NSString * const kUserDefaultServenDaySignReward      = @"K_UserDefault_ServenDaySignReward _key";  //用户连续七天签到获得奖励
static NSString * const kUserDefaultAutoUnlockChapter      = @"K_UserDefault_AutoUnlockChapter_key";  //自动解锁章节 默认yes
static NSString * const kUserDefaultWriteCommentTime      = @"K_UserDefault_WriteCommentTime _key";  //用户发送评论的时间
static NSString * const kUserDefaultWriteAdversiseTime      = @"K_UserDefault_WriteAdversiseTime _key";  //用户提建议的时间
static NSString * const kUserDefaultVistorModeSwitch      = @"K_UserDefault_VistorModeSwitch_key";  //用户提建议的时间
static NSString * const kUserDefaultInvitaLoginReward      = @"K_UserDefault_InvitaLoginReward_key";  //用户邀请获得奖励
static NSString * const kUserDefaultInvitaChargeReward      = @"K_UserDefault_InvitaChargeReward_key";  //用户充值获得奖励

static NSString * const kUserDefaultUserChargeBookId      = @"K_UserDefault_UserChargeBookId_key";  //用户充值的书id

static NSString * const kUserDefaultUserChargeSectionId      = @"K_UserDefault_ChargeSectionId_key";  //用户充值的书的章节id
static NSString * const kUserDefaultUserChargeBookType      = @"K_UserDefault_ChargeBookType_key";  //1 充值入口（用户中心）  2，小说章节 3，漫画章节 4，小说打赏 5，漫画打赏

static NSString * const kUserDefaultFictionTurnPageType      = @"K_UserDefault_FictionTurnPageType_key";  //1 仿真  2，平移

static NSString * const kUserDefaultUserHasAppCommented      = @"K_UserDefault_UserHasAppCommented_key";  //用户是否在appstroe 评论过

static NSString * const kUserDefaultUserAppCommentedShowTime      = @"K_UserDefault_AppCommentedShowTime_key";  //用户评论视图显示时间

static NSString * const kUserDefaultUniqueDeviceId      = @"K_UserDefault_UniqueDeviceId _key";  //设备的唯一id

static NSString * const kUserDefaultFreeModeNeedLookAd      = @"K_UserDefault_FreeModeNeedLookAd _key";  //免费模式下是否通过广告解锁
static NSString * const kUserDefaultUserReadTotalTimeDay      = @"K_UserDefault_ReadTotalTimeDay _key";  //用户当天阅读总时间
static NSString * const kUserDefaultUserReadCurrentDay      = @"K_UserDefault_ReadCurrentDay_key";  //用户当天阅读总时间当天时间

static NSString * const kUserDefaultFreeBookCoinUnlock      = @"K_UserDefault_FreeBookCoinUnlock_key";  //免费小说是否金币解锁

static NSString * const kUserDefaultFreeBookDayReadTime      = @"K_UserDefault_FreeBookDayReadTime_key";  //存储用户当天读第一章广告解锁章节的时间
static NSString * const kUserDefaultFreeBookIdArray      = @"K_UserDefault_FreeBookIdArray_key";  //存储用户当天读过哪几章广告解锁章节，用于次数去重
static NSString * const kUserDefaultFriendChargeId      = @"K_UserDefault_FriendChargeId_key";  //帮朋友充值的朋友id

static NSString * const kUserDefaultFictionGuideFinished      = @"K_UserDefault_FictionGuideFinished_key";  //小说界面的引导图是否显示过
static NSString * const kUserDefaultTaskGuideFinished      = @"K_UserDefault_TaskGuideFinished_key";  //任务界面的引导图是否显示过
static NSString * const kUserDefaultFictionDetailGuideFinished      = @"K_UserDefault_FictionDetailGuideFinished_key";  //小说详情界面的引导图是否显示过

#endif /* constant_NSUserDefautl_h */
