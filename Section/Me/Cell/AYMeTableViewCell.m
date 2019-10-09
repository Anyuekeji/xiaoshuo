//
//  AYMeTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/6.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYMeTableViewCell.h"
#import "AYMeModel.h"
#import "AYChargeSelectView.h" //充值界面
#import "AYSignListModel.h"
#import "UILabel+copy.h"
#import "LEClickLable.h"

@interface AYMeTableViewCell ()
@property (nonatomic,strong)UIImageView *iconImageView;//icon
@property (nonatomic,strong)UILabel *titleLable;//标题
@property (nonatomic,strong)UILabel *coinNumLable;//金币数
@property (nonatomic,strong)UIImageView *coinImageView;//金币图片
@property (nonatomic,strong)UIImageView *arrayImageview;//箭头图片
@end

@implementation AYMeTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutUI];
}
-(void)configureUI
{
    UIImageView *headImage = [UIImageView new];
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:headImage];
    _iconImageView = headImage;
    
    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:nameLable];
    nameLable.font = [UIFont systemFontOfSize:DEFAUT_FONTSIZE];
    _titleLable = nameLable;
    
    UILabel *coinNumLable = [UILabel new];
    coinNumLable.translatesAutoresizingMaskIntoConstraints = NO;
    coinNumLable.font = [UIFont systemFontOfSize:14];
    coinNumLable.textColor = UIColorFromRGB(0x999999);
    coinNumLable.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:coinNumLable];
    _coinNumLable = coinNumLable;
    
    UIImageView *coinImageView = [UIImageView new];
    coinImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:coinImageView];
    [coinImageView setImage:LEImage(@"wujiaoxin_select")];
    _coinImageView = coinImageView;
    
    UIImageView *arrayImageView = [UIImageView new];
    arrayImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:arrayImageView];
    [arrayImageView setImage:LEImage(@"arry_right_black")];
    _arrayImageview = arrayImageView;

}
-(void)layoutUI
{
    CGFloat iconImageViewWidth = 24;
    //布局
    NSDictionary * _binds = @{@"coinNumLable":_coinNumLable, @"arrayImageview":_arrayImageview, @"titleLable":_titleLable, @"iconImageView":_iconImageView, @"coinImageView":_coinImageView};
    NSDictionary * _metrics = @{@"imgW":@(iconImageViewWidth)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[iconImageView(==imgW)]-10-[titleLable]-(>=15@999)-[coinNumLable]-2-[coinImageView(==14)]-3-[arrayImageview(==16)]-15-|" options:NSLayoutFormatAlignAllCenterY  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[iconImageView(==imgW)]" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_arrayImageview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:16.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_coinImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:14.0f]];
}
+(CGFloat)cellHeight
{
    return 55.0f;
}
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:NSString.class])
    {
        NSString *str = model;
        NSString *imageName = [NSString stringWithFormat:@"me_%@",str];
        _iconImageView.image = LEImage(imageName);
        _titleLable.text = AYLocalizedString(str);

        if ([str isEqualToString:@"签到"])//签到
        {
            _coinNumLable.text = [NSString stringWithFormat:@""];
            _coinImageView.alpha =1;
            NSString *signStr = [AYLocalizedString(str) replacingString:@"\n" with:@" "];
            _titleLable.text = signStr;

            [self loadSignList];


        }
        else if ([str isEqualToString:@"邀请"])//签到
        {
            NSString *loginRewardNum  = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultInvitaLoginReward];
            if (!loginRewardNum) {
                loginRewardNum = @"20";
            }
            _coinNumLable.text = [NSString stringWithFormat:@"+%@",loginRewardNum];
            _coinImageView.alpha =1;
        }
        else if ([str isEqualToString:@"清理缓存"])//清理缓存
        {
            float catcheSize = [AYUtitle appCacheSize];
            //获取缓存大小
            _coinNumLable.text = [NSString stringWithFormat:@"%.1fM",catcheSize];
            _coinImageView.alpha =0;
            
        }
        else if ([str isEqualToString:@"版本"])//版本信息
        {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            _coinNumLable.text = [NSString stringWithFormat:@"v%@",app_Version];
            _coinImageView.alpha =0;
            _arrayImageview.alpha =0;
            
        }
        else if ([str isEqualToString:@"隐私策略"])//隐私
        {
            _coinImageView.alpha =0;
            _arrayImageview.alpha =1;

        }
        else
        {
            _coinNumLable.text = @"";
            _coinImageView.alpha =0;
        }
    }
}

