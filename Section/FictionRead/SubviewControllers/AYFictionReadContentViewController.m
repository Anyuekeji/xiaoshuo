//
//  AYFictionReadContentViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/19.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionReadContentViewController.h"
#import "LEBatteryView.h" //电池视图
#import "AYShowTextView.h" //显示文本视图
#import <objc/runtime.h>
#import "CYFictionChapterModel.h" //章节信息
#import "AYChargeView.h" //提示付费和充值view
#import <GoogleMobileAds/GoogleMobileAds.h> //admob
#import "AYAdmobManager.h"

@interface AYFictionReadContentViewController ()
@property (nonatomic,strong) AYShowTextView *textView;
@property (nonatomic,strong) UILabel *timeLable;
@property (nonatomic,strong) UILabel *percentLabel;
@property (nonatomic,strong) LEBatteryView *battery;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) AYFictionReadContentTopview *topView;
@property (nonatomic,strong) AYFictionReadContentBottomview *bottomView;

@end

@implementation AYFictionReadContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.content && self.content.length>0 && !self.showAd)
    {
        _textView.string = self.content;
        [_textView setNeedsDisplay];
    }
    if(self.turnPageType != AYTurnPageUpdown)
    {
        [_bottomView updateBottomValue:self.totalPage current:self.currentPage showAd:self.showAd];
    }
    if (self.showAd) {
        [[AYAdmobManager shared] createAdBannerView:self];
        [[AYAdmobManager shared] createContainSelectAdBannerView:self];
    }
    if(_currentPage == _totalPage)//最后一页
    {
        [[AYAdmobManager shared] createSmallAdBannerView:self];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.showAd) {
        [[AYAdmobManager shared] createAdBannerView:self];
        [[AYAdmobManager shared] createContainSelectAdBannerView:self];
    }
}
-(void)configureUI
{
    if (self.content.length<=0) {
        [self addNoContentTipView];
        return;
    }
    if(self.turnPageType != AYTurnPageUpdown)
    {
        _topView = [[AYFictionReadContentTopview alloc] initWithFrame:CGRectMake(0, 3, ScreenWidth, 13)];
        [_topView updateTopValue:self.chapterTitle];
        [self.view addSubview:_topView];
        _bottomView = [[AYFictionReadContentBottomview alloc] initWithFrame:CGRectMake(0,(_ZWIsIPhoneXSeries()?([AYUtitle getReadContentSize].height+28): ScreenHeight-25), ScreenWidth, 20) showAd:self.showAd];
        [_bottomView updateBottomValue:self.totalPage current:self.currentPage showAd:self.showAd];
        [self.view addSubview:_bottomView];
    }
    if (self.showAd)
    {
        [self.view addSubview:[AYAdmobManager shared].containSelectAdBannerView];
        [AYAdmobManager shared].containSelectAdBannerView.top =(self.view.height-[AYAdmobManager shared].containSelectAdBannerView.height)/2.0f;
    }
    else
    {
        CGSize viewSize = [AYUtitle getReadContentSize];;
        _textView = [[AYShowTextView alloc] initWithFrame:CGRectMake(13,(self.turnPageType==AYTurnPageUpdown)?1:22, viewSize.width,viewSize.height)];
        [self.view addSubview:_textView];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [self getReadFontColor];
        if(self.content && self.content.length>0)
        {    _textView.string = _content;
            [_textView setNeedsDisplay];
        }
        _textView.font = [AYUtitle getReadFontSize];
        if(_currentPage == _totalPage && self.chapterShowAd)//最后一页 如果是广告 就显示广告
        {
            CGFloat contentHeight =LETextHeight(self.content, [UIFont systemFontOfSize:[AYUtitle getReadFontSize]], _textView.width);
            CGFloat dis_height =self.view.height - contentHeight-100;
            if (dis_height>130)//弹广告
            {
                if(dis_height>350)
                {
                    [self.view addSubview:[AYAdmobManager shared].adBannerView];
                    [AYAdmobManager shared].adBannerView.top =self.textView.top+contentHeight+(dis_height-[AYAdmobManager shared].adBannerView.height)/2.0f;
                    return;
                }
                [self.view addSubview:[AYAdmobManager shared].smallAdBannerView];
                [AYAdmobManager shared].smallAdBannerView.top =self.textView.top+contentHeight+20+(dis_height-[AYAdmobManager shared].smallAdBannerView.height)/2.0f;
            }
        }
        if ([self.chapterModel.needMoney integerValue]>0 && ![self.chapterModel.unlock boolValue] && !self.chapterShowAd)
        {

            LEWeakSelf(self)
            [AYChargeView showChargeViewInView:self.view fiction:YES  chapterModel:self.chapterModel chargeReslut:^(CYFictionChapterModel * _Nonnull chapterModel, AYChargeView *chargeView ,BOOL suceess ) {
                LEStrongSelf(self)
                if(suceess)
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        if (chargeView.tag ==AD_CHARGE_TAG) {
                            chargeView.superview.alpha =0;
                        }
                        else
                        {
                            chargeView.alpha =0;
                        }
                        [self.view viewWithTag:CHARGE_MASK_TAG].alpha = 0;
                    } completion:^(BOOL finished) {
                        if (chargeView.tag ==AD_CHARGE_TAG) {
                            [chargeView.superview removeFromSuperview];
                        }
                        else
                        {
                            [chargeView removeFromSuperview];
                        }
                        [[self.view viewWithTag:CHARGE_MASK_TAG] removeFromSuperview];
                    }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFictionAddToRackEvents object:self.chapterModel.fictionID];                if (self.chargeResultAction) {
                        self.chargeResultAction(chapterModel, suceess);
                    }
                }
            }];
        }
    }
}
#pragma mark - public -

