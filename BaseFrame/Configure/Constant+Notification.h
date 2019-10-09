//
//  Constant+Notification.h
//  CallYou
//
//  Created by allen on 2017/8/24.
//  Copyright © 2017年 李雷. All rights reserved.
//

#ifndef Constant_Notification_h
#define Constant_Notification_h
///-----------------------------------------------------------------------------
/// @name t
///-----------------------------------------------------------------------------
/** 用户注销*/
#define kNotificationLoginOut @"NotificationLoginOut"
/*登录成功*/
static NSString * const kNotificationLoginSuccess          = @"K_NOTIFICATION_LoginSuccess_EVENTS";

/*加入书架成功，刷新书架*/
static NSString * const kNotificationAddBookRackSuccess          = @"K_NOTIFICATION_AddBookRack_EVENTS";

/*小说加入书架*/
static NSString * const kNotificationFictionAddToRackEvents          = @"K_NOTIFICATION_FictionAddToRack_EVENTS";

/*漫画加入书架*/
static NSString * const kNotificationCartoonAddToRackEvents          = @"K_NOTIFICATION_CartoonAddToRack_EVENTS";

/*漫画章节需要分享*/
static NSString * const kNotificationCartoonChapterShareEvents          = @"K_NOTIFICATION_CartoonChapterShare_EVENTS";

/*详情需要刷新*/
static NSString * const kNotificationDetailNeedRefreshEvents          = @"K_NOTIFICATION_DetailNeedRefresh_EVENTS";

/*pagecontroller的手势enable*/
static NSString * const kNotificationEnableOrDisablePageGestureEvents          = @"K_NOTIFICATION_EnableOrDisablePageGesture_EVENTS";


#endif /* Constant_Notification_h */