#pragma mark - network -
-(void)loadSignList
{
    
    NSArray* catcheArray =  [AYSignListModel r_allObjects];
    if (catcheArray && catcheArray.count>0)
    {
        NSInteger day_num =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultUserSignDays];
        BOOL today_sign =  [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultUserTodaySign];
        
        if (today_sign) {
            self.coinNumLable.text = @"";
            self.coinImageView.alpha =0;
        }
        else
        {
            if (day_num<catcheArray.count)
            {
                AYSignListModel *signModel = [catcheArray objectAtIndex:day_num];
                if (signModel)
                {
                    self.coinNumLable.text = [NSString stringWithFormat:@"+%@",signModel.sign_icon];
                }
            }
        }
    }
}
@end


@interface AYMeTableViewHeadCell ()
@property (nonatomic,strong)UIImageView *headImageView;//用户头像
@property (nonatomic,strong)UILabel *idLable;//用户id
@property (nonatomic,strong)UILabel *nameLable;//用户名字
//@property (nonatomic,strong)UIButton *loginBtn;//用户名字
@property (nonatomic,strong) NSArray <NSLayoutConstraint*> *vetralControns;
@property (nonatomic,strong) NSDictionary  *bindDic;

@end
@implementation AYMeTableViewHeadCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutUI];
}
-(void)configureUI
{
    UIImageView *headImage = [UIImageView new];
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:headImage];
    _headImageView = headImage;
    headImage.clipsToBounds = YES;
    headImage.layer.cornerRadius = 18.0f;
    
    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_BIG_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:nameLable];
    _nameLable = nameLable;
    
    UILabel *idLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_FONTSIZE] textColor:[UIColor grayColor] textAlignment:NSTextAlignmentLeft numberOfLines:1];
    idLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:idLable];
    _idLable = idLable;
    idLable.tag = 1264;
    [idLable addLongPressCopy];
    
}
-(void)layoutUI
{
    CGFloat headImageViewWidth = 39;
    //布局
    NSDictionary * _binds = @{@"nameLable":_nameLable, @"headImageView":_headImageView,@"idLalbe":_idLable};
    _bindDic = _binds;
    NSDictionary * _metrics = @{@"imgW":@(headImageViewWidth)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[headImageView(==imgW)]" options:0  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[headImageView(==imgW)]" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-64-[nameLable]-20-|" options:0  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-64-[idLalbe]-20-|" options:0  metrics:_metrics views:_binds]];
    if ([AYUserManager isUserLogin])
    {
        self.vetralControns =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[nameLable(==16@999)]-5-[idLalbe(==13@999)]" options:0 metrics:_metrics views:_binds];
    }
    else
    {
        self.vetralControns =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[nameLable]-22-|" options:0 metrics:_metrics views:_binds];
    }
    [self.contentView addConstraints:self.vetralControns];

}
+(CGFloat)cellHeight
{
    return 83.0f;
}
-(void)filCellWithModel:(id)model
{
    AYMeModel *meModel = [AYUserManager userItem];
    if (meModel)
    {
        if(_idLable.hidden == YES)
        {
            [self.contentView removeConstraints:self.vetralControns];
            self.vetralControns =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[nameLable(==16@999)]-5-[idLalbe(==13@999)]" options:0 metrics:nil views:_bindDic];
            [self.contentView addConstraints:self.vetralControns];
        }
        _idLable.hidden = NO;
        LEImageSet(_headImageView, meModel.myHeadImage, @"me_defalut_icon");
        _nameLable.text = meModel.myNickName;
        _idLable.text = [NSString stringWithFormat:@"ID:%@",meModel.myId];
        
    }
    else
    {
        if(_idLable.hidden == NO)
        {
            [self.contentView removeConstraints:self.vetralControns];
            self.vetralControns =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[nameLable]-22-|" options:0 metrics:nil views:_bindDic];
            [self.contentView addConstraints:self.vetralControns];
        }
        _headImageView.image = LEImage(@"me_defalut_icon");
        _nameLable.text = AYLocalizedString(@"点击登录");
        _idLable.hidden = YES;
    }
}

