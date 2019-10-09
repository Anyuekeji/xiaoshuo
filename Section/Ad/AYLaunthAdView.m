//
//  AYLaunthAdView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/23.
//  Copyright © 2018 liuyunpeng. All rights reserved.
//

#import "AYLaunthAdView.h"
#import "NSTimer+YYAdd.h"
#import "AYLaunchAdModel.h"
#import "AYLaunchADManager.h"
#import <YYKit/UIImageView+YYWebImage.h>
#import "AYFictionModel.h"
#import "AYCartoonChapterModel.h"
#import "AYCartoonModel.h"
#import "AYADSkipManager.h" //banner跳转管理

@interface AYLaunthAdView()
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) AYLaunchAdModel *adModel;

@end

@implementation AYLaunthAdView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    return self;
}
- (BOOL)prefersStatusBarHidden
{
   return YES;
}
-(void)configureUI
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.adModel = [AYLaunchADManager launchAdModel];
    CGFloat logoViewHeight =(isIPhone4 || isIPhone5) ?120:160;
    CGFloat logoWidth = 60;
    UIImageView  *adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-logoViewHeight)];
    adImageView.contentMode = UIViewContentModeScaleAspectFill;
    [adImageView setImageWithURL:[NSURL URLWithString:self.adModel.bannerImageUrl] placeholder:LEImage(@"ws_register_example_company")];
    [self addSubview:adImageView];
    LEWeakSelf(self)
    [adImageView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        [self jumpToAdvertse];
    }];
    
    //底部视图
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0, adImageView.height, SCREEN_WIDTH, logoViewHeight)];
    logoView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:logoView];
    //app图标
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (logoViewHeight-logoWidth)/2.0f, logoWidth, logoWidth)];
    iconImageView.image = LEImage(@"app_icon");
    [logoView addSubview:iconImageView];
    
    //app名字
    UILabel *appNameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:22] textColor:RGB(205, 85, 108) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    
 //   NSDictionary *appInfoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName=
    [AYUtitle getAppName];
    appNameLable.text = appName;
    [logoView addSubview:appNameLable];
    
    CGFloat appNameWidth = LETextWidth(appName, appNameLable.font);
    
    CGFloat originx = (ScreenWidth - 60 - 10 - appNameWidth)/2.0f;
    
    iconImageView.left = originx;
    appNameLable.frame =CGRectMake(iconImageView.left+iconImageView.width+10, (logoViewHeight-20)/2.0f, appNameWidth, 20);
    //app倒退时间
    UILabel *timeLabel  = [UILabel lableWithTextFont:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    timeLabel.backgroundColor = UIColorFromRGBA(0x000000, 0.6f);
    timeLabel.text = [NSString stringWithFormat:@"%@s %@",([self.adModel.bannerStopTime integerValue]<=0?@"5":[self.adModel.bannerStopTime stringValue]),AYLocalizedString(@"跳过")];
    CGFloat timeWidth = LETextWidth(timeLabel.text, timeLabel.font)+4;
    timeLabel.frame = CGRectMake(ScreenWidth-15-timeWidth, 15, timeWidth, 16);
    timeLabel.layer.cornerRadius =8.0f;
    timeLabel.clipsToBounds = YES;
    [self addSubview:timeLabel];
    
    //跳过广告
    [timeLabel addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        [self.timer invalidate];
        [self removeFromSuperview];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
    
    __block NSInteger timeSecond = ([self.adModel.bannerStopTime integerValue]<=0?5:[self.adModel.bannerStopTime integerValue]);
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
        LEStrongSelf(self)
        if (timeSecond ==0)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [timer invalidate];
            [UIView animateWithDuration:0.3f animations:^{
                self.alpha =0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [self removeFromSuperview];
                }
            }];
        }
        timeLabel.text = [NSString stringWithFormat:@"%lds %@",(long)timeSecond,AYLocalizedString(@"跳过")];
        timeSecond -= 1;
    } repeats:YES];
}

-(void)jumpToAdvertse
{
    [_timer invalidate];
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [AYADSkipManager adSkipWithModel:self.adModel];
}
@end
