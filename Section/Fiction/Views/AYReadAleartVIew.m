//
//  AYReadAleartVIew.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/21.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYReadAleartVIew.h"

#define AY_READALERT_TAG 64865
#define AY_SHOWDOW_TAG 64863

@interface AYReadAleartVIew()
@property (copy, nonatomic) void(^okBlock)(bool ok,UIView *alertView);

@end

static UIView *readAlertShaodowView = nil;
static UIView *readAlertView = nil;

@implementation AYReadAleartVIew

+(void)shareReadAleartViewWithTitle:(NSString*)title okActionTitle:(NSString*)okTitle okCancle:(BOOL)autoCancle cancleActionTitle:(NSString*)cancleTitle parentView:(UIView*)parentView okBlock : (void(^)(bool ok)) okBlock
{
    if (!parentView) {
        parentView = [AYUtitle getAppDelegate].window;
    }
    UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
    [shaodowView setBackgroundColor:[UIColor blackColor]];
    shaodowView.alpha=0;
    shaodowView.tag = AY_SHOWDOW_TAG;
    [parentView addSubview:shaodowView];
    readAlertShaodowView = shaodowView;
    
    AYReadAleartVIew* aleartView = [[AYReadAleartVIew alloc] initWithTitle:title okActionTitle:okTitle cancleActionTitle:cancleTitle compelte:^(bool ok,UIView *alertView) {
        if (okBlock) {
            okBlock(ok);
        }
        if (!autoCancle && ok)
        {
            return;
        }
        [UIView animateWithDuration:0.3f animations:^{
            shaodowView.alpha = 0;
            alertView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [alertView removeFromSuperview];
            }
        }];
    }];
    [parentView addSubview:aleartView];
    readAlertView = aleartView;
    aleartView.tag = AY_READALERT_TAG;
    aleartView.alpha =0;
    LEWeakSelf(aleartView)
    LEWeakSelf(shaodowView)
    [shaodowView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        if (!autoCancle) {
            return ;
        }
        LEStrongSelf(aleartView)
        LEStrongSelf(shaodowView)
        [UIView animateWithDuration:0.3f animations:^{
            shaodowView.alpha = 0;
            aleartView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [aleartView removeFromSuperview];
            }
        }];
    }];
    [UIView animateWithDuration:0.4f animations:^{
        shaodowView.alpha = 0.5f;
        aleartView.alpha = 1.0f;
    }];
}
+(void)removeReadAleartView
{

    if (readAlertView  && readAlertShaodowView)
    {
        [UIView animateWithDuration:0.3f animations:^{
            readAlertShaodowView.alpha = 0;
            readAlertView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [readAlertShaodowView removeFromSuperview];
                [readAlertView removeFromSuperview];
            }
        }];
    }

}

-(instancetype)initWithTitle:(NSString*)title okActionTitle:(NSString*)okTitle  cancleActionTitle:(NSString*)cancleTitle compelte : (void(^)(bool ok,UIView *alertView)) compelteBlock
{
    self = [super initWithFrame:CGRectMake(15, (ScreenHeight-206)/2.0f, ScreenWidth-30, 206)];
    if (self)
    {
        self.okBlock = compelteBlock;
        [self configureUIWithTitle:title okActionTitle:okTitle cancleActionTitle:cancleTitle];
    }
    return self;
}

-(void)configureUIWithTitle:(NSString*)title okActionTitle:(NSString*)okTitle  cancleActionTitle:(NSString*)cancleTitle
{
    self.layer.cornerRadius = 5.0f;
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:0];
    titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    titleLable.text= title;
    titleLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLable];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.layer.cornerRadius = 19.0f;
    okBtn.backgroundColor = UIColorFromRGB(0xff6666);
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okBtn.translatesAutoresizingMaskIntoConstraints = NO;

    okBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [okBtn setTitle:okTitle forState:UIControlStateNormal];
    [self addSubview:okBtn];
    LEWeakSelf(self)
    [okBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if (self.okBlock) {
            self.okBlock(YES,self);
        }
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.layer.cornerRadius = 19.0f;
    cancelBtn.layer.borderWidth= 1.0f;
    cancelBtn.layer.borderColor = UIColorFromRGB(0xe5e5e5).CGColor;
    cancelBtn.backgroundColor = UIColorFromRGB(0xffffff);
    [cancelBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelBtn setTitle:cancleTitle forState:UIControlStateNormal];

    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:cancelBtn];
    
    [cancelBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        if (self.okBlock) {
            self.okBlock(NO,self);
        }
    }];
    
    NSDictionary * _binds = @{@"titleLable":titleLable, @"cancelBtn":cancelBtn, @"okBtn":okBtn};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[titleLable]-15-[okBtn(==39@999)]-15-[cancelBtn(==39@999)]-25-|" options:0 metrics:nil views:_binds]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-28-[titleLable]-28-|" options:0 metrics:nil views:_binds]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-28-[okBtn]-28-|" options:0 metrics:nil views:_binds]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-28-[cancelBtn]-28-|" options:0 metrics:nil views:_binds]];
}
@end