//-(UIButton*)loginBtn
//{
//    if (_loginBtn) {
//        return _loginBtn;
//    }
//        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        loginBtn.frame = CGRectMake(ScreenWidth-15-55, (83-30)/2.0f, 55, 30);
//        loginBtn.layer.cornerRadius = 14;
//        [loginBtn setBackgroundColor:UIColorFromRGB(0xfa556c)];
//        [loginBtn setTitle:AYLocalizedString(@"登录") forState:UIControlStateNormal];
//        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        loginBtn.titleLabel.font = [UIFont systemFontOfSize:11];
//        [loginBtn addAction:^(UIButton *btn) {
//            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj)
//             {
//                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                 });
//
//             }];
//        }];
//    _loginBtn = loginBtn;
//    return loginBtn;
//}
@end


@interface AYMeChargeTableViewHeadCell ()
@property (nonatomic,strong)UIImageView *iconImageView;//icon
@property (nonatomic,strong)UILabel *coinNumLable;//金币数
@property (nonatomic,strong)UIButton *chargeBtn;//充值btn
@end


@implementation AYMeChargeTableViewHeadCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutUI];
}
-(void)configureUI
{
    UIImageView *headImage = [UIImageView new];
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:headImage];
    _iconImageView = headImage;
    _iconImageView.image = LEImage(@"wujiaoxin_select");

    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:nameLable];
    _coinNumLable = nameLable;
    
    UIButton *chargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chargeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    chargeBtn.layer.cornerRadius = 13;
    [chargeBtn setBackgroundColor:UIColorFromRGB(0xfa556c)];
    [self.contentView addSubview:chargeBtn];
    [chargeBtn setTitle:AYLocalizedString(@"充值") forState:UIControlStateNormal];
    [chargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    chargeBtn.titleLabel.font = [UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE];
    _chargeBtn= chargeBtn;
    LEWeakSelf(self)
    [_chargeBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self);
        if (![AYUserManager isUserLogin])
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [self startCharge];
            }];
        }
        else
        {
            [self startCharge];
        }
    }];
}

