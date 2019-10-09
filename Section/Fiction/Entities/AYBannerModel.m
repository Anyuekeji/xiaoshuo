//
//  AYBannerModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBannerModel.h"
#import "AYLaunchAdModel.h"
#import "AYBookModel.h" //书本model

@implementation AYBannerModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"bannerShowType"           : @"scan_seat",
             @"bannerID"           : @"book_id",
             @"bannerImageUrl"           : @"banner_pic",
             @"bannerType"           : @"goal_type",
             @"bannerDestinationType"           : @"goal_window",
            @"bannerLinkUrl"           : @"banner_url",
             @"bannerTitle"           : @"book_name",
             @"bannerDesc"           : @"desc",

             
             };
}

+ (NSString *) primaryKey {
    return @"bannerID";
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),self.bannerID];
}

+(AYBannerModel*)bannerModelWithADModel:(AYLaunchAdModel*)adModel
{
    AYBannerModel *bannerModel = [AYBannerModel new];
    bannerModel.bannerID = adModel.bannerID;
    bannerModel.bannerType = adModel.bannerType;
    bannerModel.bannerImageUrl = adModel.bannerImageUrl;
    bannerModel.bannerDestinationType = adModel.bannerDestinationType;
    bannerModel.bannerLinkUrl = adModel.bannerLinkUrl;
    bannerModel.bannerDesc = adModel.bannerDesc;
    bannerModel.bannerTitle = adModel.bannerTitle;

    return bannerModel;
    
}
+(AYBannerModel*)bannerModelWithBookModel:(AYBookModel*)bookModel
{
    AYBannerModel *bannerModel = [AYBannerModel new];
    bannerModel.bannerID = bookModel.bookID;
    bannerModel.bannerType =@([bookModel.type integerValue]+1);
    bannerModel.bannerImageUrl = bookModel.bookImageUrl;
    bannerModel.bannerDestinationType =bookModel.bookDestinationType;
    bannerModel.bannerDesc = bookModel.bookIntroduce;
    bannerModel.bannerTitle = bookModel.bookTitle;
    bannerModel.isfree = bookModel.isfree;
    return bannerModel;
    
}
@end
