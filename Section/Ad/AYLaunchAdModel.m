//
//  AYLaunchAdModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/25.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import "AYLaunchAdModel.h"

@implementation AYLaunchAdModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"bannerID"           : @"book_id",
             @"bannerImageUrl"           : @"advert_pic",
             @"bannerType"           : @"goal_type",
             @"bannerDestinationType"           : @"goal_window",
             @"bannerLinkUrl"           : @"advert_url",
             @"bannerTitle"           : @"advert_name",
             @"bannerDesc"           : @"desc",
             @"bannerStopTime"           : @"stop_time",
             @"bannerStatus"           : @"status",
             @"bannerEndtime"           : @"end_time",
             
             };
}

@end