-(void)startCharge
{
    
    [[NSUserDefaults standardUserDefaults] setObject:@(AYChargeLocationTypeUsercenter) forKey:kUserDefaultUserChargeBookType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LEWeakSelf(self)
    [AYChargeSelectContainView  showChargeSelectInView:self.superview.superview.superview compete:^{
        AYMeModel *meModel = [AYUserManager userItem];
        if (meModel)
        {
            if([meModel.coinNum isKindOfClass:[NSString class]])
            {
                LEStrongSelf(self)
                self.coinNumLable.text = [NSString stringWithFormat:@"%@：%@",AYLocalizedString(@"剩余金币"),meModel.coinNum];

            }
        }
    }];
}
-(void)layoutUI
{
    CGFloat iconImageViewWidth = 17;
    //布局
    NSDictionary * _binds = @{@"coinNumLable":_coinNumLable, @"iconImageView":_iconImageView, @"chargeBtn":_chargeBtn};
    NSDictionary * _metrics = @{@"imgW":@(iconImageViewWidth)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[coinNumLable]-2-[iconImageView(==imgW)]-(>=20@999)-[chargeBtn(==55)]-20-|" options:NSLayoutFormatAlignAllCenterY  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-17-[iconImageView(==imgW)]" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_chargeBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:25.0f]];
    
    
}
+(CGFloat)cellHeight
{
    return 55.0f;
}
-(void)filCellWithModel:(id)model
{
    AYMeModel *meModel = [AYUserManager userItem];
    if (meModel)
    {
        if([meModel.coinNum isKindOfClass:[NSString class]])
        {
            CGFloat coinNumFloat =[meModel.coinNum floatValue];
            _coinNumLable.text = [NSString stringWithFormat:@"%@：%.1f",AYLocalizedString(@"剩余金币"),coinNumFloat];
        }
        [AYUtitle updateUserCoin:^{
            CGFloat coinNumFloat =[meModel.coinNum floatValue];
            self.coinNumLable.text = [NSString stringWithFormat:@"%@：%.1f",AYLocalizedString(@"剩余金币"),coinNumFloat];
        }];
    }
    else
    {
        _coinNumLable.text = [NSString stringWithFormat:@"%@：%.1f",AYLocalizedString(@"剩余金币"),0.0f];
    }

}
@end
@interface AYMeSetAutoLockTableViewCell ()
@property (nonatomic,strong)UIImageView *iconImageView;//icon
@property (nonatomic,strong)UILabel *coinNumLable;//金币数
@property (nonatomic,strong)UISwitch *lockSwith;//充值btn
@end

@implementation  AYMeSetAutoLockTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutUI];
}
-(void)configureUI
{
    UIImageView *headImage = [UIImageView new];
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:headImage];
    _iconImageView = headImage;
    _iconImageView.image = LEImage(@"me_lock");
    
    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:nameLable];
    _coinNumLable = nameLable;
    
    _lockSwith = [[UISwitch alloc]init];
    _lockSwith.backgroundColor = [UIColor clearColor];
   [_lockSwith setTintColor:RGB(220, 220, 220)];
//    [_lockSwith setOnTintColor:[UIColor blueColor]];
   // [_lockSwith setThumbTintColor:[UIColor whiteColor]];
    _lockSwith.translatesAutoresizingMaskIntoConstraints = NO;
    [_lockSwith addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_lockSwith];
    
    
    NSNumber *autoUnlock=  [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultAutoUnlockChapter];
    self.lockSwith.on = [autoUnlock boolValue];
    

}
-(void)layoutUI
{
    CGFloat iconImageViewWidth = 24;
    //布局
    NSDictionary * _binds = @{@"coinNumLable":_coinNumLable, @"iconImageView":_iconImageView, @"chargeBtn":_lockSwith};
    NSDictionary * _metrics = @{@"imgW":@(iconImageViewWidth)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[iconImageView(==imgW)]-13-[coinNumLable]-(>=20@999)-[chargeBtn(==55)]-20-|" options:NSLayoutFormatAlignAllCenterY  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-17-[iconImageView(==imgW)]" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_lockSwith attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:20.0f]];
}
+(CGFloat)cellHeight
{
    return 55.0f;
}

-(void)switchAction:(UISwitch*)lockSwitch
{
    [[NSUserDefaults standardUserDefaults] setObject:@(lockSwitch.on) forKey:kUserDefaultAutoUnlockChapter];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)filCellWithModel:(id)model
{
    _coinNumLable.text = AYLocalizedString(@"自动解锁");
}
@end

#import "AYUserChargeModel.h"

@interface AYMeChargeRecoreTableViewCell ()
@property (nonatomic,strong)UIImageView *iconImageView;//icon
@property (nonatomic,strong)UILabel *coinNumLable;//金币数
@property (nonatomic,strong)UILabel *chargeTypeLable;//充值类型lable
@property (nonatomic,strong)UILabel *chargeTimeLable;//充值类型lable
@property (nonatomic,strong)UILabel *chargeCoinGiveNumLable;//充值金币赠送数量lable
@end
#import "AYTaskRecordModel.h"


