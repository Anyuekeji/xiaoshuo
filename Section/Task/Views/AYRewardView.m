//
//  AYRewardView.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/19.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYRewardView.h"

@implementation AYRewardView
+(void)showRewardViewWithTitle:(NSString*)title coinStr:(NSString*)cointStr  detail:(NSString*)detailStr  actionStr:(NSString*)actionStr
{
   // 280*345
    UIView * parentView = [AYUtitle getAppDelegate].window;
    UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
    [shaodowView setBackgroundColor:[UIColor blackColor]];
    shaodowView.alpha=0;
    [parentView addSubview:shaodowView];
    
    CGFloat rewardWidth = 280;
    CGFloat rewardHeight = 345;
    AYRewardView* rewardView = [[AYRewardView alloc] initWithFrame:CGRectMake((ScreenWidth-rewardWidth)/2.0f, (ScreenHeight-rewardHeight)/2.0f, rewardWidth, rewardHeight) title:title coinStr:cointStr detail:detailStr actionStr:actionStr];
    rewardView.tag = SHAREVIEW_TAG;
    [parentView addSubview:rewardView];
    rewardView.userInteractionEnabled = NO;
    rewardView.alpha =0;
    LEWeakSelf(rewardView)
    LEWeakSelf(shaodowView)
    [shaodowView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(rewardView)
        LEStrongSelf(shaodowView)
        [UIView animateWithDuration:0.3f animations:^{
            shaodowView.alpha = 0;
            rewardView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [rewardView removeFromSuperview];
            }
        }];
    }];
    [UIView animateWithDuration:0.3f animations:^{
        shaodowView.alpha = 0.5f;
        rewardView.alpha = 1.0f;
    }];
}

-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title coinStr:(NSString*)cointStr  detail:(NSString*)detailStr  actionStr:(NSString*)actionStr
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI:title coinStr:cointStr detail:detailStr actionStr:actionStr];
    }
    return self;
}
-(void)dealloc
{
}
-(void)configureUI:(NSString*)title coinStr:(NSString*)cointStr  detail:(NSString*)detailStr  actionStr:(NSString*)actionStr
{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    backImageView.image = LEImage(@"reward_tip");
    [self addSubview:backImageView];
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:15] textColor:UIColorFromRGB(0xFEFEFE) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    titleLable.frame = CGRectMake((self.width-250)/2.0f, 136, 250, 20);
    titleLable.text = title;
    [self addSubview:titleLable];
    
    UILabel *coinLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:37] textColor:UIColorFromRGB(0xFA556C) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    coinLable.frame = CGRectMake((self.width-150)/2.0f, 50+titleLable.top, 150, 40);
    coinLable.text = [NSString stringWithFormat:@"+%@",cointStr];
    [self addCoinImageToLable:coinLable bigIcon:YES];
    [self addSubview:coinLable];
    
    UILabel *detaiLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:15] textColor:UIColorFromRGB(0x666666) textAlignment:NSTextAlignmentCenter numberOfLines:0];
    detaiLable.frame = CGRectMake(15, 99+titleLable.top, self.width-30, 45);
    detaiLable.text = detailStr;
    if(![title isEqualToString:AYLocalizedString(@"观看完成")])
    {
        [self addCoinImageToLable:detaiLable bigIcon:NO];
    }
    [self addSubview:detaiLable];
    
    UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:19] textColor:UIColorFromRGB(0xffffff) title:actionStr image:nil];
    actionBtn.layer.cornerRadius = 16;
    actionBtn.clipsToBounds = YES;
    [actionBtn setBackgroundColor:UIColorFromRGB(0xfa556c)];
    actionBtn.frame = CGRectMake((self.width-162)/2.0f, titleLable.top+155, 162, 38);
    [self addSubview:actionBtn];
}

-(void)addCoinImageToLable:(UILabel*)coinLable bigIcon:(BOOL)bigIcon
{
    NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = [UIImage imageNamed:@"wujiaoxin_select"];
    backAttachment.bounds =bigIcon?CGRectMake(2,(bigIcon?-5:-2), 38, 38):CGRectMake(0, -2, 14, 14);
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:coinLable.text];
    NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    [orginalAttributString appendAttributedString:newAttributString];
    coinLable.attributedText = orginalAttributString;
}
@end
