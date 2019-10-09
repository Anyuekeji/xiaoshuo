//
//  AYSignInView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/5.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYSignInView.h"
#import "AYSignListModel.h"
#import "AYSignManager.h"
#import "AYRewardView.h"

@interface AYSubSignInView()
@property(nonatomic,strong)UIView *topContainView;
@property(nonatomic,strong)UIImageView *fiveStarImageView;
@property(nonatomic,strong)UILabel *coinNumLalbe;
@property(nonatomic,assign)NSInteger coinNum;
@property(nonatomic,assign)NSInteger dayNum;

@end

@implementation AYSubSignInView

-(instancetype)initWithFrame:(CGRect)frame  coinNum:(NSInteger)coinNum  dayNum:(NSInteger)dayNum
{
    self = [super initWithFrame:frame];
    if (self) {
        _coinNum = coinNum;
        _dayNum = dayNum;
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 5.0f;
    
    UIView *topContainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    topContainView.layer.cornerRadius = 16;
    [self addSubview:topContainView];
    _topContainView = topContainView;
    
    UIImageView *wuxinImageView = [UIImageView new];
    wuxinImageView.frame = CGRectMake(11, 5, 10, 10);
  //  wuxinImageView.image = LEImage(@"");
    [_topContainView addSubview:wuxinImageView];
    _fiveStarImageView = wuxinImageView;
    
    UILabel *numLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, _topContainView.bounds.size.width, 16)];
    numLable.textAlignment = NSTextAlignmentCenter;
    if(self.dayNum>=7)
    {
        numLable.text = [NSString stringWithFormat:@"%ld*2",(long)_coinNum];
        numLable.font= [UIFont systemFontOfSize:10];
    }
    else
    {
        numLable.text = [NSString stringWithFormat:@"%ld",(long)_coinNum];
        numLable.font= [UIFont systemFontOfSize:DEFAUT_SMALL_MORE_FONTSIZE];
    }
    [_topContainView addSubview:numLable];
    _coinNumLalbe = numLable;
    numLable.backgroundColor = [UIColor clearColor];
    
    UILabel *dayNumLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 32+6, _topContainView.bounds.size.width+3, 16)];
    dayNumLable.textAlignment = NSTextAlignmentCenter;
    dayNumLable.font= [UIFont systemFontOfSize:11];
    dayNumLable.textColor= UIColorFromRGB(0x999999);
    dayNumLable.text = [NSString stringWithFormat:@"%ld%@",(long)_dayNum,AYLocalizedString(@"天")];
    [self addSubview:dayNumLable];
    dayNumLable.backgroundColor = [UIColor clearColor];

}
-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected) {
        _topContainView.backgroundColor = RGB(250, 85, 108);
        _fiveStarImageView.image = LEImage(@"wujiaoxin_select");
        _coinNumLalbe.textColor = [UIColor whiteColor];
    }
    else
    {
        _topContainView.backgroundColor = [UIColor whiteColor];
        _topContainView.layer.borderColor = RGB(208, 208, 208).CGColor;
        _topContainView.layer.borderWidth = 1.0f;
           _fiveStarImageView.image = LEImage(@"wujiaoxin");
        _coinNumLalbe.textColor =RGB(208, 208, 208);
    }
}
@end

#import "MBProgressHUD.h"

@interface AYSignInView()
@property(nonatomic,strong)NSMutableArray<AYSignListModel*>  *listModel;
@property(nonatomic,assign)NSInteger  sevenDayRewardNum; //连续七天获得的奖励数
@property (nonatomic, copy) void (^completeBlock)(void);

@end
@implementation AYSignInView