@implementation AYMeChargeRecoreTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutUI];
}
-(void)configureUI
{
    UIImageView *headImage = [UIImageView new];
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:headImage];
    _iconImageView = headImage;
    _iconImageView.image = LEImage(@"wujiaoxin_select");
    
    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_FONTSIZE] textColor:RGB(250, 85, 108) textAlignment:NSTextAlignmentRight numberOfLines:1];
    nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:nameLable];
    _coinNumLable = nameLable;
    
    UILabel *giveLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentRight numberOfLines:1];
    giveLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:giveLable];
    _chargeCoinGiveNumLable = giveLable;
    
    UILabel *timeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    timeLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:timeLable];
    _chargeTimeLable = timeLable;
    
    UILabel *typeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    typeLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:typeLable];
    _chargeTypeLable = typeLable;
    
}
-(void)layoutUI
{
    CGFloat iconImageViewWidth = 17;
    //布局
    NSDictionary * _binds = @{@"coinNumLable":_coinNumLable, @"iconImageView":_iconImageView, @"chargeTypeLable":_chargeTypeLable, @"chargeTimeLable":_chargeTimeLable, @"chargeCoinGiveNumLable":_chargeCoinGiveNumLable};
    NSDictionary * _metrics = @{@"imgW":@(iconImageViewWidth)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[chargeTypeLable]" options:0  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[chargeTimeLable(==110)]" options:0  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[chargeTypeLable(==15@999)]-3-[chargeTimeLable(==12@999)]-18-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[coinNumLable]-1-[chargeCoinGiveNumLable]-1-[iconImageView(==imgW@999)]-15-|" options:NSLayoutFormatAlignAllCenterY  metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[coinNumLable]-18-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:17.0f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_chargeCoinGiveNumLable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f]];
}
+(CGFloat)cellHeight
{
    return 66.0f;
}
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:AYUserChargeModel.class])
    {
        AYUserChargeModel *chargeModel = (AYUserChargeModel*)model;
        
        self.chargeTimeLable.text = chargeModel.chargeTime;
        self.chargeTypeLable.text = chargeModel.charge_type?chargeModel.charge_type:AYLocalizedString(@"充值");
        if ([chargeModel.chargeGiveCoinNum integerValue]>0) {
           // self.chargeCoinGiveNumLable.alpha =1;        self.chargeCoinGiveNumLable.text = [NSString stringWithFormat:@"(%@ %@)",AYLocalizedString(@"Give"), chargeModel.chargeGiveCoinNum];

        }
        else
        {
            self.chargeCoinGiveNumLable.text =@"";
        }
        self.coinNumLable.text = [NSString stringWithFormat:@"+%@",chargeModel.chargeCoinNum];

    }
    else  if ([model isKindOfClass:AYTaskRecordModel.class])
    {
        AYTaskRecordModel *chargeModel = (AYTaskRecordModel*)model;
        
        self.chargeTimeLable.text = chargeModel.taskTime;
        self.chargeTypeLable.text = chargeModel.task_type_name;
        self.coinNumLable.text = [NSString stringWithFormat:@"+%@",chargeModel.taskCoinNum];
        
    }
}
@end

#import "AYConsumeModel.h"

@interface AYMeConsumeRecoreTableViewCell ()
@property(nonatomic,strong) UILabel *consumeTypeLable;
@end


@implementation AYMeConsumeRecoreTableViewCell

