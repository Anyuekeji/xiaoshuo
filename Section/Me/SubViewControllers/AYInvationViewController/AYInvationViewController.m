//
//  AYInvationViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/22.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYInvationViewController.h"
#import "LEItemView.h" //上面图片下面名字的视图
#import "AYShareView.h" //分享模块
#import "ZWDeviceSupport.h"

@interface AYInvationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLable;
@property (weak, nonatomic) IBOutlet UILabel *rewardRulesLable;
@property (weak, nonatomic) IBOutlet UILabel *f_ruleLable;
@property (weak, nonatomic) IBOutlet UILabel *s_ruleLable;

@property (weak, nonatomic) IBOutlet UILabel *invateRulesLable;
@property (weak, nonatomic) IBOutlet UILabel *f_invateLable;
@property (weak, nonatomic) IBOutlet UILabel *s_invateLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstain;

@property (copy, nonatomic)  NSString *loginRewardNum;
@property (copy, nonatomic)  NSString *chargeRewardNum;
@property (strong, nonatomic)  AYShareView *shareView;
@end

@implementation AYInvationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureData];
    [self loadRewardRuleData];
    // Do any additional setup after loading the view from its nib.
}

-(BOOL)shouldShowNavigationBar
{
    return YES;
}
-(void)configureUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.loginRewardNum = @"500";
    self.chargeRewardNum = @"10%";
    
    CGFloat itemHeight =100;
    CGFloat itemWidth = ScreenWidth/3.0f;
    
    NSArray *itemArray = @[@"Facebook",@"Line",AYLocalizedString(@"Copy Link")];
    NSArray *itemImageArray = @[@"login_facebook",@"login_line",@"login_copylink"];
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LEItemView *itemView = [[LEItemView alloc] initWithTitle:obj icon:itemImageArray[idx] isBigMode:YES numInOneLine:3];
        itemView.frame = CGRectMake((idx%3)*itemWidth,70+idx/3*(itemHeight), itemWidth, itemHeight);
        itemView.tag = 56898+idx;
        [self.view addSubview:itemView];
        
        LEWeakSelf(self)
        [itemView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            LEStrongSelf(self)
            UIView *tempView = ges.view;
            NSInteger viewTag = tempView.tag-56898;
            switch (viewTag) {
                case 0:
                {
                    [self startInvateWithType:AYSharePlatformTypeFacebook];
                }
                    break;
                case 1:
                {
                    [self startInvateWithType:AYSharePlatformTypeLine];
                }
                    break;
         
                case 2 :
                {
                    [self startInvateWithType:AYSharePlatformTypeCopyLink];
                }
                    break;
                default:
                    break;
            }
        
        }];
    }];
    
    CGFloat bottomDis = (ScreenHeight - Height_TopBar-188- 2*itemHeight-50)/2.0f;
    _bottomViewConstain.constant = bottomDis;
    

}
-(void)configureData
{
    _titleLable.text = AYLocalizedString(@"通过以下方式分享");
    _subTitleLable.text = AYLocalizedString(@"邀请好友让您拿更多金币");
    _rewardRulesLable.text = AYLocalizedString(@"奖励规则");
    _f_ruleLable.text = AYLocalizedString(@"1. 每邀请一个好友奖励%@");
    _s_ruleLable.text = AYLocalizedString(@"2. 好友每次充值，奖励*10%");
    _invateRulesLable.text = AYLocalizedString(@"邀请规则");
    _f_invateLable.text = AYLocalizedString(@"1. 一个手机用户只能被邀请一次");
    _s_invateLable.text = AYLocalizedString(@"2. 被邀请的人安装后输入邀请码再登陆才算邀请成功");
    _s_invateLable.textColor = RGB(51, 51, 51);
    _s_invateLable.font = [UIFont systemFontOfSize:14];
    
    _f_invateLable.textColor = RGB(51, 51, 51);
    _f_invateLable.font = [UIFont systemFontOfSize:14];
    
    _f_ruleLable.textColor = RGB(51, 51, 51);
    _f_ruleLable.font = [UIFont systemFontOfSize:14];
    
    _s_ruleLable.textColor = RGB(51, 51, 51);
    _s_ruleLable.font = [UIFont systemFontOfSize:14];
    
    NSTextAttachment *backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = [UIImage imageNamed:@"wujiaoxin_select"];
    backAttachment.bounds = CGRectMake(0, -2, 14, 14);
    NSMutableAttributedString *orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSMutableAttributedString *newAttributString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:AYLocalizedString(@"1. 每邀请一个好友奖励%@"),self.loginRewardNum]];
    _f_ruleLable.numberOfLines = 0;
    NSAttributedString *secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    
    [orginalAttributString appendAttributedString:newAttributString];
    _f_ruleLable.attributedText = orginalAttributString;
    
    backAttachment = [[NSTextAttachment alloc]init];
    backAttachment.image = [UIImage imageNamed:@"wujiaoxin_select"];
    backAttachment.bounds = CGRectMake(0, -2, 14, 14);
    orginalAttributString = [[NSMutableAttributedString alloc]initWithString:@""];
    newAttributString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:AYLocalizedString(@"2. 好友每次充值，奖励充值金币的%@"),self.chargeRewardNum]];
    _s_ruleLable.numberOfLines = 0;
    secondString = [NSAttributedString attributedStringWithAttachment:backAttachment];
    [newAttributString appendAttributedString:secondString];
    
    [orginalAttributString appendAttributedString:newAttributString];
    _s_ruleLable.attributedText = orginalAttributString;
    
    self.shareView = [AYShareView new];
    self.shareView.shareParas = [self configureInvateParams];
    self.shareView.shareParentViewController = self;
}
-(NSMutableDictionary*)configureInvateParams
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams setObject:[AYUtitle getAppName] forKey:@"title"];
    //[shareParams setObject:@"https://api.metinhtruyen.com/static/down/imgs/logo.png" forKey:@"image"];
  //  [shareParams setObject:AYLocalizedString(@"最火APP， 海量小说、爆款漫画，随心畅读，给你带来醉爱的阅读体验！") forKey:@"desc"];
    NSString *shareUrl = [NSString stringWithFormat:@"%@home/down/invite?uid=%@&deviceToken=%@&device=%@",[AYUtitle getServerUrl],([AYUserManager isUserLogin]?[AYUserManager userId]:@""),[AYUtitle getDeviceUniqueId],@"iphone"];
    [shareParams setObject:shareUrl forKey:@"link"];
    return shareParams;
}
#pragma mark - private -
-(void)startInvateWithType:(AYSharePlatformType)type
{
    [self.shareView shareToPlatforWithType:type];
}
#pragma mark - network -
-(void)loadRewardRuleData
{
    self.loginRewardNum  = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultInvitaLoginReward];
    if (!self.loginRewardNum || ![self.loginRewardNum isValid]) {
        self.loginRewardNum = @"500";
    }
    self.chargeRewardNum  = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultInvitaChargeReward];
    if (!self.chargeRewardNum || ![self.chargeRewardNum isValid]) {
        self.chargeRewardNum = @"10%";
    }
    [self configureData];
}
#pragma mark - ZWR2SegmentViewControllerProtocol -
+ (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewControllerWithSegmentRegisterItem : (id) object segmentItem : (ZWR2SegmentItem *) segmentItem {
    return [self controller];
}
#pragma mark - ZWRChainReactionProtocol
/**当前选中状态又重新选择了这个tabbar，联动效应事件 */
- (void) zwrChainReactionEventTabBarDidReClickAfterAppear {
}

#pragma mark - ZWRSegmentReuseProtocol
- (void) segmentRecivedMemoryWarning {
    
}
- (void) segmentViewWillAppear {
    
}
- (void) segmentViewWillDisappear {
    
}
/**
 *  当进入显示栏位的时候将会调用此方法，可实现相关逻辑
 */
- (void) segmentDidLoadViewController
{
}
- (NSString *) uniqueIdentifier {
    return @"1";
}
- (NSString *) segmentTitle {
    return AYLocalizedString(@"邀请好友");
}

@end