-(instancetype)initWithFrame:(CGRect)frame  dayNum:(NSInteger)signDayNum compete:(void(^)(void)) completeBlock;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.listModel = [NSMutableArray new];
        self.completeBlock = completeBlock;
        [self loadSignList];
    }
    return self;
}
-(void)configureUI:(NSInteger)signDayNum list:(NSArray<AYSignListModel*>*)listSign signed:(BOOL)todaySigned
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    
    UILabel *signResultLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 36, self.bounds.size.width-20, 20)];
    signResultLable.textAlignment = NSTextAlignmentCenter;
    signResultLable.textColor = RGB(51, 51, 51);
    signResultLable.font = [UIFont boldSystemFontOfSize:17];
    signResultLable.text = AYLocalizedString(@"开始签到");
    [self addSubview:signResultLable];
    
    signResultLable = [[UILabel alloc] initWithFrame:CGRectMake(10, signResultLable.frame.origin.y+signResultLable.frame.size.height+15, self.bounds.size.width-20, 40)];
    signResultLable.textAlignment = NSTextAlignmentCenter;
    signResultLable.textColor = RGB(51, 51, 51);
    signResultLable.font = [UIFont systemFontOfSize:12];
    signResultLable.numberOfLines =0;
    [self setSignLableText:signResultLable :signDayNum];
    [self addSubview:signResultLable];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(44, signResultLable.frame.origin.y+signResultLable.frame.size.height+40, self.bounds.size.width-44*2, 4)];
    lineView.backgroundColor = RGB(208, 208, 208);
    [self addSubview:lineView];
    
    UIView *redlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, lineView.bounds.size.height)];
    redlineView.backgroundColor = RGB(250, 85, 108);
    [lineView addSubview:redlineView];
    
    CGFloat itemWidth = 32;
    CGFloat itemHeight  = 32+ 28;

    CGFloat originX = 12.0f;
    CGFloat dis_x = (self.bounds.size.width - 24 - 7*itemWidth)/6.0f;
    for (int i=1; i<=listSign.count; i++)
    {
        AYSignListModel *signModel = [listSign objectAtIndex:i-1];
        AYSubSignInView *signView = [[AYSubSignInView alloc] initWithFrame:CGRectMake(originX+(i-1)*(itemWidth+dis_x), 20, itemWidth, itemHeight) coinNum:[signModel.sign_icon integerValue] dayNum:i];
        signView.center = CGPointMake(signView.center.x, lineView.center.y+13);
        signView.tag  = 5525+i;
        if(i<=signDayNum)
        {
           signView.selected =YES;
        }
        else
        {
           signView.selected =NO;
        }
        [self addSubview:signView];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect rect = redlineView.frame;
        CGFloat redLineWidth =(signDayNum-1)*(dis_x)+signDayNum*itemWidth;
        rect.size.width = (redLineWidth<=(self.width-24-2*itemWidth))?redLineWidth:(self.width-24-2*itemWidth);
        redlineView.frame = rect;
    });
    
    CGFloat rewardViewWidth =210;
    
    UIView *getRewardView = [[UIView alloc] initWithFrame:CGRectMake((self.width-rewardViewWidth)/2.0f, lineView.center.y+itemHeight+5, rewardViewWidth,48)];
    getRewardView.layer.cornerRadius = 25;
    getRewardView.clipsToBounds = YES;
    getRewardView.backgroundColor =RGB(250,85,108);
    [self addSubview:getRewardView];
    
    UIImageView *wuxinImageView = [UIImageView new];
    wuxinImageView.frame = CGRectMake((getRewardView.width-40)/2.0f, 5, 16, 16);
    wuxinImageView.image = LEImage(@"wujiaoxin_select");
    [getRewardView addSubview:wuxinImageView];
    
    UILabel *rewardNumLable = [[UILabel alloc] initWithFrame:CGRectMake(wuxinImageView.right+2, wuxinImageView.top , 30, 16)];
    rewardNumLable.textAlignment = NSTextAlignmentLeft;
    rewardNumLable.textColor = [UIColor whiteColor];
    rewardNumLable.font = [UIFont boldSystemFontOfSize:16];
    rewardNumLable.text =todaySigned?@"":[self getRewardNumWithDays:signDayNum+1];
    [getRewardView addSubview:rewardNumLable];
    
    UILabel *rewardTipLable = [[UILabel alloc] initWithFrame:CGRectMake(10,rewardNumLable.bottom+5 , getRewardView.width-20, 15)];
    rewardTipLable.textAlignment = NSTextAlignmentCenter;
    rewardTipLable.textColor = [UIColor whiteColor];
    rewardTipLable.font = [UIFont boldSystemFontOfSize:13];
    if (todaySigned)
    {
        [self setSignedLableText:rewardTipLable :[[self getRewardNumWithDays:signDayNum] integerValue]];
        rewardNumLable.alpha =0;
        wuxinImageView.alpha =0;
        rewardTipLable.frame =CGRectMake(10,10, getRewardView.width-20, getRewardView.height-20);
        getRewardView.backgroundColor = RGB(244, 244, 244);
        rewardNumLable.font = [UIFont systemFontOfSize:16];
    }
    else
    {
        rewardTipLable.text =AYLocalizedString(@"点击领取奖励");
    }
    [getRewardView addSubview:rewardTipLable];
    LEWeakSelf(self)
    [getRewardView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        if (!todaySigned) {
            [self clickGetReward:signDayNum success:^{
                if (self.completeBlock) {
                    self.completeBlock();
                }
                [self setSignedLableText:rewardTipLable :[[self getRewardNumWithDays:signDayNum+1] integerValue]];
                rewardNumLable.alpha =0;
                wuxinImageView.alpha =0;
                rewardTipLable.frame =CGRectMake(10,10, ges.view.width-20, ges.view.height-20);
                ges.view.backgroundColor = RGB(244, 244, 244);
                rewardNumLable.font = [UIFont systemFontOfSize:16];
                
                AYSubSignInView *signView = [self viewWithTag:5525+signDayNum+1];
                signView.selected = YES;
                
                CGRect rect = redlineView.frame;
                CGFloat redLineWidth =signDayNum*(dis_x)+(signDayNum+1)*itemWidth;
                rect.size.width = (redLineWidth<=(self.width-24-2*itemWidth))?redLineWidth:(self.width-24-2*itemWidth);
                redlineView.frame = rect;
            }];
        }
    }];
}
-(void)setSignLableText:(UILabel*)pictureLabel :(NSInteger)signDayNum
{
    NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = [UIImage imageNamed:@"wujiaoxin_select"];
    backAttachment.bounds = CGRectMake(0, -2, 14, 14);
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:AYLocalizedString(@"连续签到七天，额外赠送%d金币"),(int)self.sevenDayRewardNum]];
    pictureLabel.font = [UIFont systemFontOfSize:15];
    pictureLabel.numberOfLines = 0;
    NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    
    [orginalAttributString appendAttributedString:newAttributString];
    pictureLabel.attributedText = orginalAttributString;
}