-(void)setUp
{
   // [super setUp];
    [self configureUI];
    [self layoutUI];
}
-(void)configureUI
{
    [super configureUI];
    
    UILabel *typeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    typeLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:typeLable];
    _consumeTypeLable = typeLable;
    self.coinNumLable.textColor = UIColorFromRGB(0x999999);
    self.chargeTypeLable.font = [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
    self.chargeCoinGiveNumLable.textColor = RGB(174, 174, 174);
    self.iconImageView.image = LEImage(@"wujiaoxin");
 self.chargeCoinGiveNumLable.textAlignment=NSTextAlignmentLeft;
    self.chargeTimeLable.textColor = UIColorFromRGB(0xaeaeae);
}
-(void)layoutUI
{
    [self.contentView removeConstraints:self.contentView.constraints];
    
    CGFloat iconImageViewWidth = 17;
    
    self.chargeCoinGiveNumLable.font = [UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
    //布局
    NSDictionary * _binds = @{@"coinNumLable":self.coinNumLable, @"iconImageView":self.iconImageView, @"chargeTypeLable":self.chargeTypeLable, @"chargeTimeLable":self.chargeTimeLable, @"chargeCoinGiveNumLable":self.chargeCoinGiveNumLable, @"typeLable":self.consumeTypeLable};
    
    NSDictionary * _metrics = @{@"imgW":@(iconImageViewWidth)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[chargeTypeLable]" options:0  metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[coinNumLable]-2-[typeLable]-2-[iconImageView(==imgW@999)]-15-|" options:NSLayoutFormatAlignAllCenterY  metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[chargeCoinGiveNumLable]-(==20)-[chargeTimeLable(==115@999)]" options:NSLayoutFormatAlignAllCenterY  metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[coinNumLable]-10-|" options:0 metrics:_metrics views:_binds]];
    
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-13-[chargeTypeLable(==15@999)]-3-[chargeCoinGiveNumLable]-13-|" options:0 metrics:_metrics views:_binds]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:17.0f]];
    
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.coinNumLable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:15.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.chargeTimeLable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:15.0f]];
}
+(CGFloat)cellHeight
{
    return 66.0f;
}
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:AYConsumeModel.class])
    {
        AYConsumeModel *chargeModel = (AYConsumeModel*)model;
        
        self.chargeTimeLable.text = chargeModel.consumeTime;
        self.chargeTypeLable.text = chargeModel.consumeProjectType;
        if ([chargeModel.expend_type integerValue]==2)//打赏才显示
        {
            self.chargeCoinGiveNumLable.text = [NSString stringWithFormat:@"(%@)",AYLocalizedString(@"打赏")];
        }
        else
        {
            self.chargeCoinGiveNumLable.text = chargeModel.consumeSection;

            self.consumeTypeLable.text =@"";
        }
    
        self.coinNumLable.text = [NSString stringWithFormat:@"%.1f",[chargeModel.consumeCoinNum floatValue]];
    }
}
@end

#import "AYFriendModel.h"

@interface AYMeFriendRecoreTableViewCell ()
@property (nonatomic,strong)UIImageView *iconImageView;//icon
@property (nonatomic,strong)UILabel *coinNumLable;//金币数
@property (nonatomic,strong)UILabel *chargeTypeLable;//朋友名字lable
@property (nonatomic,strong)UILabel *chargeTimeLable;//时间lable
@end

@implementation AYMeFriendRecoreTableViewCell

