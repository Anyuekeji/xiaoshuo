//
//  AYLaunchADManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/25.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import "AYLaunchADManager.h"
#import "AYLaunchAdModel.h"
#import "LEFileManager.h"
#import <YYKit/YYKit.h>

static NSString * const kAYLaunchADFileName = @"K_AY_LAUNCHAD_FILENAME";

@implementation AYLaunchADManager
+(void)fetchLaunchAd
{
    //  从网络下载
    [ZWNetwork post:@"HTTP_Post_Launch_ad" parameters:nil success:^(id record)
     {
         if (record && [record isKindOfClass:NSDictionary.class]) {
             AYLaunchAdModel  *launchAdModel= [AYLaunchAdModel itemWithDictionary:record];
             if (launchAdModel )
             {
                 [AYLaunchADManager saveLaunchAd:launchAdModel];
                 [self catcheAdImage:launchAdModel];
             }
         }
     }
    failure:^(LEServiceError type, NSError *error)
     {
         
     }];
}
+(void)saveLaunchAd:(AYLaunchAdModel*)launchAdModel
{
    [launchAdModel saveToDocumentWithFileName:kAYLaunchADFileName];
}
+(AYLaunchAdModel*)launchAdModel
{
    if ( [LEFileManager isFileExistsInDocuments:kAYLaunchADFileName] )
    {
       AYLaunchAdModel * adModle = [AYLaunchAdModel loadFromDocumentWithFileName:kAYLaunchADFileName];
        return adModle;
    }
    return nil;
}
+(void)catcheAdImage:(AYLaunchAdModel*)adModel
{
    YYWebImageManager *manager= [YYWebImageManager sharedManager];
    [manager requestImageWithURL:[NSURL URLWithString:adModel.bannerImageUrl] options:kNilOptions progress:nil transform:nil completion:nil];
}
+(BOOL)hasCatcheImage
{
    AYLaunchAdModel *lauchModel  = [AYLaunchADManager launchAdModel];
    if(lauchModel.bannerImageUrl && lauchModel.bannerImageUrl.length>0)
    {
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
        UIImage *imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:[NSURL URLWithString:lauchModel.bannerImageUrl]] withType:YYImageCacheTypeAll];
        if(imageFromMemory)
        {
            return YES;
        }
    }
    return NO;
}
@end
