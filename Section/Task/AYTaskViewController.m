//
//  AYTaskViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/7.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYTaskViewController.h"
#import "AYSignInView.h" //签到视图
#import "LERotateScrollView.h" //轮播图
#import "AYBannerModel.h" //banner图
#import "AYTaskViewModel.h"
#import "AYTaskTableViewCell.h"
#import "AYADSkipManager.h" //banner跳转管理
#import "AYAdmobManager.h" //admob 广告管理
#import "AYTaskDayItem.h" //任务model
#import "AYRewardView.h"
#import "AYGuideManager.h"

@interface AYTaskViewController ()<LERotateScrollViewDataSource, LERotateScrollViewDelegate>
@property (nonatomic, readwrite, strong) AYTaskViewModel * viewModel; //数据处理
@property (nonatomic, strong) LERotateScrollView *lanterSlideView; //广告轮播
@property (nonatomic, strong) UIView *topView; //顶部view
@property (nonatomic, assign) AYAdmobAction videoAdmobAction; //视频加载进度
@property (nonatomic, assign) BOOL  taskCurrentLogin; //任务的当前登录状态
@property (nonatomic, strong) AYTaskSignInView *signView; //顶部view
@property (nonatomic, strong) AYGuideManager *guideManager; //顶部轮播

@end

@implementation AYTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configurateData];
    [self configurateTableView];
    [self loadBannerList];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self monitorAdvertiseLoadProgress];

    });
}
-(BOOL)shouldShowNavigationBar
{
     return NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  self.view.height = self.parentViewController.view.height-Height_TapBar;
    if ([AYUserManager isUserLogin]!=self.taskCurrentLogin )
    {
        self.tableView.tableHeaderView = nil;
        self.tableView.tableHeaderView = [self tableHeadView];
    }
    [self.viewModel updateTaskStatus];
    [self.tableView reloadData];
    UIView *tableHeadview = self.tableView.tableHeaderView;
    if (tableHeadview)
    {
        [tableHeadview.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = [UIColor clearColor];
        }];
    }
}
#pragma mark - Init
- (void) configurateData
{
    self.viewModel = [AYTaskViewModel viewModelWithViewController:self];
    if ([AYUserManager isUserLogin]) {
        [[AYGlobleConfig shared] updateTaskStatus:^{
            [self.viewModel updateTaskStatus];
            [self.tableView reloadData];
        } failure:^(NSString * _Nonnull errorString) {
            
        }];
    }
    [[AYAdmobManager shared] createGADRewardBasedVideoAd];
}

