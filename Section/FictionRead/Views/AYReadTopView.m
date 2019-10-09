//
//  AYReadTopView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYReadTopView.h"

@interface AYReadTopView ()
@property(nonatomic,strong)UILabel *titleLable;
@property(nonatomic,assign)bool advertiseMode;
@end

@implementation AYReadTopView

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    //返回btn
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, STATUS_BAR_HEIGHT+(44-30)/2.0f, 30, 30);
    [backBtn setImage:LEImage(@"btn_back_nav") forState:UIControlStateNormal];
    [self addSubview:backBtn];
    [backBtn setEnlargeEdgeWithTop:20 right:20 bottom:20 left:20];
    LEWeakSelf(self)
    [backBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if([self.delegate respondsToSelector:@selector(backInReadTopView:)])
        {
            [self.delegate backInReadTopView:self];
        }
        
    }];
    //分享btn
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(ScreenWidth-15-24, STATUS_BAR_HEIGHT+(44-24)/2.0f, 24, 24);
    [shareBtn setImage:LEImage(@"task_shared") forState:UIControlStateNormal];
    [self addSubview:shareBtn];
    [shareBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [shareBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if([self.delegate respondsToSelector:@selector(shareInReadTopView:)])
        {
            [self.delegate shareInReadTopView:self];
        }
    }];
    
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:18] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    titleLable.frame = CGRectMake(40, STATUS_BAR_HEIGHT+7, ScreenWidth-86, 30);
    [self addSubview:titleLable];
    _titleLable= titleLable;
    //设置阴影
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 1;
    
    // 单边阴影 底边边
    float shadowPathWidth = self.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, self.bounds.size.height+shadowPathWidth/2.0, self.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    self.layer.shadowPath = path.CGPath;
}
-(void)setTitle:(NSString *)title
{
    _title = title;
    _titleLable.text = title;
}
-(void)changeToAdvertiseMode:(BOOL)advertiseMode  
{
    if (advertiseMode == self.advertiseMode) {
        return;
    }
    _advertiseMode = advertiseMode;
    if (advertiseMode)
    {
        self.titleLable.layer.borderWidth =1.0f;
        self.titleLable.layer.borderColor= UIColorFromRGB(0xFF6666).CGColor;
        self.titleLable.textColor =UIColorFromRGB(0xFF6666);
        self.titleLable.layer.cornerRadius =15.0f;
        self.titleLable.clipsToBounds = YES;
        LEWeakSelf(self)
        [self. titleLable addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            LEStrongSelf(self)
            if ([self.delegate respondsToSelector:@selector(switchUnlockModeInAdverttiseModeIReadTopView:unlockMode:)])
            {
                [self.delegate switchUnlockModeInAdverttiseModeIReadTopView:self unlockMode:([self.titleLable.text isEqualToString:AYLocalizedString(@"不想看广告")]?NO:YES)];
            }
        }];
    }
    else
    {
        self.titleLable.layer.borderWidth =0;
        self.titleLable.textColor =RGB(51, 51, 51);
        self.titleLable.text =_title;
        for (UIGestureRecognizer *ges in self.titleLable.gestureRecognizers) {
                 [self.titleLable removeGestureRecognizer:ges];
        }
    }

}
-(void)changeCoinModeInAdverse:(BOOL)coin
{
    if (self.titleLable.layer.borderWidth>0) {
        self.titleLable.text =coin?AYLocalizedString(@"看广告免费阅读"):AYLocalizedString(@"不想看广告");

    }

}

@end
