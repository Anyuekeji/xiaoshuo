//
//  AYBannerModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"



@class AYLaunchAdModel;
@class AYBookModel;

NS_ASSUME_NONNULL_BEGIN

@interface AYBannerModel : ZWDBBaseModel
@property(nonatomic,strong) NSNumber<RLMInt> *bannerShowType; //banner类型 显示在哪里是在小说banner 还是 漫画banner1：小说首页 2：漫画首页
@property(nonatomic,strong) NSString *bannerID; //id
@property(nonatomic,strong) NSString *bannerTitle; //id
@property(nonatomic,strong) NSString *bannerDesc; //id

@property(nonatomic,strong) NSString *bannerImageUrl;//图片
@property(nonatomic,strong) NSNumber<RLMInt> *bannerType;//1网页、2小说、3漫画
@property(nonatomic,strong) NSNumber<RLMInt> *bannerDestinationType;//1详情页、2阅读页
@property(nonatomic,strong) NSString *bannerLinkUrl;//网页跳转链接
@property(nonatomic,strong) NSNumber<RLMInt> *isfree;

+(AYBannerModel*)bannerModelWithADModel:(AYLaunchAdModel*)adModel;

+(AYBannerModel*)bannerModelWithBookModel:(AYBookModel*)bookModel;
@end

NS_ASSUME_NONNULL_END
