//
//  AYReadAppearanceSetView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYReadAppearanceSetView.h"
#import "UIImage+YYAdd.h"

#define  AYRead_Flag_Tag 56212

#define  AYRead_AppearanceView_Tag 56512

@interface AYReadAppearanceSetView()
@property(nonatomic,strong) UIImageView *selectFlagImageView;
@end

static UIView *static_shaodowView = nil;
static UIView *static_appearanceView = nil;

@implementation AYReadAppearanceSetView

+(void)showAppearanceSetViewInView:(UIView*)parentView
{
    UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
    [shaodowView setBackgroundColor:[UIColor clearColor]];
    [parentView addSubview:shaodowView];
    static_shaodowView =shaodowView;
    AYReadAppearanceSetView* appearanceSetView = [[AYReadAppearanceSetView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 216)];
    [parentView addSubview:appearanceSetView];
    appearanceSetView.tag= AYRead_AppearanceView_Tag;
    static_appearanceView = appearanceSetView;
    appearanceSetView.delegate = parentView.nextResponder;
    LEWeakSelf(appearanceSetView)
    LEWeakSelf(shaodowView)
    
    [shaodowView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(appearanceSetView)
        LEStrongSelf(shaodowView)
        
        [UIView animateWithDuration:0.3 animations:^{
            appearanceSetView.top = ScreenHeight;
        } completion:^(BOOL finished) {
            if (finished) {
                [shaodowView removeFromSuperview];
                [appearanceSetView removeFromSuperview];
            }
        }];
    }];
    [UIView animateWithDuration:0.5f animations:^{
        appearanceSetView.top = parentView.height-appearanceSetView.height;
    }];
}
+(void)removeAppearanceSetView
{
    if (static_appearanceView && static_shaodowView)
    {
        [UIView animateWithDuration:0 animations:^{
            static_appearanceView.alpha = 0;
            static_shaodowView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [static_appearanceView removeFromSuperview];
                [static_shaodowView removeFromSuperview];
                static_shaodowView = nil;
                static_appearanceView= nil;
            }
        }];
    }

}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    return self;
}

-(void)configureUI
{
    self.backgroundColor = [UIColor whiteColor];
    [self createLightScreenView];
    [self createFontSetView];
    [self createTurnPageSetView];
    [self creatBackgroundColorView];
}