-(void)configureUI
{
    self.taskCurrentLogin =[AYUserManager isUserLogin];
    if(!self.topView)
    {
            self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, Height_TopBar)];
            [self.topView setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:self.topView];
            
            UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-Height_TapBar)];
            backImage.image = LEImage(@"task_backgound");
            backImage.contentMode = UIViewContentModeScaleToFill;
            [self.view addSubview:backImage];
            [self.view sendSubviewToBack:backImage];
            UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:18] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentCenter numberOfLines:1];
            titleLable.frame = CGRectMake(40, STATUS_BAR_HEIGHT, ScreenWidth-80, 44);
            [self.view addSubview:titleLable];
            [titleLable setBackgroundColor:[UIColor clearColor]];
            //[self.view bringSubviewToFront:self.topView];
            titleLable.text = AYLocalizedString(@"任务");
    }
    self.topView.alpha =0;
    [self.viewModel updateTaskStatus];
    [self.tableView reloadData];
    self.tableView.tableHeaderView = [self tableHeadView];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
}
- (void) configurateTableView
{
    self.tableView.showsVerticalScrollIndicator = NO;
    LERegisterCellForTable([AYTaskTableViewCell class], self.tableView);
   LERegisterCellForTable([AYTaskTableViewEmptyCell class], self.tableView);
    LEConfigurateCellBehaviorsFunctions([AYTaskTableViewCell class], @selector(fillCellWithModel: ),nil);

    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
-(void)configureGuide
{
    if(![AYGuideManager guideFinishWithViewType:AYGuideViewTypeTask])
    {
        if(self.tabBarController.selectedIndex!=2)
        {
            return;
        }
        AYGuideManager *guideManager= [[AYGuideManager alloc] init];
        _guideManager = guideManager;
        [_guideManager showGuideWithViewType:AYGuideViewTypeTask];
        self.view.userInteractionEnabled= NO;
        
        LEWeakSelf(self)
        _guideManager.guideFinish = ^{
            LEStrongSelf(self)
            self.view.userInteractionEnabled =YES;
        };
    }
}
#pragma mark - ui
-(UIView*)tableHeadView
{
    UIView *tableHeadView = self.tableView.tableHeaderView;
    if(!tableHeadView)
    {
        CGFloat signViewHeight =244+((SYSTEM_VERSION_GREATER_THAN(@"11"))?0:20);
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, signViewHeight)];
        [headView setBackgroundColor:[UIColor clearColor]];
        //签到视图
        AYTaskSignInView *signView = [[AYTaskSignInView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, signViewHeight) dayNum:2 compete:^{
            
        }];
        self.signView= signView;
        LEWeakSelf(self)
        self.signView.signDataLoadFinish = ^{
            LEStrongSelf(self)
            [self configureGuide];
        };
        [signView setBackgroundColor:[UIColor clearColor]];
        [headView addSubview:signView];
        tableHeadView = headView;
    }
    if ([_viewModel numberOfPageInRotateScrollView]>0) {
        CGFloat adverHeight = (85.0f/375.0f)*ScreenWidth;
        tableHeadView.height=self.signView.height+adverHeight;
        if (!_lanterSlideView)
        {
            LERotateScrollView * rotateView = [LERotateScrollView view];
            rotateView.dataSource = self;
            rotateView.delegate = self;
            _lanterSlideView = rotateView;
        }
        _lanterSlideView.frame = CGRectMake(0,self.signView.height, ScreenWidth, adverHeight);
        [tableHeadView addSubview:_lanterSlideView];
    }

    return tableHeadView;
}
-(void)gotoAnswerQuestion
{
    NSString *linkUrl = [NSString stringWithFormat:@"%@home/active/question",[AYUtitle getServerUrl]];
    if ([linkUrl containsString:@"?"] && [linkUrl containsString:@"&"]) {
        linkUrl =[NSString stringWithFormat:@"%@&users_id=%@&deviceType=ios",linkUrl,[AYUserManager userId]];
    }
    else
    {
        linkUrl =[NSString stringWithFormat:@"%@?users_id=%@&deviceType=ios",linkUrl,[AYUserManager userId]];
    }
    [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:linkUrl animate:YES];
}
-(void)monitorAdvertiseLoadProgress
{
        LEWeakSelf(self)
    [AYAdmobManager shared].admobActionBlock = ^(AYAdmobAction admobAction) {
        LEStrongSelf(self)
        self.videoAdmobAction = admobAction;
        NSIndexPath* indexpath = [self.viewModel indexPathForObject:@"task_adverse"];
        AYTaskDayItem *item = [self.viewModel objectForIndexPath:indexpath];
        if (admobAction == AYAdmobActionVideoAdvertiseLoadStart)
        {
            item.itemFinish = YES;
            item.advertiseLoading = YES;
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else if (admobAction == AYAdmobActionVideoAdvertiseLoadFinished)
        {
           if(![AYGlobleConfig shared].advertiseTaskFinished)
           {
               item.advertiseLoading = NO;

               item.itemFinish = NO;
               [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];

           }
        }
    };
}
#pragma mark - network -
-(void)loadBannerList
{
    [_viewModel getTaskBannerDataByAction:^{
        self.tableView.tableHeaderView = [self tableHeadView];
        [self.lanterSlideView reloadData];
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}
-(void)lookAdvertiseForRewardWithIndexPath:(NSIndexPath*)indexPath
{
    [[AYAdmobManager shared] showGADRewardBasedVideoAd:^(id  _Nonnull obj) {
        [ZWNetwork post:@"HTTP_Post_Advertise_Reward" parameters:nil success:^(id record) {
            if ([record isKindOfClass:NSDictionary.class])
            {
                if (record[@"remainder"])
                {
                    AYMeModel *meModel = [AYUserManager userItem];
                    meModel.coinNum = [record[@"remainder"] stringValue];
                    [AYUserManager save];
                }
                if (record[@"record_count"])
                {
                    NSInteger rewardCount =[record[@"record_count"] integerValue];
                     AYTaskDayItem *item = [self.viewModel objectForIndexPath:indexPath];
                    if (rewardCount==4)//观看视频次数用完
                    {
                        item.itemFinish = YES;
                        [AYGlobleConfig shared].advertiseTaskFinished = YES;
                        [AYRewardView showRewardViewWithTitle:AYLocalizedString(@"观看完成") coinStr:@"10" detail:[NSString stringWithFormat:AYLocalizedString(@"今日广告剩余次数：%d"),5-rewardCount] actionStr:AYLocalizedString(@"明日再来")];
                        item.itmeIntroduce = [NSString stringWithFormat:AYLocalizedString(@"今日剩余：%d"),5-rewardCount];
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    else
                    {
                    [AYRewardView showRewardViewWithTitle:AYLocalizedString(@"观看完成") coinStr:@"10" detail:[NSString stringWithFormat:AYLocalizedString(@"今日广告剩余次数：%d"),5-rewardCount] actionStr:AYLocalizedString(@"确定")];
                        item.itmeIntroduce = [NSString stringWithFormat:AYLocalizedString(@"今日剩余：%d"),5-rewardCount];
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }
            
        } failure:^(LEServiceError type, NSError *error) {
            occasionalHint([error localizedDescription]);
        }];
    } controller:self];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section ==0)
    {
        if ( indexPath.row ==1)
        {
            AYTaskTableViewEmptyCell* cell=   LEGetCellForTable([AYTaskTableViewEmptyCell class], tableView, indexPath);
            return cell;
        }
    }

    id object = [self.viewModel objectForIndexPath:indexPath];

    if (object) {
        AYTaskTableViewCell* cell=   LEGetCellForTable([AYTaskTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;

    }
    return nil;

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (section ==0)
    {
        if ([AYGlobleConfig shared].questionTaskFinished) {
            return nil;
        }
    }
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 53)];
    [headView setBackgroundColor:[UIColor whiteColor]];
    UILabel *titleLalbe  = [UILabel lableWithTextFont:[UIFont systemFontOfSize:17] textColor:UIColorFromRGB(0xff6666) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    titleLalbe.text = (section==0)?AYLocalizedString(@"新手任务"):AYLocalizedString(@"日常任务");
    titleLalbe.frame = CGRectMake(20, 10, ScreenWidth-40, headView.height-20);
    [headView addSubview:titleLalbe];
    UIView *underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [underLine setBackgroundColor:UIColorFromRGB(0xe7e7e7)];
    underLine.frame = CGRectMake(20, headView.height-0.8f, ScreenWidth-20, 0.5);
    [headView addSubview:underLine];
    return headView;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section ==0)
    {
        if ([AYGlobleConfig shared].questionTaskFinished) {
            return 0;
        }
        if (indexPath.row ==1)
        {
            CGFloat  cellHeight =LEGetHeightForCellWithObject(AYTaskTableViewEmptyCell.class, nil,nil);
            return cellHeight;
        }
    }

    id object = [self.viewModel objectForIndexPath:indexPath];

    CGFloat  cellHeight =LEGetHeightForCellWithObject(AYTaskTableViewCell.class, object,nil);
    return  cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        if ([AYGlobleConfig shared].questionTaskFinished) {
            return 0;
        }
    }
    return 53;
}
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section ==0)//问卷调查
    {
        if ([AYUserManager isUserLogin])
        {
            [self gotoAnswerQuestion];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [self gotoAnswerQuestion];
                
            }];
        }
        return;
    }
    if ([[_viewModel getIndexPathTitle:indexPath] isEqualToString:@"task_invite"]) //邀请
    {
        if ([AYUserManager isUserLogin])
        {
            [ZWREventsManager sendViewControllerEvent:kEventAYFriendSegmentViewController parameters:nil];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [ZWREventsManager sendViewControllerEvent:kEventAYFriendSegmentViewController parameters:nil];
            }];
        }
    }
    else if ([[_viewModel getIndexPathTitle:indexPath] isEqualToString:@"task_charge_friend"]) //好友充值
    {
        if ([AYUserManager isUserLogin])
        {
            [ZWREventsManager sendViewControllerEvent:kEventAYFriendChargeViewController parameters:@(YES) animate:YES];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [ZWREventsManager sendViewControllerEvent:kEventAYFriendChargeViewController parameters:@(YES) animate:YES];
            }];
        }
    }
    else if ([[_viewModel getIndexPathTitle:indexPath] isEqualToString:@"task_adverse"] ) //看广告领奖励
    {
        if ([AYGlobleConfig shared].advertiseTaskFinished ||(self.videoAdmobAction ==AYAdmobActionVideoAdvertiseLoadStart)) {
            return;
        }
        if ([AYUserManager isUserLogin])
        {
            [self lookAdvertiseForRewardWithIndexPath:indexPath];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [self lookAdvertiseForRewardWithIndexPath:indexPath];
            }];
        }
    }
    else if ([[_viewModel getIndexPathTitle:indexPath] isEqualToString:@"task_share"]) //每日分享
    {

        if ([AYUserManager isUserLogin])
        {
            [ZWREventsManager sendViewControllerEvent:kEventAYTaskShareViewController parameters:nil animate:YES];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [ZWREventsManager sendViewControllerEvent:kEventAYTaskShareViewController parameters:nil animate:YES];
            }];
        }
    }
    else if ([[_viewModel getIndexPathTitle:indexPath] isEqualToString:@"task_read"]) //每日阅读
    {
          UITabBarController *tab = [self tabBarController];
        if (tab) {
            [tab setSelectedIndex:0];
        }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y<30)
    {
        self.topView.alpha = 0;
    }
    else
    {
        self.topView.alpha =1-(120.0f-scrollView.contentOffset.y)/280.0f;
    }
}
#pragma mark - LERotateScrollViewDataSource
- (NSUInteger) numberOfPageInRotateScrollView : (LERotateScrollView *) rotateScrollView {
    return [_viewModel numberOfPageInRotateScrollView];
}

- (UIView *) rotateScrollView :(LERotateScrollView *) rotateScrollView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    AYBannerModel *fictionModle = [_viewModel objectForPage:index];
    if (!view) {
        UIImageView *imageView = [UIImageView new];
        imageView.frame = _lanterSlideView.bounds;
    LEImageSet(imageView,fictionModle.bannerImageUrl, @"task_test");
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        return imageView;
    }
    else
    {
    LEImageSet((UIImageView*)view, fictionModle.bannerImageUrl, @"task_test");
        return view;
    }
}
#pragma mark - LERotateScrollViewDelegate
- (void) leRotateScrollView : (LERotateScrollView *) rotateScrollView didClickPageAtIndex : (NSInteger) index {
    //
    AYBannerModel *bannerModle = [_viewModel objectForPage:index];
    [AYADSkipManager adSkipWithModel:bannerModle];
}

- (void) leRotateScrollView : (LERotateScrollView *) rotateScrollView didMovedToPageAtIndex : (NSInteger) index {
    //
}
#pragma mark - getter and setter -

@end
