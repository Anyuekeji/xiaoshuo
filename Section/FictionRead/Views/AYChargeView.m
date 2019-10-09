//
//  AYChargeView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYChargeView.h"
#import "CYFictionChapterModel.h"
#import "AYChargeSelectView.h" //充值界面
#import "AYCartoonChapterModel.h"
#import "AYFictionCatlogManager.h" //目录管理
#import "AYCartoonCatlogMananger.h" //漫画目录管理

#define AY_CHARGEVIEW_TAG 64865

@interface AYChargeView()
@property(nonatomic,assign) BOOL fiction;  //来自小说解锁章节
@property(nonatomic,strong) CYFictionChapterModel *chapterModel;  //model
@end

static UIView *stati_shaodowView = nil;
static UIView *stati_chargeView = nil;

@implementation AYChargeView
+(void)showChargeViewInView:(UIView*)parentView  fiction:(BOOL)isFiction chapterModel:(CYFictionChapterModel*) chapterModeliew chargeReslut:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut
{
    
  //  parentView = [AYUtitle getAppDelegate].window;
    UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
    [shaodowView setBackgroundColor:[UIColor blackColor]];
    shaodowView.alpha=0;
    shaodowView.tag  = CHARGE_MASK_TAG;
    [parentView addSubview:shaodowView];
    shaodowView.userInteractionEnabled =NO;
    stati_shaodowView = shaodowView;

    AYChargeView* shareView = [[AYChargeView alloc] initWithFrame:CGRectMake(0, parentView.height, ScreenWidth, 206)  fiction:isFiction  chapterModel:chapterModeliew chargeReslut:chargeReslut];

    UIView *containView = shareView;
    if ([chapterModeliew.needMoney integerValue]==4)//广告解锁
    {
        UIView *advertiseChargeView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, shareView.height)];
        [advertiseChargeView setBackgroundColor:[UIColor whiteColor]];
        UILabel *tipLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:15] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentCenter numberOfLines:0];
        tipLable.text =  [NSString stringWithFormat:AYLocalizedString(@"每天可免费阅读%d个章节 继续阅读需要解锁"),[AYGlobleConfig shared].fictionMaxReadSectionNum];
        CGFloat tipHeight = LETextHeight(tipLable.text, tipLable.font, ScreenWidth-100);
        tipLable.frame = CGRectMake(50, 20, ScreenWidth-100, tipHeight);
        advertiseChargeView.height += 40+tipHeight;
        [advertiseChargeView addSubview:tipLable];
        shareView.top = tipLable.top+tipLable.height;
        [advertiseChargeView addSubview:shareView];
        shareView.tag =AD_CHARGE_TAG;
        containView = advertiseChargeView;
    }
    else
    {
        shareView.tag =63453;
    }
    [parentView addSubview:containView];
    containView.tag = AY_CHARGEVIEW_TAG;
    stati_chargeView = containView;

    [UIView animateWithDuration:0.01f animations:^{
        shaodowView.alpha = 0.5f;
        containView.top = parentView.height-containView.height-(_ZWIsIPhoneXSeries()?([AYUtitle al_safeAreaInset:parentView].bottom+40):0);
    }];
}
+(void)removeChargeView
{
    
    if (stati_shaodowView && stati_chargeView)
    {
        [UIView animateWithDuration:0.3f animations:^{
            stati_shaodowView.alpha = 0;
            stati_chargeView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [stati_shaodowView removeFromSuperview];
                [stati_chargeView removeFromSuperview];
                stati_chargeView = nil;
                stati_shaodowView= nil;
            }
        }];
    }

}
-(instancetype)initWithFrame:(CGRect)frame  fiction:(BOOL)isFiction chapterModel:(CYFictionChapterModel*) chapterModel chargeReslut:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut
{
    self = [super initWithFrame:frame];
    if (self) {
        _fiction = isFiction;
        _chapterModel = chapterModel;
        [self configureUI:chargeReslut];

    }
    return self;
}

