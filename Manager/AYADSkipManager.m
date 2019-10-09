//
//  AYADSkipManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/1/10.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYADSkipManager.h"
#import "AYCartoonModel.h"
#import "AYBannerModel.h"
#import "AYFictionModel.h"
#import "AYCartoonChapterModel.h"
#import "AYLaunchAdModel.h"
#import "AYChargeSelectView.h" //充值界面
#import "AYBookModel.h" //书本model

@implementation AYADSkipManager

+(void)adSkipWithModel:(id)model
{
    AYBannerModel *bannerModle = nil;
    if([model isKindOfClass:AYBannerModel.class])
    {
        bannerModle = model;
    }
    else if([model isKindOfClass:AYLaunchAdModel.class])
    {
        bannerModle = [AYBannerModel bannerModelWithADModel:model];
    }
    else if([model isKindOfClass:AYBookModel.class])
    {
        bannerModle = [AYBannerModel bannerModelWithBookModel:model];
    }
    if (bannerModle)
    {
        if ([bannerModle.bannerType integerValue] == 1)//1网页、2小说、3漫画
        {
            //网页
            NSString *linkUrl  = bannerModle.bannerLinkUrl;
            if (linkUrl && linkUrl.length>2)
            {
                if (![linkUrl containsString:@"http"]) {
                    linkUrl =[NSString stringWithFormat:@"https://%@",linkUrl];
                }
                [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:linkUrl animate:YES];
            }
            else
            {
                AYLog(@"跳转网页地址错误：%@",linkUrl);
                occasionalHint(@"url error");
            }
        }
        else if ([bannerModle.bannerType integerValue] == 2)//1网页、2小说、3漫画
        {
            AYFictionModel *fictionModel = [AYADSkipManager fictionModelWith:bannerModle];
            //小说
            // 1详情页、2阅读页
            if ([bannerModle.bannerDestinationType integerValue] == 1) {
  
                [ZWREventsManager sendViewControllerEvent:kEventAYFictionDetailViewController parameters:fictionModel animate:YES];
            }
            else
            {
                [ZWREventsManager sendViewControllerEvent:kEventAYFuctionReadViewController parameters:fictionModel];
            }
        }

        else if ([bannerModle.bannerType integerValue] == 3)//1网页、2小说、3漫画
        {
            //小说
            // 1详情页、2阅读页
            if ([bannerModle.bannerDestinationType integerValue] == 1) {
                AYCartoonModel *cartoonModel = [AYADSkipManager cartoonModelWith:bannerModle];
                [ZWREventsManager sendViewControllerEvent:kEventAYNewCartoonDetailViewController parameters:cartoonModel animate:YES];
            }
            else
            {
                AYCartoonChapterModel *cartoonModel = [AYADSkipManager cartoonChapterModelWith:bannerModle];
                
                AYCartoonModel *scartoonModel = [AYADSkipManager cartoonModelWith:bannerModle];
                
                NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:cartoonModel,@"chapter",scartoonModel,@"cartoon", nil];
                [ZWREventsManager sendViewControllerEvent:kEventAYCartoonReadPageViewController parameters:para];
            }
        }
        else if ([bannerModle.bannerType integerValue] == 4)//1网页、2小说、3漫画，4充值
        {
            if(![AYUserManager isUserLogin])
            {
                [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                    [self startCharge];
                }];
            }
            else
            {
                [self startCharge];
            }
        }
        else if ([bannerModle.bannerType integerValue] == 5)//5网页充值
        {
            //网页
            NSString *linkUrl  = bannerModle.bannerLinkUrl;
            if (linkUrl && linkUrl.length>2)
            {
                if (![linkUrl containsString:@"http"]) {
                    linkUrl =[NSString stringWithFormat:@"https://%@",linkUrl];
                }
                
                if(![AYUserManager isUserLogin])
                {
                    [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                        [self startChonzhi:linkUrl];
                    }];
                }
                else
                {
                    [self startChonzhi:linkUrl];
                }
             }
            else
            {
                AYLog(@"跳转网页地址错误：%@",linkUrl);
                occasionalHint(@"url error");
            }
        }
    }
}
+(void)startCharge
{
    [[NSUserDefaults standardUserDefaults] setObject:@(AYChargeLocationTypeUsercenter) forKey:kUserDefaultUserChargeBookType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AYChargeSelectContainView  showChargeSelectInView:[UIApplication sharedApplication].keyWindow compete:^{
    }];
}

+(void)startChonzhi:(NSString*)linkUrl
{
    if ([linkUrl containsString:@"?"] && [linkUrl containsString:@"&"]) {
        linkUrl =[NSString stringWithFormat:@"%@&users_id=%@&deviceType=ios",linkUrl,[AYUserManager userId]];
    }
    else
    {
        linkUrl =[NSString stringWithFormat:@"%@?users_id=%@&deviceType=ios",linkUrl,[AYUserManager userId]];
    }
    [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:linkUrl animate:YES];

}
+(AYFictionModel*)fictionModelWith:(AYBannerModel*)bannerModle
{
    AYFictionModel *fictionModel = [AYFictionModel new];
    fictionModel.fictionID = bannerModle.bannerID;
    fictionModel.fictionTitle = bannerModle.bannerTitle;
    fictionModel.fictionIntroduce = bannerModle.bannerDesc;
    fictionModel.fictionImageUrl = bannerModle.bannerImageUrl;
    fictionModel.isfree = bannerModle.isfree;
    return fictionModel;
}
+(AYCartoonModel*)cartoonModelWith:(AYBannerModel*)bannerModle
{
    AYCartoonModel *cartoonModel = [AYCartoonModel new];
    cartoonModel.cartoonID = bannerModle.bannerID;
    cartoonModel.cartoonImageUrl = bannerModle.bannerImageUrl;
    cartoonModel.cartoonTitle = bannerModle.bannerTitle;
    cartoonModel.cartoonIntroduce = bannerModle.bannerDesc;
    cartoonModel.isfree = bannerModle.isfree;
    return cartoonModel;
}

+(AYCartoonChapterModel*)cartoonChapterModelWith:(AYBannerModel*)bannerModle
{
    AYCartoonChapterModel *cartoonModel = [AYCartoonChapterModel new];
    cartoonModel.cartoonId = bannerModle.bannerID;
    cartoonModel.cartoontTitle = bannerModle.bannerTitle;
    return cartoonModel;
}
@end
