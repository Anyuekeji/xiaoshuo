//
//  ZWREventsRegisted.h
//  CallU
//
//  Created by liuyunpeng on 16/6/23.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#ifndef ZWREventsRegisted_h
#define ZWREventsRegisted_h

//这是所有事件注册表，所有对象必须履行ZWREventsProtocol协议才能将类名注册到本文件
//注意所有value必须是匹配的控制器名称

/*跳转到登录界面的事件:无参数*/
static NSString * const kEventAYLogiinViewController               =   @"AYLogiinViewController";
/**小说详情界面事件：无参数*/
static NSString * const kEventAYFictionDetailViewController               =   @"AYFictionDetailViewController";

/**目录界面事件：无参数*/
static NSString * const kEventCYFictionCatalogViewController               =   @"CYFictionCatalogViewController";

/*写评论界面事件：无参数*/
static NSString * const kEventAYWriteCommentViewController               =   @"AYWriteCommentViewController";

/*评论界面事件：无参数*/
static NSString * const kEventAYCommentViewController              =   @"AYCommentViewController";

/*漫画详情界面事件：无参数*/
static NSString * const kEventAYCartoonContainViewController               =   @"AYCartoonContainViewController";

/*卡通阅读：无参数*/
static NSString * const kEventAYCartoonReadPageViewController               =   @"AYCartoonReadPageViewController";

/*意见反馈界面事件：无参数*/
static NSString * const kEventAYAdverseViewController              =   @"AYAdverseViewController";
/*设置界面事件：无参数*/
static NSString * const kEventAYSettingViewController               =   @"AYSettingViewController";

/*记录界面事件：无参数*/
static NSString * const kEventAYRecordSegmentViewController               =   @"AYRecordSegmentViewController";
/*邀请好友界面事件：无参数*/
static NSString * const kEventAYFriendSegmentViewController              =   @"AYFriendSegmentViewController";
/*web界面事件：无参数*/
static NSString * const kEventAYWebViewController               =   @"AYWebViewController";

/*小说阅读界面事件：无参数*/
static NSString * const kEventAYFuctionReadViewController               =   @"AYFuctionReadViewController";
/*APP关于界面*/
static NSString * const kEventAYAboutAppViewController               =   @"AYAboutAppViewController";
/*搜索事件：无参数*/
static NSString * const kEventAYSearchViewController  =   @"AYSearchViewController";

/*小说免费界面事件：无参数*/
static NSString * const kEventAYFictionFreeViewController              =   @"AYFictionFreeViewController";
/*编辑力荐界面事件：无参数*/
static NSString * const kEventAYFictionEidterRecommendViewController              =   @"AYFictionEidterRecommendViewController";
/*书城界面事件：无参数*/
static NSString * const kEventAYBookmailViewController              =   @"AYBookmailViewController";
/*发布个人动态界面事件：无参数*/
static NSString * const kEventAYFriendChargeViewController              =   @"AYFriendChargeViewController";
/*去分享任务界面事件：无参数*/
static NSString * const kEventAYTaskShareViewController              =   @"AYTaskShareViewController";

/*qa事件有参数*/
static NSString * const kEventAYQuestionAndAnswerViewController              =   @"AYQuestionAndAnswerViewController";

/*新的漫画详情页*/
static NSString * const kEventAYNewCartoonDetailViewController              =   @"AYNewCartoonDetailViewController";
/*漫画目录无参数*/
static NSString * const kEventAYCartoonSelectViewController             =   @"AYCartoonSelectViewController";
/*我的关注事件无参数*/
static NSString * const kEventWSMyAttentionViewControlller              =   @"WSMyAttentionViewControlller";
/*设置与帮助事件无参数*/
static NSString * const kEventWSSetAndHelpViewController              =   @"WSSetAndHelpViewController";
/*修改密码事件无参数*/
static NSString * const kEventWSModifyPasswrodVeiwController              =   @"WSModifyPasswrodVeiwController";

/*绑定紧急联系人事件无参数*/
static NSString * const kEventWSAddFriendCheckInfoViewController              =   @"WSAddFriendCheckInfoViewController";
/*新朋友申请界面*/
static NSString * const kEventWSNewFriendVIewController              =   @"WSNewFriendVIewController";

/*会话已过期界面事件无参数*/
static NSString * const kEventALChatFinishViewController              =   @"ALChatFinishViewController";
/*新手引导事件无参数*/
static NSString * const kEventCYNewGuideViewController              =   @"CYNewGuideViewController";

/*选择国家编码事件无参数*/
static NSString * const kEventALCountryCodeViewController              =   @"ALCountryCodeViewController";

//输入手机号事件无参数*/
static NSString * const kEventWSInpuTelephoneViewController              =   @"WSInpuTelephoneViewController";
/*意见反馈事件无参数*/
static NSString * const kEventWSAdviceFeedbackViewController              =   @"WSAdviceFeedbackViewController";

/*打赏事件无参数*/
static NSString * const kEventWSSendLoveViewController              =   @"WSSendLoveViewController";

#endif /* ZWREventsRegisted_h */