-(void)setUp
{
    [super setUp];
    [self configureUI];
    [self layoutUI];
}
-(void)configureUI
{
    UIImageView *headImage = [UIImageView new];
    headImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:headImage];
    _iconImageView = headImage;
    _iconImageView.image = LEImage(@"wujiaoxin_select");
    
    UILabel *nameLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51,51,51) textAlignment:NSTextAlignmentRight numberOfLines:1];
    nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:nameLable];
    _coinNumLable = nameLable;
    
    UILabel *timeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE] textColor:RGB(174, 174, 174) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    timeLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:timeLable];
    _chargeTimeLable = timeLable;
    
    UILabel *typeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    typeLable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:typeLable];
    _chargeTypeLable = typeLable;
    
}
-(void)layoutUI
{
    CGFloat iconImageViewWidth = 17;
    //布局
    NSDictionary * _binds = @{@"coinNumLable":_coinNumLable, @"iconImageView":_iconImageView, @"chargeTypeLable":_chargeTypeLable, @"chargeTimeLable":_chargeTimeLable};
    NSDictionary * _metrics = @{@"imgW":@(iconImageViewWidth)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[chargeTypeLable]-80-|" options:0  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[chargeTimeLable(==110)]" options:0  metrics:_metrics views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[chargeTypeLable(==15@999)]-3-[chargeTimeLable(==12@999)]-18-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[coinNumLable]-1-[iconImageView(==imgW@999)]-15-|" options:NSLayoutFormatAlignAllCenterY  metrics:_metrics views:_binds]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[coinNumLable]-10-|" options:0 metrics:_metrics views:_binds]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:17.0f]];
    
   
}
+(CGFloat)cellHeight
{
    return 66.0f;
}
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:AYFriendModel.class])
    {
        AYFriendModel *chargeModel = (AYFriendModel*)model;
        
        self.chargeTimeLable.text = chargeModel.invateTime;
        self.chargeTypeLable.text =chargeModel.friendName;
        self.coinNumLable.text = [NSString stringWithFormat:@"+%@",chargeModel.coinNum];
        
    }
}
@end


@implementation AYMeTableViewEmptyCell
-(void)setUp
{
    [self configureUI];
}
-(void)configureUI
{
    self.contentView.backgroundColor = RGB(243, 243, 243);
}
+(CGFloat)cellHeight
{
    return 10.0f;
}
@end


@interface AYMeAnswerTableViewCell ()
@property (nonatomic,strong)LEClickLable *answerLable;//金币数
@end


@implementation AYMeAnswerTableViewCell
-(void)setUp
{
    [super setUp];
    [self configureUI];
}
-(void)configureUI
{
    self.contentView.backgroundColor = UIColorFromRGB(0xf7f7f7);
    UIView *containView  = [UIView new];
    containView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:containView];
    
    NSDictionary * _binds = @{@"containView":containView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containView]-1-|" options:0 metrics:nil views:_binds]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containView]-0-|" options:0 metrics:nil views:_binds]];
    LEClickLable *anwserLable = [[LEClickLable alloc] init];
    anwserLable.font =[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE];
    anwserLable.textColor =UIColorFromRGB(0x666666);
    anwserLable.numberOfLines = 0;
    self.answerLable.preferredMaxLayoutWidth = ScreenWidth - 32;
 anwserLable.translatesAutoresizingMaskIntoConstraints = NO;
    _answerLable = anwserLable;
    [containView addSubview:anwserLable];
   // self.answerLable.showLink = YES;
    self.answerLable.matchTextColor = RGB(205, 85, 108);
     [self.answerLable.addStringM addObject:[NSString stringWithFormat:@"%@",AYLocalizedString(@"点我进入")]];
     self.answerLable.userStringTapHandler = ^(UILabel *label,NSString *string,NSRange range,NSInteger matchCount){
         NSString *chargeUrl  = [NSString stringWithFormat:@"%@%@",[AYUtitle getServerUrl],@"home/privacy/icharge"];
         if ([string containsString:AYLocalizedString(@"点我进入")]) {
             [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:chargeUrl animate:YES];
         }
    };

    _binds = @{@"anwserLable":anwserLable};
    [containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[anwserLable]-10-|" options:0 metrics:nil views:_binds]];
    [containView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[anwserLable]-15-|" options:0 metrics:nil views:_binds]];
}
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:NSString.class]) {
        _answerLable.text = model;
    }
}

@end

