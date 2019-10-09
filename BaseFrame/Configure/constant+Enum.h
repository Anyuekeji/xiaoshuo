//
//  constant+Enum.h
//  CallYou
//
//  Created by allen on 2017/8/17.
//  Copyright © 2017年 李雷. All rights reserved.
//

#ifndef constant_Enum_h
#define constant_Enum_h

/**
 - WSFriend: 好友
 - WSFriendDynamic: 动态
  */
typedef NS_ENUM(NSInteger, AYResultType) {
    AYCurrent          =   1,
    AYPre   =   2,
    AYNext  =   3,

};

/**
 - AYCommentTypeFiction: 获取小说评论
 - AYCommentTypeCartoon:获取漫画评论
 - AYCommentTypeSelf:获取自己发表评论
 */
typedef NS_ENUM(NSInteger, AYCommentType) {
    AYCommentTypeFiction         =   1,
    AYCommentTypeCartoon   =   2,
   AYCommentTypeSelf   =   3,

};
typedef NS_ENUM(NSInteger,AYSharePlatformType) {
    AYSharePlatformTypeFacebook          =   1, //facebook
   // AYSharePlatformTypeZalo   =   2,
    AYSharePlatformTypeLine   =   2,
    AYSharePlatformTypeTwitter  =   6,
    AYSharePlatformTypeGoogle  =   5,
    AYSharePlatformTypeGmail  =   4,
    AYSharePlatformTypeCopyLink  =   3,

};
//充值入口类型
typedef NS_ENUM(NSInteger,AYChargeLocationType) {
    AYChargeLocationTypeUsercenter          =   1, //用户中心充值入口
    AYChargeLocationTypeFictionChapter   =   2,//小说章节
    AYChargeLocationTypeCartoonChapter  =   3, //漫画章节
    AYChargeLocationTypeFictionReward  =   4,//小说打赏
    AYChargeLocationTypeCartoonReward  =   5,//漫画打赏
    
};

typedef NS_ENUM(NSInteger, AYFictionViewType) {
    AYFictionViewTypeHome          =   10, //首页
    AYFictionViewTypeRcommmend   =   0, //推荐
    AYFictionViewTypeFree   =   1, //免费
    AYFictionViewTypeChuangxiao   =   3, //畅销
    AYFictionViewTypeLove   =   2, //最爱
    AYFictionViewTypeTimeFree   =   4, //限时免费
    AYFictionViewTypeCartoon   =   5, //漫话

};

typedef NS_ENUM(NSInteger, AYAdmobAction) {
    AYAdmobActionDoNotLookAdvertise         =   0, //不想看广告
    AYAdmobActionVideoAdvertiseLoadFinished         =   2, //视频广告加载完成
    AYAdmobActionVideoAdvertiseLoadStart         =   1, //视频广告加载开始


};

/**
 - WSFriendStateNoAction:未处理
 - WSFriendStateAggreed 已经同意
 - WSFriendStateRefused: 已经拒绝
 */
typedef NS_ENUM(NSInteger, WSNewFriendState) {
    WSFriendStateSendApply          =   0,
    WSFriendStateAggreed    =   1,
    WSFriendStateRefused      =   2,
};
/** 新闻列表样式 */
typedef NS_ENUM(NSInteger, WSNewsPatternType){
    /** 纯文字样式 */
    kNewsPatternTypeText = 1,
    
    /** 单图样式 */
    kNewsPatternTypeSingleImage = 2,
    
    /** 多图样式 */
    kNewsPatternTypeMultiImage = 3,
    
    /** 信息流广告 */
    kNewsPatternTypeInfoAD = 4,
    
    /** 单张大图模式 */
    kNewsPatternTypeBigImage= 5,
};

/** 新闻展示类型 */
typedef NS_ENUM(NSInteger, WSNewsDisplayType) {
    /** 默认 */
    kNewsDisplayTypeNone = 0,
    /** 文字 */
    kNewsDisplayTypeText = 1,
    /** 图文 */
    kNewsDisplayTypeImageAndText = 2,
    /** 图集 */
    kNewsDisplayTypeImageSet = 3,
    /** 视频 */
    kNewsDisplayTypeVideo = 4,
    /** 原创 */
    kNewsDisplayTypeOriginal = 5,
    /** 专题 */
    kNewsDisplayTypeSpecialReport = 6,
    /** 活动 */
    kNewsDisplayTypeActivity = 8,
    /** 独家新闻 */
    kNewsDisplayTypeExclusive = 9,
    /** 直播新闻 */
    kNewsDisplayTypeLive = 10,
};

typedef NS_ENUM(NSInteger, AYFictionReadTurnPageType) {
    AYTurnPageCurl          =   1, //仿真
    AYTurnPageHorizontal   =   2, //平移
    AYTurnPageUpdown   =   3, //上下
    
};

typedef NS_ENUM(NSInteger, AYCountry) {
    AYCountryIndonesia        =   0,//印尼
    AYCountryVietnam        =   1,//越南
    AYCountryTailand        =   2,//泰国
    AYCountryJapan        =   3, //日本
    
};
#endif /* constant_Enum_h */