-(void)configureUI:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut
{
    
    CGFloat myCoinNum =[AYUserManager userItem].coinNum?[[AYUserManager userItem].coinNum floatValue]:0;
    //获取是否自动解锁
    NSNumber *autoUnlock = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultAutoUnlockChapter];
    //自动解锁，且必须先登录
    if([autoUnlock boolValue] && (myCoinNum>=[self.chapterModel.coinNum floatValue]) && [AYUserManager isUserLogin] && [self.chapterModel.needMoney integerValue]!=4)
    {
        AYLog(@"自动解锁");
        [self startUnlockChapter:^(CYFictionChapterModel *chapterModel, AYChargeView *chargeView, BOOL suceess) {
            if (suceess)
            {
                NSString *resultStr = [NSString stringWithFormat:@"%@:%@",self.chapterModel.fictionSectionTitle,AYLocalizedString(@"已自动解锁")];
                occasionalHint(resultStr);
                if (chargeReslut) {
                    chargeReslut(chapterModel,chargeView,suceess);
                }
            }
            else
            {
                AYLog(@"自动解锁失败，弹出解锁视图");
                [self showUi:chargeReslut];
            }
        }];
    }
    else
    {
        AYLog(@"不是自动解锁，弹出解锁视图");
        [self showUi:chargeReslut];
    }
}
-(void)showUi:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut
{
    self.backgroundColor = [UIColor whiteColor];
    UILabel *lockLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    lockLable.text = AYLocalizedString(@"本章解锁：");
    [lockLable sizeToFit];
    [self addSubview:lockLable];
    
    //去掉后面的多位小数
    CGFloat coinNumFloat =[self.chapterModel.coinNum floatValue];
    NSString *chapetCoinNum =[NSString stringWithFormat:@" %.1f",coinNumFloat];
    
    CGFloat coinWidth=  LETextWidth(chapetCoinNum, [UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE]);
    
    
    CGFloat originx = (ScreenWidth-lockLable.width- coinWidth-20)/2.0f;

    UIButton* coinBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:UIColorFromRGB(0x333333) title:chapetCoinNum image:LEImage(@"wujiaoxin_select")];
    
    lockLable.frame = CGRectMake(originx, 35, lockLable.width, 16);
    
    coinBtn.frame = CGRectMake(lockLable.left+lockLable.width+2, 36, coinWidth+20, 16);
    [self addSubview:coinBtn];
    if(![AYUserManager isUserLogin])
    {
        LEWeakSelf(self)
        UIButton *unlockBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:UIColorFromRGB(0xffffff) title: AYLocalizedString(@"立即解锁") image:nil];
        unlockBtn.frame = CGRectMake(30, (self.height-36)/2.0f, ScreenWidth-60, 36);
        [unlockBtn setBackgroundColor:RGB(250, 85, 108)];
        unlockBtn.layer.cornerRadius =18.0f;
        [self addAdvertiseTipView:unlockBtn];
        [self addSubview:unlockBtn];
        [unlockBtn addAction:^(UIButton *btn)
         {
             LEStrongSelf(self)
             [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                 [btn removeFromSuperview];
                 if (self.fiction) {
                     //登录刷新目录
                     [[AYFictionCatlogManager shared] fetchFictionCatlogWithFictionId:self.chapterModel.fictionID refresh:YES success:nil failure:nil];
                 }
                 else
                 {
                     [[AYCartoonCatlogMananger shared] fetchCartoonCatlogWithCartoonId:self.chapterModel.fictionID refresh:YES success:^(NSArray<AYCartoonChapterModel *> * _Nonnull cartoonCatlogArray, int count_all, NSString *update_day) {
                         
                     } failure:^(NSString * _Nonnull errorString) {
                         
                     }];
                 }
                 [self changeUI:chargeReslut chargeAuto:YES];
             }];
         }];
    }
    else
    {
        [self changeUI:chargeReslut chargeAuto:NO];
    }
}
-(void)changeUI:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut  chargeAuto:(BOOL)chargeAuto
{
    
    LEWeakSelf(self)
    UILabel *moneyLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(53, 53, 53) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    moneyLable.frame = CGRectMake(20, 65, ScreenWidth-40, 15);
    moneyLable.text = AYLocalizedString(@"账号余额：");
    [moneyLable sizeToFit];
    [self addSubview:moneyLable];
    
    CGFloat myCoinNum =[AYUserManager userItem].coinNum?[[AYUserManager userItem].coinNum floatValue]:0;

   CGFloat coinWidth=  LETextWidth([[AYUserManager userItem].coinNum stringValue], [UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE]);
    
   CGFloat originx = (ScreenWidth-moneyLable.width- coinWidth-20)/2.0f;
    
   UIButton *coinBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:UIColorFromRGB(0x333333) title:[NSString stringWithFormat:@" %@",[[AYUserManager userItem].coinNum stringValue]] image:LEImage(@"wujiaoxin_select")];
    moneyLable.frame = CGRectMake(originx, 65, moneyLable.width, 16);
    coinBtn.frame = CGRectMake(moneyLable.left+moneyLable.width+2, 66, coinWidth+20, 16);
    [self addSubview:coinBtn];
    if (myCoinNum<[self.chapterModel.coinNum floatValue])//金币不足需要充值
    {
        moneyLable.textColor = RGB(153, 153, 153);
        [coinBtn setImage:LEImage(@"wujiaoxin") forState:UIControlStateNormal];
        UILabel *balanceLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_BIG_FONTSIZE] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentCenter numberOfLines:1];
        balanceLable.frame = CGRectMake(20, moneyLable.top+moneyLable.height+25, ScreenWidth-40, 15);
        balanceLable.text = AYLocalizedString(@"金币不足，需要充值");
        [self addSubview:balanceLable];
        
        UIButton *chargeBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:UIColorFromRGB(0xffffff) title:AYLocalizedString(@"立即充值") image:nil];
        chargeBtn.frame = CGRectMake(30, balanceLable.top+balanceLable.height+20, ScreenWidth-60, 36);
        [chargeBtn setBackgroundColor:RGB(250, 85, 108)];
        chargeBtn.layer.cornerRadius =18.0f;
        [self addSubview:chargeBtn];
        if (chargeAuto) {
            [self startCharge:chargeReslut];
        }
        [chargeBtn addAction:^(UIButton *btn) {
            LEStrongSelf(self)
            [self startCharge:chargeReslut];
        }];
        [self addAdvertiseTipView:chargeBtn];

    }
    else
    {
        UIButton *unlockBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:UIColorFromRGB(0xffffff) title:AYLocalizedString(@"立即解锁") image:nil];
        unlockBtn.frame = CGRectMake(30, moneyLable.top+moneyLable.height+30, ScreenWidth-60, 36);
        [unlockBtn setBackgroundColor:RGB(250, 85, 108)];
        unlockBtn.layer.cornerRadius =18.0f;
        [self addSubview:unlockBtn];
        [unlockBtn addAction:^(UIButton *btn)
         {
             LEStrongSelf(self)
             [self startUnlockChapter:chargeReslut];
            
         }];
        if (chargeAuto) {
            [self startUnlockChapter:chargeReslut];
        }
        [self addAdvertiseTipView:unlockBtn];

        if ([self.chapterModel.needMoney integerValue]!=4)
        {
            UIButton *autoUnlockBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:13] textColor:RGB(177, 177, 177) title:[NSString stringWithFormat:@" %@",AYLocalizedString(@"自动解锁下一章")] image:LEImage(@"read_autounlock_select")];
            [autoUnlockBtn setImage:LEImage(@"read_autounlock") forState:UIControlStateSelected];
            [autoUnlockBtn setFrame:CGRectMake(20, unlockBtn.top+unlockBtn.height+17, ScreenWidth-40, 15)];
            [self addSubview:autoUnlockBtn];
            NSNumber *autoUnlock = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultAutoUnlockChapter];
            if(autoUnlock)
            {
                autoUnlockBtn.selected = ![autoUnlock boolValue];
            }
            [autoUnlockBtn addAction:^(UIButton *btn){
                btn.selected = !btn.selected;
                [[NSUserDefaults standardUserDefaults] setObject:@(!btn.selected) forKey:kUserDefaultAutoUnlockChapter];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
        }

    }
}
-(void)addAdvertiseTipView:(UIButton*)btn
{
    if ([self.chapterModel.needMoney integerValue]==4)//广告解锁
    {
        UILabel *tipLalbe  = [UILabel lableWithTextFont:[UIFont systemFontOfSize:14] textColor:UIColorFromRGB(0xff6666) textAlignment:NSTextAlignmentCenter numberOfLines:1];
        tipLalbe.text = AYLocalizedString(@"您也可以明天再来免费看哦！");
        CGFloat tipHeight = LETextHeight(tipLalbe.text, tipLalbe.font, tipLalbe.width);
        //tipLalbe.frame = CGRectMake(20, self.height-tipHeight-(_ZWIsIPhoneXSeries()?([AYUtitle al_safeAreaInset:self.superview].bottom+40):10), ScreenWidth- 40, tipHeight+6);
        tipLalbe.frame = CGRectMake(20,btn.top+btn.height+(self.height-tipHeight-6-btn.top-btn.height)/2.0f+2.0f, ScreenWidth- 40, tipHeight+6);
        [self addSubview:tipLalbe];
    }
}
#pragma mark - 章节付费 -
-(void)chapterConsum: (void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        if (self.fiction)
        {
            [params addValue:self.chapterModel.fictionID forKey:@"book_id"];
            [params addValue:self.chapterModel.fictionSectionID forKey:@"section_id"];
        }
        else
        {
            [params addValue:self.chapterModel.fictionID forKey:@"cartoon_id"];
            [params addValue:self.chapterModel.fictionSectionID forKey:@"cart_section_id"];
        }
        [params addValue:[self.chapterModel.coinNum stringValue] forKey:@"expend_red"];
    }];
    [ZWNetwork post:@"HTTP_Post_User_Unlock_Chaprer" parameters:para success:^(id record)
     {
         [MBProgressHUD hideHUDForView:self animated:NO];
         if ([record isKindOfClass:NSDictionary.class])
         {
             NSString *myMoney = [record[@"remainder"] stringValue];
             if (myMoney)
             {
                 [AYUserManager userItem].coinNum = myMoney;
                 [AYUserManager save];

             }
         }
         if(completeBlock)
         {
             completeBlock();
         }
     } failure:^(LEServiceError type, NSError *error) {
         [MBProgressHUD hideHUDForView:self animated:NO];
          occasionalHint([error localizedDescription]);
         if(failureBlock)
         {
             failureBlock([error localizedDescription]);
         }
         
     }];
}
//开始充值
-(void)startCharge:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut
{
    [AYUtitle enableReadViewPangestrue:NO];

    [[NSUserDefaults standardUserDefaults] setObject:(self.fiction?@(AYChargeLocationTypeFictionChapter):@(AYChargeLocationTypeCartoonChapter)) forKey:kUserDefaultUserChargeBookType];
    [[NSUserDefaults standardUserDefaults] setObject:self.chapterModel.fictionID forKey:kUserDefaultUserChargeBookId];
    [[NSUserDefaults standardUserDefaults] setObject:self.chapterModel.fictionSectionID forKey:kUserDefaultUserChargeSectionId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LEWeakSelf(self)
    [AYUtitle showChargeView:^{
        LEStrongSelf(self)
        [self startUnlockChapter:chargeReslut];
    }];
}
//开始解锁
-(void)startUnlockChapter:(void(^)(CYFictionChapterModel * chapterModel,AYChargeView *chargeView,BOOL suceess)) chargeReslut
{
    [self chapterConsum:^{
        if (chargeReslut) {
            chargeReslut(self.chapterModel,self,YES);
        }
    } failure:^(NSString *errorString)
     {
         if (chargeReslut) {
             chargeReslut(nil,nil,NO);
         }
     }];
}
@end
