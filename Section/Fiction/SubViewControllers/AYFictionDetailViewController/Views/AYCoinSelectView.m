//
//  AYCoinSelectView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCoinSelectView.h"
#import "AYFictionDetailModel.h"
#import "AYCartoonDetailModel.h"
#import "AYChargeSelectView.h" //充值
#import "AYCartoonModel.h"

//书架介绍
@interface AYCoinSelectView()
@property(nonatomic,strong) id dataModel;//小说图片

@property (copy, nonatomic) void(^complete)(NSString *rewardNum);

@end

@implementation AYCoinSelectView

+(void)showCoinSelectViewInView:(UIView*)parentView model:(id)model success :(void(^)(NSString *rewardNum)) completeBlock
{
    UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
    [shaodowView setBackgroundColor:[UIColor blackColor]];
    shaodowView.alpha=0;
    [parentView addSubview:shaodowView];
    
    
    AYCoinSelectView* coinSelectView = [[AYCoinSelectView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 4*55) model:model success:^(NSString *rewardNum){
        UIView *coinView = [parentView viewWithTag:5865];
        [UIView animateWithDuration:0.2 animations:^{
            shaodowView.alpha = 0;
            coinView.top = ScreenHeight;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [coinView removeFromSuperview];
            }
        }];
        if (completeBlock) {
            completeBlock(rewardNum);
        }
    }];
    coinSelectView.tag = 5865;
    [parentView addSubview:coinSelectView];
    LEWeakSelf(coinSelectView)
    coinSelectView.coinSelectActionCancle = ^{
        LEStrongSelf(coinSelectView)
        [UIView animateWithDuration:0.2 animations:^{
            shaodowView.alpha = 0;
            coinSelectView.top = ScreenHeight;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [coinSelectView removeFromSuperview];
            }
        }];
    };
    [UIView animateWithDuration:0.2f animations:^{
        shaodowView.alpha = 0.5f;
        coinSelectView.top = parentView.height-coinSelectView.height;
    }];
    
    [shaodowView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        [UIView animateWithDuration:0.2f animations:^{
            ges.view.alpha =0;
            coinSelectView.alpha =0;
        } completion:^(BOOL finished) {
            if (finished) {
                [ges.view removeFromSuperview];
                [coinSelectView removeFromSuperview];
            }
        }];
    }];
}
-(instancetype)initWithFrame:(CGRect)frame model:(id)model success :(void(^)(NSString *rewardNum)) completeBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataModel = model;
        _complete = completeBlock;
        [self configureUI];
    }
    return self;
}

-(void)configureUI
{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat itemHeight =55;
    NSArray *itemArray = @[@"15",@"50",@"100",AYLocalizedString(@"取消")];
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton* itemBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:14] textColor:UIColorFromRGB(0x333333) title:[NSString stringWithFormat:@" %@",obj] image:(idx ==3)?nil:LEImage(@"wujiaoxin_select")];
        [itemBtn setImage:LEImage(@"wujiaoxin_select") forState:UIControlStateHighlighted];
        itemBtn.backgroundColor = [UIColor clearColor];
        itemBtn.frame = CGRectMake(0, idx*itemHeight, ScreenWidth, itemHeight);
        itemBtn.tag = 1098+idx;
        if(idx<3)
        {
            CALayer *lineLayer = [CALayer layer];
            lineLayer.backgroundColor = UIColorFromRGB(0xeaeaea).CGColor;
            lineLayer.frame =CGRectMake(0, (idx+1)*itemHeight, ScreenWidth, 1.0f);
            [self.layer addSublayer:lineLayer];
        }
        LEWeakSelf(self)
        [itemBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
            if (btn.tag-1098<3) {
                NSString *price = [itemArray objectAtIndex:(btn.tag - 1098)];
                if ([AYUserManager isUserLogin])
                {
                    [self readyReward:[price intValue]];
                }
                else
                {
                    [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                        [self readyReward:[price intValue]];
                    }];
                }
            }
            else
            {
                if (self.coinSelectActionCancle) {
                    self.coinSelectActionCancle();
                }
            }
        }];
        [self addSubview:itemBtn];
    }];
}
-(void)readyReward:(int)price
{
    //余额不足，需充值
    if ([[AYUserManager userItem].coinNum integerValue]<price) {
        [[NSUserDefaults standardUserDefaults] setObject:([self.dataModel isKindOfClass:AYCartoonDetailModel.class]?@(AYChargeLocationTypeCartoonChapter):@(AYChargeLocationTypeFictionReward)) forKey:kUserDefaultUserChargeBookType];
        if ([self.dataModel isKindOfClass:AYCartoonDetailModel.class])
        {
            AYCartoonDetailModel *cartoonDetail = self.dataModel;
            [[NSUserDefaults standardUserDefaults] setObject:cartoonDetail.cartoonID forKey:kUserDefaultUserChargeBookId];
        }
        else
        {
            AYFictionDetailModel *fictionDetail = self.dataModel;
            [[NSUserDefaults standardUserDefaults] setObject:fictionDetail.fictionID forKey:kUserDefaultUserChargeBookId];
        }
        
  
        [[NSUserDefaults standardUserDefaults] synchronize];
        LEWeakSelf(self)
        [AYChargeSelectContainView showChargeSelectInView:self.superview compete:^{
            LEStrongSelf(self)
            [self userReward:price];
        }];
    }
    else
    {
        [self userReward:price];
    }
}
-(void)userReward:(int)price
{
    [[self parentViewController] showHUD];
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        if([self.dataModel isKindOfClass:AYCartoonDetailModel.class])
        {
            [params addValue:((AYCartoonDetailModel*)self.dataModel).cartoonID forKey:@"book_id"];
            [params addValue:@(2) forKey:@"type"];
        }
        else if([self.dataModel isKindOfClass:AYCartoonModel.class])
        {
            [params addValue:((AYCartoonModel*)self.dataModel).cartoonID forKey:@"book_id"];
            [params addValue:@(2) forKey:@"type"];
        }
        else
        {
            [params addValue:((AYFictionDetailModel*)self.dataModel).fictionID forKey:@"book_id"];
            [params addValue:@(1) forKey:@"type"];
        }
        [params addValue:@(price) forKey:@"reward_price"];
    }];
    [ZWNetwork post:@"HTTP_Post_User_Reward" parameters:para success:^(id record)
     {
         [[self parentViewController] hideHUD];
         occasionalHint(AYLocalizedString(@"打赏成功"));
         NSString *myMoney = [record[@"remainder"] stringValue];
         if (myMoney)
         {
             [AYUserManager userItem].coinNum = myMoney;
             [AYUserManager save];
             
         }
         if (self.complete) {
             self.complete([@(price) stringValue]);
         }

     } failure:^(LEServiceError type, NSError *error) {
        occasionalHint([error localizedDescription]);
         [[self parentViewController] hideHUD];

     }];
}

-(UIViewController*)parentViewController
{
    UIResponder *nextResponder = self.nextResponder;
    while (nextResponder) {
        if ([nextResponder isKindOfClass:UINavigationController.class])
        {
            UINavigationController *nav =(UINavigationController*) nextResponder;
            return (UIViewController*)nav.visibleViewController;
        }
        nextResponder = nextResponder.nextResponder;
    }
    return nil;
}
@end