-(void)setSignedLableText:(UILabel*)signLabel :(NSInteger)signDayNum
{
    NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = [UIImage imageNamed:@"wujiaoxin_select"];
    backAttachment.bounds = CGRectMake(0, -2, 14, 14);
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:AYLocalizedString(@"已领取%d"),signDayNum]];
    signLabel.font = [UIFont systemFontOfSize:15];
    signLabel.numberOfLines = 0;
    signLabel.textColor = RGB(85, 194, 47);
    NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    [orginalAttributString appendAttributedString:newAttributString];
    signLabel.attributedText = orginalAttributString;
}
#pragma mark - private -
//获取连续点赞天数，获取的奖励金币数
-(NSString*)getRewardNumWithDays:(NSInteger)days
{
    if (self.listModel)
    {
        AYSignListModel *signModel = [self.listModel safe_objectAtIndex:days-1];
        if (signModel) {
           NSInteger day_num =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultUserSignDays];
            if(day_num ==6)//连续签到六天
            {
                return  [NSString stringWithFormat:@"%d",(int)[signModel.sign_icon integerValue]*2] ;

            }
            return signModel.sign_icon;
        }
    }
    return @"";
}
#pragma mark - db -
-(void)loadSignList
{
    NSArray* catcheArray =  [AYSignListModel r_allObjects];
    if (catcheArray && catcheArray.count>=7) {
        [self.listModel addObjectsFromArray:catcheArray];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        [[AYSignManager shared] loadAllData:^{
            [MBProgressHUD hideHUDForView:self animated:YES];

            [self loadSignList];
        } failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            [MBProgressHUD hideHUDForView:self animated:YES];

        }];
        return;
    }
     self.sevenDayRewardNum =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultServenDaySignReward];
     NSInteger day_num =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultUserSignDays];
     BOOL today_sign =  [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultUserTodaySign];
    
    [self configureUI:day_num list:self.listModel signed:today_sign];

}
//点击签到
-(void)clickGetReward:(NSInteger)dayNum success : (void(^)(void)) completeBlock
{
        NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
            [params addValue:[self getRewardNumWithDays:dayNum+1] forKey:@"sign_coin"]; //页数
        }];
    [ZWNetwork post:@"HTTP_Post_Sign_user" parameters:para success:^(id record)
     {
         
         
         occasionalHint(AYLocalizedString(@"签到成功"));
         //更新本地缓存
         NSInteger day_num =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultUserSignDays];
         [[NSUserDefaults standardUserDefaults] setInteger:day_num+1 forKey:kUserDefaultUserSignDays];
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultUserTodaySign];
         [[NSUserDefaults standardUserDefaults] synchronize];
         if (record && [record isKindOfClass:NSDictionary.class]) {
             AYMeModel *meModel = [AYUserManager userItem];
             meModel.coinNum = [record[@"remainder"] stringValue];
             [AYUserManager save];
         }

         if (completeBlock) {
             completeBlock();
         }
     } failure:^(LEServiceError type, NSError *error) {
         occasionalHint([error localizedDescription]);
     }];
}
@end