UIKIT_EXTERN void _AYMeCellsRegisterToTable(UITableView * tableView,int dataType)
{
    if (dataType ==0)
    {
        LERegisterCellForTable(AYMeTableViewHeadCell.class, tableView);
        LERegisterCellForTable(AYMeChargeTableViewHeadCell.class, tableView);
        LERegisterCellForTable(AYMeTableViewCell.class, tableView);
        
    }
    if (dataType ==1)
    {
    LERegisterCellForTable(AYMeSetAutoLockTableViewCell.class, tableView);
        LERegisterCellForTable(AYMeTableViewCell.class, tableView);
    }
    LERegisterCellForTable(AYMeTableViewEmptyCell.class, tableView);

}
UIKIT_EXTERN UITableViewCell * _AYMeGetCellByItem(id object, int dataType,UITableView * tableView, NSIndexPath * indexPath, void(^fetchedEvent)(UITableViewCell * fetchCell))
{
    UITableViewCell * _fetchCell = nil;
    if (dataType ==0)
    {
        if ([object isEqualToString:@"head"]) {
            _fetchCell = LEGetCellForTable(AYMeTableViewHeadCell.class, tableView, indexPath);
            [((AYMeTableViewHeadCell*)_fetchCell) filCellWithModel:object];
        }
        else if ([object isEqualToString:@"empty"]) {
            _fetchCell = LEGetCellForTable(AYMeTableViewEmptyCell.class, tableView, indexPath);
        }
        else if ([object isEqualToString:@"coin"]) {
            _fetchCell = LEGetCellForTable(AYMeChargeTableViewHeadCell.class, tableView, indexPath);
            [((AYMeChargeTableViewHeadCell*)_fetchCell) filCellWithModel:object];
        }
        else
        {
            _fetchCell = LEGetCellForTable(AYMeTableViewCell.class, tableView, indexPath);
            [((AYMeTableViewCell*)_fetchCell) filCellWithModel:object];
        }
    }
    else if ( dataType ==1)
    {
        if ([object isEqualToString:@"lock"]) {
            _fetchCell = LEGetCellForTable(AYMeSetAutoLockTableViewCell.class, tableView, indexPath);
            [((AYMeSetAutoLockTableViewCell*)_fetchCell) filCellWithModel:object];
        }
        else if ([object isEqualToString:@"empty"]) {
            _fetchCell = LEGetCellForTable(AYMeTableViewEmptyCell.class, tableView, indexPath);
        }
        else
        {
            _fetchCell = LEGetCellForTable(AYMeTableViewCell.class, tableView, indexPath);
            [((AYMeTableViewCell*)_fetchCell) filCellWithModel:object];
        }
    }
    //触发事件构成
    if ( _fetchCell && fetchedEvent ) {
        fetchedEvent(_fetchCell);
    } else if ( !_fetchCell ) {
        Debug(@">> 未能找到Cell，此提示出现将引发崩溃！\n");
    }
    return _fetchCell;
}
UIKIT_EXTERN CGFloat _AYMeCellHeightByItem(id object,NSIndexPath * indexPath,int dataType)
{
    if (dataType ==0)
    {
        if ([object isEqualToString:@"head"]) {
            return  LEGetHeightForCellWithObject(AYMeTableViewHeadCell.class, object, nil);
        }
        else if ([object isEqualToString:@"empty"]){
            return  LEGetHeightForCellWithObject(AYMeTableViewEmptyCell.class, object, nil);
        }
        else if ([object isEqualToString:@"coin"]) {
            return  LEGetHeightForCellWithObject(AYMeChargeTableViewHeadCell.class, object, nil);
        }
        else
        {
            return  LEGetHeightForCellWithObject(AYMeTableViewCell.class, object, nil);
        }
    }
    else if (dataType ==1)
    {
        if ([object isEqualToString:@"lock"]) {
    
                return  LEGetHeightForCellWithObject(AYMeSetAutoLockTableViewCell.class, object, nil);
        }
        else if ([object isEqualToString:@"empty"]){
            return  LEGetHeightForCellWithObject(AYMeTableViewEmptyCell.class, object, nil);
        }
        else
        {
           return  LEGetHeightForCellWithObject(AYMeTableViewCell.class, object, nil);
        }
    }
    return 0;
}