#pragma mark - help -

#pragma mark - getter and setter -

-(void)setChapterTitle:(NSString *)chapterTitle
{
    _chapterTitle = chapterTitle;
    _titleLabel.text = chapterTitle;
}
-(void)addNoContentTipView
{
    UILabel *tipLalbe = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:[self getReadFontColor] textAlignment:NSTextAlignmentCenter numberOfLines:2];
    
    tipLalbe.text = AYLocalizedString(@"暂无数据，点击重试");
    tipLalbe.frame = CGRectMake(20, (SCREEN_HEIGHT-100)/2.0f, ScreenWidth-40, 100);
    [self.view addSubview:tipLalbe];
    LEWeakSelf(self)
    [tipLalbe addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        if(self.reloadSectionContent)
        {
            self.reloadSectionContent();
        }
    }];
}
-(void)updateContentApperance
{
   BOOL night = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultNightMode];
    if (night)
    {
        self.timeLable.textColor = UIColorFromRGB(0x888888);
        self.percentLabel.textColor =UIColorFromRGB(0x888888);
        self.titleLabel.textColor =UIColorFromRGB(0x888888);
        self.textView.textColor =UIColorFromRGB(0x888888);
        [self.textView setNeedsDisplay];
    }
    else
    {
        self.timeLable.textColor = UIColorFromRGB(0x333333);
        self.percentLabel.textColor =UIColorFromRGB(0x333333);
        self.titleLabel.textColor =UIColorFromRGB(0x333333);
        self.textView.textColor =UIColorFromRGB(0x555555);;
        [self.textView setNeedsDisplay];
    }
}
-(UIColor*)getReadFontColor
{
    BOOL night = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultNightMode];
    if (night)
    {
        return UIColorFromRGB(0x888888);
    }
    else
    {
        return UIColorFromRGB(0x555555);
    }
}
@end

@interface AYFictionReadContentTopview()
@property (nonatomic,strong) UILabel *titleLabel;
@end

@implementation AYFictionReadContentTopview
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
    _titleLabel = [UILabel lableWithTextFont:[UIFont systemFontOfSize:8] textColor:[self getReadFontColor] textAlignment:NSTextAlignmentLeft numberOfLines:1];
    _titleLabel.frame = CGRectMake(10, 0, ScreenWidth-20, 10);
    [self addSubview:_titleLabel];
}
-(void)updateTopValue:(NSString*)title
{
    self.titleLabel.text = title;
}

-(UIColor*)getReadFontColor
{
    BOOL night = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultNightMode];
    if (night)
    {
        return UIColorFromRGB(0x888888);
    }
    else
    {
        return UIColorFromRGB(0x555555);
    }
}
@end
@interface AYFictionReadContentBottomview()
@property (nonatomic,strong) UILabel *timeLable;
@property (nonatomic,strong) UILabel *percentLabel;
@property (nonatomic,strong) LEBatteryView *battery;
@property (nonatomic,assign) BOOL showAd;
@end

@implementation AYFictionReadContentBottomview
-(instancetype)initWithFrame:(CGRect)frame showAd:(BOOL)showAd
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showAd = showAd;
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    _battery = [[LEBatteryView alloc]initWithLineColor:[UIColor grayColor]];
    self.battery.frame = CGRectMake(15,(self.height-20)/2.0f, 20, 20);
    [self addSubview:_battery];
    [self.battery runProgress:[self getCurrentBatteryLevel]];
    
    _timeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:10] textColor:[self getReadFontColor] textAlignment:NSTextAlignmentRight numberOfLines:1];
    _timeLable.text = [self getCurrentTimes];
    _timeLable.frame = CGRectMake(_battery.left+_battery.width+10, _battery.top-5, 30, 20);
    [self addSubview:_timeLable];
    if (!self.showAd)
    {
        _percentLabel = [UILabel lableWithTextFont:[UIFont systemFontOfSize:10] textColor:[self getReadFontColor] textAlignment:NSTextAlignmentRight numberOfLines:1];
        _percentLabel.frame = CGRectMake(ScreenWidth-60-15, _battery.top-5, 60, 20);
        [self addSubview:_percentLabel];
    }
}
#pragma mark - public -
-(void)updateBottomValue:(NSInteger)totalpage current:(NSInteger)currentPage showAd:(BOOL)showAd
{
    if (showAd) {
        _percentLabel.text = @"";
        return;
    }
    if(currentPage ==0)
    {
        _percentLabel.text = @"0.0%";
    }
    else
    {
        _percentLabel.text = [NSString stringWithFormat:@"%.2f%@",(currentPage*100.0f)/(totalpage*1.0f),@"%"];
    }
    if (AY_CURRENT_COUNTRY == AYCountryVietnam)
    {
        
        _percentLabel.text = [NSString stringWithFormat:@"%d/%d",(int)currentPage+1,(int)totalpage+1];
    }
}
#pragma mark - help -
-(NSString*)getCurrentTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}
- (CGFloat)getCurrentBatteryLevel
{
    UIApplication *app = [UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateActive||app.applicationState==UIApplicationStateInactive) {
        Ivar ivar=  class_getInstanceVariable([app class],"_statusBar");
        id status  = object_getIvar(app, ivar);
        for (id aview in [status subviews]) {
            int batteryLevel = 0;
            for (id bview in [aview subviews]) {
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame&&[[[UIDevice currentDevice] systemVersion] floatValue] >=6.0) {
                    Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                    if(ivar) {
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            return batteryLevel;
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }
    return 0;
}
-(UIColor*)getReadFontColor
{
    BOOL night = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultNightMode];
    if (night)
    {
        return UIColorFromRGB(0x888888);
    }
    else
    {
        return UIColorFromRGB(0x555555);
    }
}
@end