@interface AYTaskSignInView()
@property(nonatomic,strong)NSMutableArray<AYSignListModel*>  *listModel;
@property(nonatomic,assign)NSInteger  sevenDayRewardNum; //连续七天获得的奖励数
@property(nonatomic,assign)NSInteger  continueSignDayNum; //连续签到的天数
@property(nonatomic,strong)UIView  *redLineView; //红线

@property (nonatomic, copy) void (^completeBlock)(void);
@end
@implementation AYTaskSignInView

-(instancetype)initWithFrame:(CGRect)frame  dayNum:(NSInteger)signDayNum compete:(void(^)(void)) completeBlock;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.listModel = [NSMutableArray new];
        self.completeBlock = completeBlock;
        [self loadSignList];
    }
    return self;
}
#pragma mark - ui -

-(void)configureUI:(NSInteger)signDayNum list:(NSArray<AYSignListModel*>*)listSign signed:(BOOL)todaySigned
{
    self.continueSignDayNum = signDayNum;
    CGFloat itemWidth = 32;
    CGFloat itemHeight  = 32+ 28;
    
    CGFloat originX = 27.0f;
    CGFloat dis_x = (self.bounds.size.width - 54 - 7*itemWidth)/6.0f;
    
    self.backgroundColor = [UIColor clearColor];
    
    UIButton *signBtn = [self addsignBtn:dis_x itemWidth:itemWidth todaySign:todaySigned];//创建签到按钮
   
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(59, signBtn.top+signBtn.height+26+10, self.bounds.size.width-59*2, 4)];
    lineView.tag = SIGN_LINEVIEW_TAG;
    lineView.backgroundColor = RGB(208, 208, 208);
    [self addSubview:lineView];
    
    UIView *redlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, lineView.bounds.size.height)];
    redlineView.backgroundColor = RGB(250, 85, 108);
    [lineView addSubview:redlineView];
    self.redLineView = redlineView;
    
    for (int i=1; i<=listSign.count; i++)
    {
        AYSignListModel *signModel = [listSign objectAtIndex:i-1];
        AYSubSignInView *signView = [[AYSubSignInView alloc] initWithFrame:CGRectMake(originX+(i-1)*(itemWidth+dis_x), 20, itemWidth, itemHeight) coinNum:[signModel.sign_icon integerValue] dayNum:i];
        signView.center = CGPointMake(signView.center.x, lineView.center.y+13);
        signView.tag  = 5525+i;
        if(i<=signDayNum)
        {
            signView.selected =YES;
        }
        else
        {
            signView.selected =NO;
        }
        [self addSubview:signView];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect rect = redlineView.frame;
        CGFloat redLineWidth =(signDayNum-1)*(dis_x)+signDayNum*itemWidth;
        rect.size.width = (redLineWidth<=(self.width-originX*2-2*itemWidth))?redLineWidth:(self.width-originX*2-2*itemWidth);
        redlineView.frame = rect;
    });
    UILabel *signResultLable = [[UILabel alloc] initWithFrame:CGRectMake(30, lineView.top+lineView.height+16+16, self.bounds.size.width-60, 40)];
    signResultLable.textAlignment = NSTextAlignmentCenter;
    signResultLable.textColor = UIColorFromRGB(0x999999);
    signResultLable.font = [UIFont systemFontOfSize:12];
    signResultLable.numberOfLines =0;
    signResultLable.text = AYLocalizedString(@"连续签到七天奖励翻倍");
    [self addCoinImageToLable:signResultLable];
    [self addSubview:signResultLable];
}
-(UIButton*)addsignBtn:(CGFloat)dis_x  itemWidth:(CGFloat)itemWidth todaySign:(BOOL)todaySign
{
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (IS_LOCAL_COUNTRY) {
        [signInBtn setBackgroundImage:todaySign?LEImage(@"task_signed"):LEImage(@"task_sign") forState:UIControlStateNormal];

    }
    else
    {
        [signInBtn setBackgroundImage:todaySign?LEImage(@"task_signed_id"):LEImage(@"task_sign_id") forState:UIControlStateNormal];

    }
    CGFloat btnWidth = 74.0f;
    signInBtn.frame = CGRectMake((ScreenWidth-btnWidth)/2.0f, (SYSTEM_VERSION_GREATER_THAN(@"11"))?55:75, btnWidth, btnWidth);
    [signInBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    signInBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    signInBtn.titleLabel.numberOfLines = 0;
    signInBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[signInBtn setTitle:AYLocalizedString(@"签到") forState:UIControlStateNormal];
    [self addSubview:signInBtn];
    LEWeakSelf(self)
    __weak typeof(UIButton*) weakSignInBtn = signInBtn;
    [signInBtn addAction:^(UIButton *btn)
    {
        if (todaySign) {
            return;
        }
        LEStrongSelf(self)
        if (![AYUserManager isUserLogin])
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                LEStrongSelf(self)
                [[AYSignManager shared] loadAllData:^{
                    __strong typeof(UIButton*) strongSignInBtn = weakSignInBtn;
                    [self startSignWithBtn:strongSignInBtn lineView:self.redLineView dis:dis_x itemWidth:itemWidth];
                    
                } failure:^(NSString * _Nonnull errorString) {
                    
                }];
            }];
        }
        else
        {
            __strong typeof(UIButton*) strongSignInBtn = weakSignInBtn;
            [self startSignWithBtn:strongSignInBtn lineView:self.redLineView dis:dis_x itemWidth:itemWidth];

        }
    }];
    return signInBtn;
}
#pragma mark - private -
-(void)addCoinImageToLable:(UILabel*)coinLable
{
    NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = [UIImage imageNamed:@"wujiaoxin_select"];
    backAttachment.bounds = CGRectMake(0, -2, 14, 14);
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:coinLable.text];
    NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    [orginalAttributString appendAttributedString:newAttributString];
    coinLable.attributedText = orginalAttributString;
}
//获取连续点赞天数，获取的奖励金币数
-(NSString*)getRewardNumWithDays:(NSInteger)days
{
    if (self.listModel) {
        AYSignListModel *signModel = [self.listModel safe_objectAtIndex:days-1];
        if (signModel) {
            NSInteger day_num =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultUserSignDays];
            if(day_num ==6)//连续签到六天
            {
                return  [NSString stringWithFormat:@"%d",(int)[signModel.sign_icon integerValue]+100] ;
                
            }
            return signModel.sign_icon;
        }
    }
    return @"";
}
-(void)startSignWithBtn:(UIButton*)signBtn  lineView:(UIView*)redlineView  dis:(CGFloat)dis_x  itemWidth:(CGFloat)itemWidth
{
    
    [self clickGetReward:self.continueSignDayNum success:^{
        if (self.completeBlock)
        {
            self.completeBlock();
        }
      //  occasionalHint(AYLocalizedString(@"签到成功"));
        [signBtn setBackgroundImage:LEImage(@"task_signed") forState:UIControlStateNormal];
        AYSubSignInView *signView = [self viewWithTag:5525+self.continueSignDayNum+1];
        signView.selected = YES;
        CGRect rect = redlineView.frame;
        CGFloat redLineWidth =self.continueSignDayNum*(dis_x)+(self.continueSignDayNum+1)*itemWidth;
        rect.size.width = (redLineWidth<=(self.width-24-2*itemWidth))?redLineWidth:(self.width-24-2*itemWidth);
        redlineView.frame = rect;
    }];
}
#pragma mark - db -
-(void)loadSignList
{
    NSArray* catcheArray =  [AYSignListModel r_allObjects];
    if (catcheArray && catcheArray.count>=7) {
        [self.listModel addObjectsFromArray:catcheArray];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        [[AYSignManager shared] loadAllData:^{
            [MBProgressHUD hideHUDForView:self animated:YES];
            
            [self loadSignList];
        } failure:^(NSString * _Nonnull errorString) {
            occasionalHint(errorString);
            [MBProgressHUD hideHUDForView:self animated:YES];
            
        }];
        return;
    }
    if (self.signDataLoadFinish) {
        self.signDataLoadFinish();
    }
    
    self.sevenDayRewardNum =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultServenDaySignReward];
    NSInteger day_num = [AYUserManager isUserLogin]?[[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultUserSignDays]:0;
    BOOL today_sign =[AYUserManager isUserLogin]?[[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultUserTodaySign]:NO;
    [self configureUI:day_num list:self.listModel signed:today_sign];
}
//点击签到
-(void)clickGetReward:(NSInteger)dayNum success : (void(^)(void)) completeBlock
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:[self getRewardNumWithDays:dayNum+1] forKey:@"sign_coin"]; //页数
    }];
    [ZWNetwork post:@"HTTP_Post_Sign_user" parameters:para success:^(id record)
     {
         NSString *detailStr;
         NSString *coinStr;

         if ((dayNum+1)==7)
         {
             detailStr = [NSString stringWithFormat:@"%@",AYLocalizedString(@"连续签到七天奖励翻倍")];
             AYSignListModel *signModel = [self.listModel safe_objectAtIndex:dayNum];
             coinStr = [NSString stringWithFormat:@"%@*2",signModel.sign_icon];
         }
         else
         {
             detailStr = [NSString stringWithFormat:@"%@%@",AYLocalizedString(@"明日还可领取"),[self getRewardNumWithDays:(dayNum+2)]];
             coinStr = [self getRewardNumWithDays:(dayNum+1)];

         }
         [AYRewardView showRewardViewWithTitle:AYLocalizedString(@"签到成功") coinStr:coinStr detail:detailStr actionStr:AYLocalizedString(@"明日再来")];         //更新本地缓存
         NSInteger day_num =  [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultUserSignDays];
         [[NSUserDefaults standardUserDefaults] setInteger:day_num+1 forKey:kUserDefaultUserSignDays];
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultUserTodaySign];
         [[NSUserDefaults standardUserDefaults] synchronize];
         if (record && [record isKindOfClass:NSDictionary.class]) {
             AYMeModel *meModel = [AYUserManager userItem];
             meModel.coinNum=[record[@"remainder"] stringValue];
             [AYUserManager save];
         }
         
         if (completeBlock) {
             completeBlock();
         }
     } failure:^(LEServiceError type, NSError *error) {
         occasionalHint([error localizedDescription]);
     }];
}
//-(void)updateSignView
//{
//    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj removeFromSuperview];
//    }];
//    [[AYSignManager shared] loadAllData:^{
//        [self loadSignList];
//    } failure:^(NSString * _Nonnull errorString) {
//        occasionalHint(errorString);
//    }];
//}
@end