-(void)createLightScreenView
{
    UIView *lightView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 40)];
    [self addSubview: lightView];
    if (AY_CURRENT_COUNTRY == AYCountryVietnam)
    {
        lightView.backgroundColor =UIColorFromRGB(0xf7f7f7);
        lightView.clipsToBounds = YES;
        lightView.layer.cornerRadius = 20.0f;
    }
    UIImageView *smallSun = [[UIImageView alloc] initWithFrame:CGRectMake(20, (40-15)/2.0f, 15, 15)];
    smallSun.image = LEImage(@"read_light");
    [lightView addSubview:smallSun];
    
    UIImageView *bigSun = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-15-22, (40-22)/2.0f, 22, 22)];
    bigSun.image = LEImage(@"read_light");
    [lightView addSubview:bigSun];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(smallSun.frame.origin.x+smallSun.bounds.size.width+10, 10, bigSun.frame.origin.x-smallSun.frame.origin.x-smallSun.bounds.size.width-20, 20)];
    [lightView addSubview:slider];
    slider.minimumValue = 0;// 设置最小值
    slider.maximumValue = 1;// 设置最大值
    slider.value = [UIScreen mainScreen].brightness;// 设置初始值
    slider.minimumTrackTintColor = RGB(250, 85, 108); //滑轮左边颜色，如果设置了左边的图片就不会显示
    slider.maximumTrackTintColor =  RGB(230, 230, 230); //滑轮右边边颜色，如果设置了右边的图片就不会显示
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
    UIImage *thumbImage =[UIImage imageWithColor:RGB(250, 85, 108) size:CGSizeMake(20, 20)];
    thumbImage = [thumbImage imageByRoundCornerRadius:thumbImage.size.height/2.0f];
    
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
}
-(void)createFontSetView
{
    UIView *fontSetView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, ScreenWidth, 40)];
    [self addSubview:fontSetView];
    if (AY_CURRENT_COUNTRY == AYCountryVietnam)
    {
        fontSetView.backgroundColor =UIColorFromRGB(0xf7f7f7);
        fontSetView.clipsToBounds = YES;
        fontSetView.layer.cornerRadius = 20.0f;
    }
    else
    {
        fontSetView.frame= CGRectMake(0, 65, ScreenWidth, 28);
    }
    CGFloat btnWidth =(ScreenWidth - 15*2- 50)/2.0f;
    
    UIButton *subtractBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(51, 51, 51) title:@"A-" image:nil];

    subtractBtn.layer.cornerRadius =(AY_CURRENT_COUNTRY == AYCountryVietnam)?5:14.0f;
    subtractBtn.clipsToBounds = YES;
    subtractBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
    subtractBtn.layer.borderWidth = 1.0f;
    subtractBtn.frame = CGRectMake(15, 0, btnWidth, 28);
    if (AY_CURRENT_COUNTRY == AYCountryVietnam)
    {
        subtractBtn.frame = CGRectMake(53, 6, btnWidth, 28);
    }
    [fontSetView addSubview:subtractBtn];
    

    UILabel *fontSizeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:16] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    fontSizeLable.text = [NSString stringWithFormat:@"%d",(int)[AYUtitle getReadFontSize]];
    fontSizeLable.frame = CGRectMake(subtractBtn.frame.origin.x+btnWidth, 0, 50, 28);
    if (AY_CURRENT_COUNTRY == AYCountryVietnam)
    {
        fontSizeLable.textAlignment = NSTextAlignmentLeft;
        fontSizeLable.frame = CGRectMake(15, 6, 50, 28);
    }
    [fontSetView addSubview:fontSizeLable];
    
    [subtractBtn addAction:^(UIButton *btn) {
        NSInteger currentValue = [fontSizeLable.text integerValue];
        if(currentValue<=12)
        {
            return ;
        }
        currentValue -=1;
    
        fontSizeLable.text = [NSString stringWithFormat:@"%ld",currentValue];
        
        if([self.delegate respondsToSelector:@selector(fontSizeChange: value:)])
        {
            [self.delegate fontSizeChange:self value:currentValue];
        }
    }];
    
    UIButton *plusBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(51, 51, 51) title:@"A+" image:nil];
    plusBtn.layer.cornerRadius =(AY_CURRENT_COUNTRY == AYCountryVietnam)?5:14.0f;
    plusBtn.clipsToBounds = YES;
    plusBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
    plusBtn.layer.borderWidth = 1.0f;
    plusBtn.frame = CGRectMake(ScreenWidth-15-btnWidth, 0, btnWidth, 28);
    if (AY_CURRENT_COUNTRY == AYCountryVietnam)
    {
        plusBtn.frame = CGRectMake(ScreenWidth-15-btnWidth, 6, btnWidth, 28);
    }
    [fontSetView addSubview:plusBtn];
    
    [plusBtn addAction:^(UIButton *btn) {
        NSInteger currentValue = [fontSizeLable.text integerValue];
        if(currentValue>=30)
        {
            return ;
        }
        currentValue +=1;
        fontSizeLable.text = [NSString stringWithFormat:@"%ld",currentValue];
        if([self.delegate respondsToSelector:@selector(fontSizeChange: value:)])
        {
            [self.delegate fontSizeChange:self value:currentValue];
        }
    }];

}
-(void)createTurnPageSetView
{
    UIView *turnPagetView = [[UIView alloc] initWithFrame:CGRectMake(0, 170, ScreenWidth, 28)];
    [self addSubview:turnPagetView];
    if (AY_CURRENT_COUNTRY != AYCountryVietnam) {
       turnPagetView.frame= CGRectMake(0, 112, ScreenWidth, 28);
    }
    
    CGFloat btnWidth =(ScreenWidth - 15*2- 15*2)/3.0f;
    
    //仿真btn
    UIButton *pageurlBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(51, 51, 51) title:AYLocalizedString(@"仿真") image:nil];
    pageurlBtn.layer.cornerRadius =(AY_CURRENT_COUNTRY == AYCountryVietnam)?5:14.0f;
    pageurlBtn.clipsToBounds = YES;
    pageurlBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
    pageurlBtn.layer.borderWidth = 1.0f;
    pageurlBtn.frame = CGRectMake(15, 0, btnWidth, 28);
    [pageurlBtn setTitleColor:RGB(250, 84, 108) forState:UIControlStateSelected];
    [turnPagetView addSubview:pageurlBtn];
    //平移btn
    UIButton *scrollBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(51, 51, 51) title:AYLocalizedString(@"平移") image:nil];
    scrollBtn.layer.cornerRadius =(AY_CURRENT_COUNTRY == AYCountryVietnam)?5:14.0f;
    scrollBtn.clipsToBounds = YES;
    scrollBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
    scrollBtn.layer.borderWidth = 1.0f;
    scrollBtn.frame = CGRectMake(pageurlBtn.left+pageurlBtn.width+15, 0, btnWidth, 28);
    [turnPagetView addSubview:scrollBtn];
    [scrollBtn setTitleColor:RGB(250, 84, 108) forState:UIControlStateSelected];
    //上下btn
    UIButton *upScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(51, 51, 51) title:AYLocalizedString(@"上下") image:nil];
    upScrollBtn.layer.cornerRadius =(AY_CURRENT_COUNTRY == AYCountryVietnam)?5:14.0f;
    upScrollBtn.clipsToBounds = YES;
    upScrollBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
    upScrollBtn.layer.borderWidth = 1.0f;
    upScrollBtn.frame = CGRectMake(ScreenWidth-15-btnWidth, 0, btnWidth, 28);
    [turnPagetView addSubview:upScrollBtn];
    [upScrollBtn setTitleColor:RGB(250, 84, 108) forState:UIControlStateSelected];
    LEWeakSelf(pageurlBtn)
    LEWeakSelf(scrollBtn)
    LEWeakSelf(upScrollBtn)
    LEWeakSelf(self)
    [pageurlBtn addAction:^(UIButton *btn) {
        LEStrongSelf(scrollBtn)
        LEStrongSelf(self)
        btn.selected = YES;
        scrollBtn.selected = NO;
        scrollBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
        upScrollBtn.selected = NO;
        upScrollBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
        btn.layer.borderColor = RGB(250, 84, 108).CGColor;
        if([self.delegate respondsToSelector:@selector(turnPageChange: value:)])
        {
            [self.delegate turnPageChange:self value:AYTurnPageCurl];
        }
    }];
    
    [scrollBtn addAction:^(UIButton *btn) {
        LEStrongSelf(pageurlBtn)
        LEStrongSelf(self)
        btn.selected = YES;
        pageurlBtn.selected = NO;
        pageurlBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
        upScrollBtn.selected = NO;
        upScrollBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
        btn.layer.borderColor = RGB(250, 84, 108).CGColor;
        if([self.delegate respondsToSelector:@selector(turnPageChange: value:)])
        {
            [self.delegate turnPageChange:self value:AYTurnPageHorizontal];
        }
    }];
    [upScrollBtn addAction:^(UIButton *btn) {
        LEStrongSelf(pageurlBtn)
        LEStrongSelf(self)
        btn.selected = YES;
        pageurlBtn.selected = NO;
        pageurlBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
        scrollBtn.selected = NO;
        scrollBtn.layer.borderColor = RGB(196, 196, 196).CGColor;
        btn.layer.borderColor = RGB(250, 84, 108).CGColor;
        if([self.delegate respondsToSelector:@selector(turnPageChange: value:)])
        {
            [self.delegate turnPageChange:self value:AYTurnPageUpdown];
        }
    }];
    
    if ([self currentReadTurnPageType] == AYTurnPageCurl)
    {
        pageurlBtn.selected = YES;
        pageurlBtn.layer.borderColor = RGB(250, 84, 108).CGColor;
    }
    else if ([self currentReadTurnPageType] == AYTurnPageUpdown)
    {
        upScrollBtn.selected = YES;
        upScrollBtn.layer.borderColor = RGB(250, 84, 108).CGColor;
    }
    else
    {
        scrollBtn.selected = YES;
        scrollBtn.layer.borderColor = RGB(250, 84, 108).CGColor;
    }
}
-(void)creatBackgroundColorView
{
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, ScreenWidth, 32)];
    [self addSubview:colorView];
    if (AY_CURRENT_COUNTRY != AYCountryVietnam) {
        colorView.frame= CGRectMake(0, 160, ScreenWidth, 32);
    }
    
    
    CGFloat origin_x = 15;
    CGFloat btn_width = 32;
    CGFloat btn_dis = (ScreenWidth - 15*2 - 7*32)/6.0f;
    
    NSArray *colorArray = @[RGB(243, 235, 223),RGB(196, 222, 178),RGB(237, 217, 223),RGB(197, 214, 233),RGB(185, 163, 137),RGB(206, 192, 146),RGB(221, 221, 221)];
    
    [colorArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *colorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        colorBtn.frame = CGRectMake(origin_x+idx*(btn_width+btn_dis), 0, btn_width, btn_width);
        colorBtn.layer.cornerRadius = (AY_CURRENT_COUNTRY == AYCountryVietnam)?5:16.0f;
        colorBtn.clipsToBounds = YES;
        colorBtn.tag = 125+idx;
        [colorBtn setBackgroundColor:obj];
        [colorView addSubview:colorBtn];
        if ([self colorIsEqualToLocalColor:obj]) {
           [self addOrRemvomeSelectFlag:colorBtn];
            
        }
        [colorBtn addAction:^(UIButton *btn) {
            NSInteger tag = btn.tag-125;
            
            if([self.delegate respondsToSelector:@selector(backgroundColorChange: value:)])
            {
                [self addOrRemvomeSelectFlag:btn];
                [self.delegate backgroundColorChange:self value:[colorArray objectAtIndex:tag]];
            }
        }];
    }];
}

