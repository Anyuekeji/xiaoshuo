//
//  AYLaunchAdModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/25.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYLaunchAdModel : ZWBaseModel
@property(nonatomic,strong) NSString *bannerID; //id
@property(nonatomic,strong) NSString *bannerTitle; //id
@property(nonatomic,strong) NSString *bannerDesc; //id

@property(nonatomic,strong) NSString *bannerImageUrl;//图片
@property(nonatomic,strong) NSNumber *bannerType;//1网页、2小说、3漫画
@property(nonatomic,strong) NSNumber *bannerDestinationType;//1详情页、2阅读页
@property(nonatomic,strong) NSString *bannerLinkUrl;//网页跳转链接
@property(nonatomic,strong) NSNumber *bannerStopTime;//广告停止时间
@property(nonatomic,strong) NSNumber *bannerStatus;//广告是否关闭
@property(nonatomic,strong) NSString *bannerEndtime;//广告不显示的时间,过期时间
@end

NS_ASSUME_NONNULL_END
