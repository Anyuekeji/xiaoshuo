//
//  AYLaunchADManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/25.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AYLaunchAdModel;

NS_ASSUME_NONNULL_BEGIN

@interface AYLaunchADManager : NSObject
+(void)fetchLaunchAd;
//获取admodel
+(AYLaunchAdModel*)launchAdModel;
//是否缓存广告图片
+(BOOL)hasCatcheImage;
@end

NS_ASSUME_NONNULL_END