-(void)addOrRemvomeSelectFlag:(UIButton*)btn
{
    UIView *flagView = [btn viewWithTag:AYRead_Flag_Tag];
    if (flagView)
    {
        [flagView removeFromSuperview];
        flagView = nil;
    }
    else
    {
        [btn addSubview:[self selectFlagImageView]];
    }
}

#pragma mark - private methods -
-(BOOL)colorIsEqualToLocalColor:(UIColor*)newColor
{
    UIColor *currentColor = [AYUtitle getReadBackgroundColor];
    if([AYUtitle compareRGBAColor1:currentColor withColor2:newColor])
    {
        return YES;
    }
    return NO;
}
-(AYFictionReadTurnPageType)currentReadTurnPageType
{
    NSNumber *turnPageNum = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFictionTurnPageType];
    if (turnPageNum) {
        return  [turnPageNum integerValue];
    }
    else
    {
        return  AYTurnPageCurl;
    }
}
#pragma mark - event handle -
-(void)sliderValueChanged:(UISlider*)slider
{
     [[UIScreen mainScreen] setBrightness:slider.value];
    
}
#pragma mark - getter -
-(UIImageView*)selectFlagImageView
{
    if (!_selectFlagImageView)
    {
        UIImageView *flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake((32-20)/2.0f, (32-20)/2.0f, 20, 20)];
        flagImageView.image = LEImage(@"read_gou");
        flagImageView.tag = AYRead_Flag_Tag;
        _selectFlagImageView = flagImageView;
    }

    return _selectFlagImageView;
}
@end