@implementation AYSignInContainView

-(instancetype)initWithFrame:(CGRect)frame  dayNum:(NSInteger)signDayNum compete:(void(^)(void)) completeBlock;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        AYSignInView *signInView = [[AYSignInView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 225+60) dayNum:signDayNum compete:completeBlock];
        [self addSubview:signInView];
        signInView.backgroundColor = [UIColor whiteColor];
        [signInView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            
        }];

        UIImageView *deleteSignView = [[UIImageView alloc] initWithImage:LEImage(@"delete")];
        deleteSignView.frame = CGRectMake((self.frame.size.width-31)/2,signInView.frame.origin.y+signInView.bounds.size.height, 31, 73);
        [self addSubview:deleteSignView];
        deleteSignView.userInteractionEnabled =NO;
        
    }
    return self;
}
+(void)showSignViewInView:(UIView*)parentView  frame:(CGRect)frame dayNum:(NSInteger)signDayNum bottom:(BOOL)isFromBottom compete:(void(^)(void)) completeBlock;
{
    UIView *maskView = [[UIView alloc] initWithFrame:parentView.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [parentView addSubview:maskView];
    
    AYSignInContainView *containView = [[AYSignInContainView alloc] initWithFrame:frame dayNum:signDayNum compete:completeBlock];
    [parentView addSubview:containView];
    containView.alpha =0.3f;
    containView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    if (isFromBottom) {
        containView.layer.anchorPoint = CGPointMake(1, 1);
        
        [UIView animateWithDuration:0.2f animations:^{
            containView.alpha =1;
            maskView.alpha = 0.5f;
            containView.transform = CGAffineTransformMakeScale(1, 1);
            containView.center = CGPointMake(parentView.center.x+containView.bounds.size.width/2, (ScreenHeight-64-44-containView.bounds.size.height)/2+containView.bounds.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            containView.alpha =1;
            maskView.alpha = 0.5f;
            containView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
    LEWeakSelf(maskView)
    [containView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(maskView)
        [UIView animateWithDuration:0.5f animations:^{
            maskView.alpha =0;
            ges.view.alpha = 0;
            ges.view.transform = CGAffineTransformMakeScale(0, 0);
            ges.view.center = CGPointMake(ScreenWidth, containView.frame.origin.y+containView.bounds.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
                [ges.view removeFromSuperview];
                [maskView removeFromSuperview];
            }
        }];
    }];
    [maskView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        [UIView animateWithDuration:0.5f animations:^{
            containView.alpha =0;
            ges.view.alpha = 0;
            containView.transform = CGAffineTransformMakeScale(0, 0);
            containView.center = CGPointMake(ScreenWidth, containView.frame.origin.y+containView.bounds.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
                [ges.view removeFromSuperview];
                [containView removeFromSuperview];
            }
        }];
    }];
}

@end
