//
//  AYFuctionReadViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//
#import "AYFuctionReadViewController.h"
#import "AYReadTopView.h" //头视图
#import "AYReadBottomView.h" //底部视图
#import "AYShareView.h" //分享视图
#import "CYReadMenuView.h" //目录视图
#import "CYFictionChapterModel.h"
#import "AYReadAppearanceSetView.h"//阅读器外观设置
#import "AYReadContentView.h" //显示内容视图
#import "AYChargeView.h" //解锁和充值视图
#import "NSTimer+YYAdd.h"
#import "AYFictionReadViewModel.h" //小说数据处理
#import "AYFictionReadContentViewController.h" //内容显示
#import "AYReadBackgroundViewController.h" //翻页背景颜色视图
#import "AYFictionModel.h" //
#import "AYFictionReadModel.h" //存储当前小说阅读状态
#import "AYBookModel.h" //书本model
#import "AYShareManager.h" //分享管理
#import "UIGestureRecognizer+YYAdd.h"
#import "AYChargeSelectView.h"
#import "AYBookRackManager.h"
#import "AYAdmobManager.h"
#import "AYReadStatisticsManager.h"
#import "AYReadAleartVIew.h"

@interface AYFuctionReadViewController ()<AYReadTopViewDelegate,AYReadBottomViewDelegate,AYReadAppearanceSetViewDelegate,UIPageViewControllerDelegate, UIPageViewControllerDataSource,UIGestureRecognizerDelegate,AYFictionReadViewModelDelegate>

@property(nonatomic, strong) AYReadTopView *topView;
@property(nonatomic, strong) AYReadBottomView *bottomView;
@property(nonatomic, assign) BOOL editState; //编辑状态
@property(nonatomic, assign) BOOL animatinoFinished; //动画是否结束
@property (nonatomic, strong) UIPageViewController *pageViewController; //分页视图
@property (nonatomic, strong) id snapObj; //截屏通知对象

@property(nonatomic, strong) AYFictionReadViewModel *viewModel;
@property(nonatomic, strong) AYFictionReadContentViewController *currentContentViewController; //
@property(nonatomic, strong) AYFictionReadContentViewController *beforeContentViewController; //
@property(nonatomic, strong) AYFictionReadContentViewController *afterContentViewController; //
@property(nonatomic, strong) AYFictionReadContentViewController *oldContentViewController; //上一页的对象 用于广告跳转
@property(nonatomic, strong) AYFictionReadContentTopview *contentTopview; //上下滚动模式topview
@property(nonatomic, strong) AYFictionReadContentBottomview *contentBottomview; //上下滚动模式bottomview

@property(nonatomic, assign) BOOL old_dir; //上一页方向 yes -> next no -> before
@property (nonatomic, strong) AYFictionModel *fictionModel; //分页视图
@property (nonatomic, assign) BOOL animationSwitchFinished; //防止短时间内切换多章
@property (nonatomic, assign) BOOL nextSwitchFinished;
@property (nonatomic, assign) AYFictionReadTurnPageType turnPageType;//小说翻页方式

@property (nonatomic, assign) NSInteger adIndex;//广告的索引
@property (nonatomic, assign) NSInteger start;//上一次显示广告的索引
@end

@implementation AYFuctionReadViewController
-(instancetype)initWithPara:(id)para
{
    self = [super init];
    if (self) {
        if ([para isKindOfClass:AYFictionModel.class]) {
            self.fictionModel = para;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureData];
    [self configureUI];
    [self configureNotification];
    
    
    //用于每日阅读30分钟获取50金币 统计阅读时间
    [[AYReadStatisticsManager shared] enterReadController];
    //用于免费广告阅读，每天只有10章的机会
    [[AYReadStatisticsManager shared] localBookFreeReadStatiticsTimeAviable:^{
        //免费小说缓存是否有效
    }];
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
-(void)hideOrShowStatusBar
{
    if(_ZWIsIPhoneXSeries() || _editState)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
    }else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.snapObj];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AYUtitle addAppReview];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_ZWIsIPhoneXSeries())
    {
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark - configure  -
-(void)configureUI
{
    [self setReadTurnPageType];//默认仿真
    LEWeakSelf(self)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        LEStrongSelf(self)
        CGPoint point = [sender locationInView:self.view];
        if(point.x < ScreenWidth * 0.3 || point.x > ScreenWidth * 0.7 || point.y <ScreenHeight * 0.01f || point.y > ScreenHeight * 0.99f)
        {//水平滚动模式实现点击翻页
            if((point.x < ScreenWidth * 0.3) && self.turnPageType != AYTurnPageCurl)//上翻页
            {
                [self turnPageWithClick:NO];
            }
            else if((point.x > ScreenWidth * 0.7 ) && self.turnPageType != AYTurnPageCurl)//下翻页
            {
                [self turnPageWithClick:YES];
            }
            return;
        }
        self.editState = !self.editState;
    }];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    self.view.backgroundColor = [AYUtitle getReadBackgroundColor];
    [self initPageViewController];
    [self.view addSubview:[self topView]];
    [self.view addSubview:[self bottomView]];
}
-(void)configureData
{
    self.adIndex = 0; //广告模式下，广告索引
    self.editState = NO;
    _animatinoFinished = YES;
    _viewModel = [AYFictionReadViewModel viewModelWithViewController:self];
    _viewModel.bookId = _fictionModel.fictionID;
    _viewModel.delegate = self;
    [self loadFictionData];
    //上传人气值
    [AYBookRackManager sendBookHot:self.fictionModel.fictionID type:1];
    LEWeakSelf(self)
    [AYAdmobManager shared].admobActionBlock = ^(AYAdmobAction admobAction)//广告页点击了不想看广告
    {
        LEStrongSelf(self)
        if (admobAction == AYAdmobActionDoNotLookAdvertise) {
            [self switchUnlockModeInAdverttiseModeIReadTopView:nil unlockMode:NO];
        }
    };
    


}
-(void)configureNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePageGestureEvent:) name:kNotificationEnableOrDisablePageGestureEvents object:nil];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];

    self.snapObj= [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        AYLog(@"SNOT");
        UILabel *snatshopAlert = [[UILabel alloc] initWithFrame:CGRectMake(30, (ScreenHeight-200)/2.0f, ScreenWidth-60, 200)];
        snatshopAlert.text = AYLocalizedString(@"禁止截屏\n您已触发app防御机制，请重启app才能继续使用");
        snatshopAlert.textColor = RGB(205, 85, 108);
        snatshopAlert.textAlignment = NSTextAlignmentCenter;
        snatshopAlert.layer.cornerRadius = 8.0f;
        snatshopAlert.clipsToBounds = YES;
        snatshopAlert.backgroundColor = [UIColor whiteColor];
        snatshopAlert.numberOfLines = 0;
        snatshopAlert.font = [UIFont systemFontOfSize:DEFAUT_BIG_FONTSIZE];
        UIView *parentView = [AYUtitle getAppDelegate].window;
        UIView *shaodowView = [[UIView alloc] initWithFrame:parentView.bounds];
        [shaodowView setBackgroundColor:[UIColor blackColor]];
        shaodowView.alpha=0.6f;
        [parentView addSubview:shaodowView];
        [parentView addSubview:snatshopAlert];
    
    }];
}
- (void)initPageViewController{
    CGRect preFrame = CGRectZero;
    if (_pageViewController) {
        preFrame =_pageViewController.view.frame;
        [_pageViewController removeFromParentViewController];
        [_pageViewController.view removeFromSuperview];
        _pageViewController = nil;
    }
    if (_contentBottomview) {
        [_contentBottomview removeFromSuperview];
        _contentBottomview = nil;
    }
    if (_contentTopview) {
        [_contentTopview removeFromSuperview];
        _contentTopview = nil;
    }
    [self addChildViewController:self.pageViewController];
    if (self.turnPageType == AYTurnPageUpdown) {
 
            self.pageViewController.view.frame =CGRectMake(0, (self.contentTopview.height+self.contentTopview.top)+5, ScreenWidth, [AYUtitle getReadContentSize].height+10);
        [self.view addSubview:self.contentTopview];
        [self.view addSubview:self.pageViewController.view];
        [self.view addSubview:self.contentBottomview];
    }
    else
    {
        self.pageViewController.view.frame =CGRectMake(0, (_ZWIsIPhoneXSeries()?STATUS_BAR_HEIGHT:0), ScreenWidth, ScreenHeight-(_ZWIsIPhoneXSeries()?(STATUS_BAR_HEIGHT):0));
        [self.view addSubview:self.pageViewController.view];
    }
}
#pragma mark - event handle -

-(void)handlePageGestureEvent:(NSNotification*)notify
{
    NSNumber *num = (NSNumber*)notify.object;
    if (num && [num isKindOfClass:NSNumber.class]) {
        [self.pageViewController.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.enabled = [num boolValue];
        }];
    }
}
#pragma mark - gesture -
//防止跟 点击冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {//判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }//否则手势存在
    else
    {
        UIView *touView = touch.view;
        UIView *parView = touView.superview;
        while (parView) {
            if([parView isKindOfClass:AYChargeSelectContainView.class])//相应菜单点击事件
            {
                return NO;
            }
            parView = parView.superview;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    return NO;

}
#pragma mark - network  -
-(void)loadFictionData
{
    [self showHUD];
    [_viewModel startLoadFiction:self.fictionModel.startChatperIndex];
}
#pragma mark - AYFictionReadViewModelDelegate -
- (void)dataSourceDidFinish
{
    [self hideHUD];
    self.adIndex =0;
    [self showPage:_viewModel.currentPageIndex chapter:self.viewModel.currentChapterIndex];
    [self openOrCloseBackGesture:[self.viewModel currentPageIndex]];
}
#pragma mark - AYReadTopViewDelegate -
//返回
-(void)backInReadTopView:(AYReadTopView *)topView
{
    [[AYReadStatisticsManager shared] leaveReadController:YES];

    if(self.updateBookOpenCover)
    {
        self.updateBookOpenCover();
    }
    [self.viewModel saveFictionReadModel];
    if (![AYBookRackManager bookInBookRack:self.fictionModel.fictionID]) {
        [self creatAddAlertController];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

}
//分享
-(void)shareInReadTopView:(AYReadTopView *)topView
{
    [AYShareManager ShareFictionWith:self.fictionModel parentView:self.view];
}
-(void)switchUnlockModeInAdverttiseModeIReadTopView:(AYReadTopView *)topView unlockMode:(BOOL)unlockAdvertise
{
    [AYReadAleartVIew shareReadAleartViewWithTitle:(unlockAdvertise?AYLocalizedString(@"不想付费购买，您可以"):AYLocalizedString(@"不想看广告，您可以")) okActionTitle:(unlockAdvertise?AYLocalizedString(@"从下一章开始看广告阅读"):AYLocalizedString(@"从下一章开始付费阅读")) okCancle:YES cancleActionTitle:AYLocalizedString(@"看广告取消") parentView:nil okBlock:^(bool ok){
        if (!ok) {
            return;
        }
        if(!topView ) //广告 上的点击
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultFreeBookCoinUnlock];
        }
        else //topview上的点击
        {
            BOOL advertise =[[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFreeBookCoinUnlock];
            if(advertise)//切换成广告前判断每天机会次数是否用完
            {
                if ([[AYReadStatisticsManager shared] advertiseReadDayCountFinished])
                {
                    NSString *errorStr = [NSString stringWithFormat:AYLocalizedString(@"每天可免费阅读%d个章节 继续阅读需要解锁"),[AYGlobleConfig shared].fictionMaxReadSectionNum];
                    occasionalHint(errorStr);
                    return ;
                }
            }
            [[NSUserDefaults standardUserDefaults] setBool:!advertise forKey:kUserDefaultFreeBookCoinUnlock];
            [[NSUserDefaults standardUserDefaults] synchronize];

            if ((self.turnPageType != AYTurnPageCurl && self.viewModel.currentPageIndex==0) || (self.turnPageType == AYTurnPageCurl && self.viewModel.currentPageIndex==0 && advertise)) //水平翻页重新加载数据，因为有缓存
            {
                self.fictionModel.startChatperIndex = [NSString stringWithFormat:@"%ld",(long)self.viewModel.currentChapterIndex];
                [self loadFictionData];
            }
        }
    }];
}

#pragma mark - AYReadBottomViewDelegate -
//菜单
-(void)menuInReadBottomView:(AYReadBottomView *)bottomView
{
    self.editState = NO;

    [CYReadMenuView showMenuViewInView:self.view fictionModel:self.fictionModel currentChapterIndex:_viewModel.currentChapterIndex menuList:nil chapterSelect:^(CYFictionChapterModel *chapterModel,NSInteger chapterIndex) {

        self.fictionModel.startChatperIndex = [NSString stringWithFormat:@"%ld",(long)chapterIndex];
        [self loadFictionData];

    }];
}
//日夜间切换
-(void)dayNightSwitchInReadBottompView:(AYReadBottomView *)bottomView day:(BOOL)day
{
    if (day) {//白天
        self.view.backgroundColor = [UIColor whiteColor];
        self.beforeContentViewController.view.backgroundColor =[UIColor whiteColor];
        self.afterContentViewController.view.backgroundColor =[UIColor whiteColor];
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:kUserDefaultNightMode];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        self.beforeContentViewController.view.backgroundColor =RGB(0, 0, 0);
        self.afterContentViewController.view.backgroundColor =RGB(0, 0, 0);
        self.view.backgroundColor = RGB(0, 0, 0);
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:kUserDefaultNightMode];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self saveUserColorSet:self.view.backgroundColor];
    
    AYFictionReadContentViewController* vc = _pageViewController.viewControllers.lastObject;
    vc.view.backgroundColor = self.view.backgroundColor;
    [vc updateContentApperance];

}

//font设置
-(void)fontSetInReadBottomView:(AYReadBottomView *)bottomView
{
    [AYReadAppearanceSetView showAppearanceSetViewInView:self.view];
}
//评论
-(void)commentInReadBottomView:(AYReadBottomView *)bottomView
{
    self.editState = NO;
    NSDictionary *paraDic = [NSDictionary dictionaryWithObjectsAndKeys:@(AYCommentTypeFiction),@"type",_fictionModel.fictionID,@"book_id", nil];
    [ZWREventsManager sendViewControllerEvent:kEventAYCommentViewController parameters:paraDic];
}
#pragma mark - YReadAppearanceSetViewDelegate -
//字体大小
-(void)fontSizeChange:(AYReadAppearanceSetView *)appearanceSetView value:(CGFloat)fontSizeValue
{
//    if (self.currentContentViewController.showAd && self.turnPageType == AYTurnPageCurl) {
//        return;
//    }
    [[NSUserDefaults standardUserDefaults] setObject:@(fontSizeValue) forKey:kUserDefaultReadFontSize];
    [[NSUserDefaults standardUserDefaults] synchronize];
    AYFictionReadContentViewController* vc = _pageViewController.viewControllers.lastObject;
    NSInteger page = [self.viewModel fontChangedPageWithCurrentPage:vc.currentPage];
    [self showPage:page chapter:self.viewModel.currentChapterIndex];
}
//背景颜色
-(void)backgroundColorChange:(AYReadAppearanceSetView *)appearanceSetView value:(UIColor*)backGroudColor
{
    BOOL night = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultNightMode];
    if (night)//夜晚模式点击无效
    {
        return;
    }
    
    if([AYUtitle compareRGBAColor1:backGroudColor withColor2:self.view.backgroundColor])
    {
        self.view.backgroundColor = [UIColor whiteColor];

    self.beforeContentViewController.view.backgroundColor =[UIColor whiteColor];
    self.afterContentViewController.view.backgroundColor =[UIColor whiteColor];

        [_pageViewController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.view.backgroundColor = [UIColor whiteColor];

        }];
    }
    else
    {
        self.view.backgroundColor = backGroudColor;

        [_pageViewController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.view.backgroundColor = backGroudColor;
        }];
        self.beforeContentViewController.view.backgroundColor =backGroudColor;
        self.afterContentViewController.view.backgroundColor =backGroudColor;
    }

    [self saveUserColorSet:backGroudColor];
}
//翻页方式
-(void)turnPageChange:(AYReadAppearanceSetView *)appearanceSetView value:(AYFictionReadTurnPageType)turnPageType
{
    [AYReadAppearanceSetView removeAppearanceSetView];
    [[NSUserDefaults standardUserDefaults] setObject:@(turnPageType) forKey:kUserDefaultFictionTurnPageType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.editState = NO;
    _turnPageType = turnPageType;
    [self switchTurnPageType];
}
#pragma mark - UIPageViewController datasource -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[AYFictionReadContentViewController class]] && (_turnPageType== AYTurnPageCurl)) {
        self.currentContentViewController = (AYFictionReadContentViewController*)viewController;
        AYReadBackgroundViewController* backCon = [self readBackgroundViewController];
        return backCon;
    }
    AYLog(@"viewControllerBeforeViewController 当前%d页",(int)self.viewModel.currentPageIndex);
    NSInteger pageIndex=0;
    if(_turnPageType== AYTurnPageCurl)
    {
        if ([self needIncreasePageIndexWithDir:NO]) {
            pageIndex = self.viewModel.currentPageIndex-1;
        }
        else
        {
            pageIndex = self.viewModel.currentPageIndex;
        }
        self.oldContentViewController = self.currentContentViewController;
        self.old_dir = NO; //向后翻页

    }
    else
    {
        pageIndex = self.viewModel.currentPageIndex-1;
    }
    // 当前章节和当前页数都为0 代表当前为图书第一张的第一页
    NSInteger chapterIndex = self.viewModel.currentChapterIndex;
    if ( pageIndex < 0)
    {
        if (![self.viewModel preChapter])
        {
             // occasionalHint(@"已经是第一章了！！！");
            return nil;
        }
        chapterIndex-=1;
        pageIndex = [self.viewModel lastPageWithchapterIndex:chapterIndex];
   }
    if ([_viewModel isAdvertiseSection:chapterIndex])//更新广告index
    {
        self.adIndex -=1;
    }
    AYFictionReadContentViewController* beforeCon =[self viewControllerAtIndex:pageIndex chapterIndex:chapterIndex];
    self.beforeContentViewController = beforeCon;
    if ([viewController isKindOfClass:AYReadBackgroundViewController.class] && (_turnPageType== AYTurnPageCurl)) {
        AYReadBackgroundViewController *backCon = (AYReadBackgroundViewController*)viewController;
        [backCon setCurrentContentViewController:beforeCon];
    }
    return beforeCon;
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[AYFictionReadContentViewController class]]&& (_turnPageType== AYTurnPageCurl)) {
        self.currentContentViewController = (AYFictionReadContentViewController*)viewController;
        AYReadBackgroundViewController* backCon = [self readBackgroundViewController];
        [backCon setCurrentContentViewController:viewController];
        return backCon;
    }
    
    AYLog(@"viewControllerAfterViewController 当前%d页",(int)self.viewModel.currentPageIndex);
    NSInteger pageIndex=0;
    if(_turnPageType== AYTurnPageCurl)
    {
        if ([self needIncreasePageIndexWithDir:YES])//防止有广告时点击广告页数会跳跃的问题
        {
            pageIndex = self.viewModel.currentPageIndex+1;
        }
        else
        {
            pageIndex = self.viewModel.currentPageIndex;
        }
        self.oldContentViewController = self.currentContentViewController;
        self.old_dir = YES;//向前翻页

    }
    else
    {
        pageIndex = self.viewModel.currentPageIndex+1;
    }

    NSInteger chapterIndex = self.viewModel.currentChapterIndex;
    if (pageIndex > self.viewModel.lastPage)
    {
        if (![self.viewModel nextChapter])
        {
            return nil;
        }
        chapterIndex+=1;
        pageIndex =0;
    }
    if ([_viewModel isAdvertiseSection:chapterIndex])//更新广告index
    {
        self.adIndex +=1;
    }
    if(_turnPageType== AYTurnPageCurl) {
        self.oldContentViewController = self.currentContentViewController;
    }
    self.afterContentViewController =[self viewControllerAtIndex:pageIndex chapterIndex:chapterIndex];
    return self.afterContentViewController;
}
// 滑动结束时的回调
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    pageViewController.view.userInteractionEnabled = YES;
    UIViewController *tempCurrentViewController =nil;
    if (!completed)
    {//切换不成功 恢复状态
        tempCurrentViewController = previousViewControllers.firstObject;

    }
    else
    {
        tempCurrentViewController = pageViewController.viewControllers.firstObject;
        [self updateCurrentFictionReadInfo:tempCurrentViewController];

    }
    
}
// 手势滑动(或翻页)开始时回调
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    if(self.turnPageType== AYTurnPageCurl)
    {
        pageViewController.view.userInteractionEnabled = NO;
    }
    self.editState = NO;
   UIViewController * tempCurrentViewController = pageViewController.viewControllers.firstObject;
    [self updateCurrentFictionReadInfo:tempCurrentViewController];

}
-(void)updateCurrentFictionReadInfo:(UIViewController*)tempCurrentViewController
{
    if ([tempCurrentViewController isKindOfClass:AYFictionReadContentViewController.class]) {
        AYFictionReadContentViewController *contentViewController = (AYFictionReadContentViewController*)tempCurrentViewController;
        
        if (!contentViewController.showAd) {
            AYLog(@"currentChapterIndex: %d pageIndex:%d",(int)contentViewController.currentChapterIndex,contentViewController.currentPage);
                    [self.viewModel updateChapterInfoWithChapterIndex:contentViewController.currentChapterIndex pageIndex:contentViewController.currentPage];
            
            if (self.turnPageType == AYTurnPageUpdown) {
                [self.contentTopview updateTopValue:contentViewController.chapterTitle];
                [self.contentBottomview updateBottomValue:contentViewController.totalPage current:contentViewController.currentPage showAd: contentViewController.showAd];
            }
        }

    }
}
#pragma mark  - private -
-(BOOL)isNeedShowAd:(NSInteger)pageIndex chapterIndex:(NSUInteger)chapterIndex
{
    if([_viewModel isNeedShowAD:chapterIndex])//这个章节是用广告来解锁
    {
        AYLog(@"the adindex is %ld",(long)pageIndex);
        NSInteger fictionAdvertiseFrequency=[AYGlobleConfig shared].fictionAdvertiseFrequency;
        if (((pageIndex+1)%fictionAdvertiseFrequency)==0) {
                return YES;
            }
    }
    return NO;
}
-(void)saveUserColorSet:(UIColor*)willSetColor
{
    NSData *objColor = [NSKeyedArchiver archivedDataWithRootObject:willSetColor];
    [[NSUserDefaults standardUserDefaults] setObject:objColor forKey:kUserDefaultReadBackColor];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)setReadTurnPageType
{
    NSNumber *turnPageNum = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFictionTurnPageType];
    if (turnPageNum) {
        _turnPageType = [turnPageNum integerValue];
    }
    else
    {
        _turnPageType = AYTurnPageCurl;
    }
}
-(void)openOrCloseBackGesture:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewModel.currentChapterIndex <= 0  && index<=0 )
        {
            // 开启返回手势
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
        }
        else
        {
            if (self.navigationController.interactivePopGestureRecognizer.enabled) {
                // 开启返回手势
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
                }
            }
        }
    });
}

-(void)switchTurnPageType
{
    [self initPageViewController];
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.bottomView];
    [self showPage:_viewModel.currentPageIndex chapter:self.viewModel.currentChapterIndex];

}
-(void)changeTopViewStatus
{
    [self.topView changeToAdvertiseMode:([_viewModel isAdvertiseSection:self.viewModel.currentChapterIndex]?YES:NO)];
    BOOL coinUnlock= [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFreeBookCoinUnlock];
    [self.topView changeCoinModeInAdverse:coinUnlock];

}
-(BOOL)needIncreasePageIndexWithDir:(BOOL)next
{
    if (self.currentContentViewController && self.oldContentViewController && self.currentContentViewController.showAd)//当只有在广告页点击才有可能出现两页之间出现不是连续的，也就是当前页为第二页，当翻页时有可能出现0页或者 4页，第三页不显示的问题
    {
     
        if(self.currentContentViewController.currentPage == self.oldContentViewController.currentPage && next==self.old_dir) //当上两页页码相同时，q且翻页方向没发生变化时才要页码变化，否则页码不变化
        {
            return YES;
        }
        
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark  - db -
-(BOOL)fictionIsAddToBookRack
{
    NSString *qureyStr = [NSString stringWithFormat:@"bookID = '%@'",self.fictionModel.fictionID];
    NSArray<AYBookModel*> *booRackArray = [AYBookModel r_query:qureyStr];
    if (booRackArray && booRackArray.count>0 ) //已阅读过
    {
        AYBookModel *bookModel = booRackArray[0];
        if ([bookModel.isgroom boolValue]) {
            return NO;
        }
        return YES;
    }
    return NO;
}
#pragma mark  - UI -
- (void)showPage:(NSInteger)page chapter:(NSInteger)chapterIndex{
    AYLog(@"pageviewcontroller 设置数据%ld",(long)page);
    AYFictionReadContentViewController *initialViewController = [self viewControllerAtIndex:page chapterIndex:chapterIndex];// 得到第一页
    self.currentContentViewController= initialViewController;
      UIPageViewControllerNavigationDirection direction =  UIPageViewControllerNavigationDirectionForward;
    if (_turnPageType== AYTurnPageCurl)
    {
        AYReadBackgroundViewController *backCon = [self readBackgroundViewController];
        NSInteger subControllersCount = _pageViewController.viewControllers.count;
        [backCon setCurrentContentViewController:initialViewController];
        [_pageViewController setViewControllers:((subControllersCount>=2)?@[initialViewController,backCon]:@[initialViewController])
                                      direction:direction
                                       animated:NO
                                     completion:nil];
    }
    else
    {
        [_pageViewController setViewControllers:@[initialViewController]
                                      direction:direction
                                       animated:NO
                                     completion:nil];
    }
    self.currentContentViewController = self.pageViewController.viewControllers.firstObject;
    
    if (self.turnPageType == AYTurnPageUpdown) {
        [self.contentTopview updateTopValue:initialViewController.chapterTitle];
        [self.contentBottomview updateBottomValue:initialViewController.totalPage current:initialViewController.currentPage showAd: initialViewController.showAd];
    }

}
-(void)creatAddAlertController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:AYLocalizedString(@"喜欢这本书就加入书架吧") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:AYLocalizedString(@"加入书架") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFictionAddToRackEvents object:self.fictionModel.fictionID];
        if ([AYUserManager isUserLogin])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:AYLocalizedString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
    
}
-(void)turnPageWithClick:(BOOL)nextPage
{
    self.editState = NO;
    if (nextPage)//下一页
    {
        NSInteger pageIndex=0;
        if ([self needIncreasePageIndexWithDir:YES]) {
            pageIndex = self.viewModel.currentPageIndex+1;
        }
        else
        {
            pageIndex = self.viewModel.currentPageIndex;
        }
        self.old_dir = YES;
        NSInteger chapterIndex = self.viewModel.currentChapterIndex;
       //  self.viewModel.currentPageIndex+=1;
        if (pageIndex> self.viewModel.lastPage)
        {
            if (![self.viewModel nextChapter])
            {
                return;
            }
            chapterIndex= self.viewModel.currentChapterIndex+1;
            pageIndex =0;
        }

        self.oldContentViewController = self.currentContentViewController;
        if ([_viewModel isAdvertiseSection:chapterIndex])//更新广告index
        {
            self.adIndex +=1;
            if (![self isNeedShowAd:self.adIndex chapterIndex:chapterIndex]) {
                self.viewModel.currentChapterIndex = chapterIndex;
                self.viewModel.currentPageIndex =pageIndex;
            }
        }
        else
        {
            self.viewModel.currentChapterIndex = chapterIndex;
            self.viewModel.currentPageIndex = pageIndex;
        }
        [self showPage:pageIndex chapter:chapterIndex];
    }
    else //上一页
    {
        NSInteger pageIndex=0;
        if ([self needIncreasePageIndexWithDir:NO]) {
            pageIndex = self.viewModel.currentPageIndex-1;
        }
        else
        {
            pageIndex = self.viewModel.currentPageIndex;
        }
        self.old_dir = NO;
        NSInteger chapterIndex = self.viewModel.currentChapterIndex;
        if (pageIndex < 0)
        {
            if (![self.viewModel preChapter])
            {
                // occasionalHint(@"已经是第一章了！！！");
                return;
            }
            chapterIndex-=1;
            pageIndex = [self.viewModel lastPageWithchapterIndex:chapterIndex];
        }
        self.oldContentViewController = self.currentContentViewController;

        if ([_viewModel isAdvertiseSection:chapterIndex])///更新广告index
        {
            self.adIndex -=1;
            if (![self  isNeedShowAd:self.adIndex chapterIndex:chapterIndex]) {
                self.viewModel.currentChapterIndex = chapterIndex;
                self.viewModel.currentPageIndex = pageIndex;
            }
        }
        else
        {
            self.viewModel.currentChapterIndex = chapterIndex;
            self.viewModel.currentPageIndex = pageIndex;
        }
        [self showPage:pageIndex chapter:chapterIndex];
    }

}
#pragma  mark - getter and setter -
-(AYReadTopView*)topView
{
    if (!_topView) {
        _topView = [[AYReadTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, Height_TopBar)];
        _topView.delegate = self;
        _topView.title = self.fictionModel.fictionTitle;
        self.topView.transform = CGAffineTransformMakeTranslation(0,-Height_TopBar);
    }
    return _topView;
}
-(AYReadBottomView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[AYReadBottomView alloc] initWithFrame:CGRectMake(0, ScreenHeight-49-(_ZWIsIPhoneXSeries()?20:0), ScreenWidth, (_ZWIsIPhoneXSeries()?49+20:49))];
        _bottomView.delegate = self;
        self.bottomView.transform = CGAffineTransformMakeTranslation(0,70);

    }
    return _bottomView;
}
-(void)setEditState:(BOOL)editState
{
    if(!_animatinoFinished || _editState == editState)
    {
        return;
    }
    _editState = editState;
    _animatinoFinished = NO;
    if(editState == YES)
    {
        [UIView animateWithDuration:0.3 animations:^{
               self.topView.transform =CGAffineTransformIdentity;
               self.bottomView.transform = CGAffineTransformIdentity;
            [self changeTopViewStatus];
        } completion:^(BOOL finished) {
            self.animatinoFinished = YES;

        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.topView.transform = CGAffineTransformMakeTranslation(0,-Height_TopBar-10);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0,69);
        } completion:^(BOOL finished) {
            self.animatinoFinished = YES;
        }];
    }
    [self hideOrShowStatusBar];
//    //更新状态栏是不是显示
//    [self setNeedsStatusBarAppearanceUpdate];
}
-(UIPageViewController *)pageViewController
{
    if(_pageViewController == nil)
    {
        _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:((_turnPageType==AYTurnPageCurl)?UIPageViewControllerTransitionStylePageCurl:UIPageViewControllerTransitionStyleScroll) navigationOrientation:((_turnPageType==AYTurnPageUpdown)?UIPageViewControllerNavigationOrientationVertical:UIPageViewControllerNavigationOrientationHorizontal) options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        if (_turnPageType==AYTurnPageCurl) //仿真模式才有
        {
            [_pageViewController setDoubleSided:YES];
        }
    }
    return _pageViewController;
}
/** 根据页数创建显示文字的控制器 */
- (AYFictionReadContentViewController *)viewControllerAtIndex:(NSUInteger)index chapterIndex:(NSUInteger)chapterIndex{
    AYLog(@"创建第%lu页",(unsigned long)index);
    // 创建一个新的控制器类，并且分配给相应的数据
    AYFictionReadContentViewController *contentVC = [[AYFictionReadContentViewController alloc] init];
    contentVC.chapterShowAd = [_viewModel isNeedShowAD:chapterIndex];
    contentVC.currentChapterIndex = chapterIndex;
    contentVC.chapterTitle = [self.viewModel getChapterNameWithchapterIndex:chapterIndex];
    contentVC.showAd = [self isNeedShowAd:self.adIndex chapterIndex:chapterIndex];
    contentVC.currentPage =contentVC.showAd?self.viewModel.currentPageIndex:index;
    contentVC.turnPageType = self.turnPageType;
    contentVC.content = [self.viewModel stringWithChapterIndex:chapterIndex page:index];
    contentVC.textColor = [UIColor blackColor];
    contentVC.totalPage = [self.viewModel lastPageWithchapterIndex:chapterIndex];
    contentVC.chapterModel = [self.viewModel getChapterModelWithChapterIndex:chapterIndex];
    contentVC.view.backgroundColor = self.view.backgroundColor;
    LEWeakSelf(self)
    contentVC.chargeResultAction = ^(CYFictionChapterModel * _Nonnull chapterModel, BOOL success) {
        LEStrongSelf(self)
        [self.viewModel chapterChargeResult:chapterModel success:success ];
        if (self.turnPageType!= AYTurnPageCurl)//平移解锁 因为平移方式会预先加载前后两页 所以解锁要重新 加载
        {
            CYFictionChapterModel *currentChapterModel = [self.viewModel getCurrentMenuChapterModel];
            if(currentChapterModel == chapterModel)
            {
                self.fictionModel.startChatperIndex = [NSString stringWithFormat:@"%ld",(long)self.viewModel.currentChapterIndex];
                [self loadFictionData];
            }

        }
    };
    contentVC.reloadSectionContent = ^{
        LEStrongSelf(self)
        [self showHUD];
        [self.viewModel loadChatperWithIndex:(int)[self.viewModel currentChapterIndex] compete:^{
            [self hideHUD];
            self.fictionModel.startChatperIndex = [NSString stringWithFormat:@"%ld",(long)[self.viewModel currentChapterIndex]];
            [self loadFictionData];
        } failure:^(NSString * _Nonnull errorString) {
            [self hideHUD];

        }];

    };
    return contentVC;
}
-(AYReadBackgroundViewController*)readBackgroundViewController
{
    AYReadBackgroundViewController *readController = [AYReadBackgroundViewController new];
    return readController;
}
-(AYFictionReadContentBottomview*)contentBottomview
{
    if (!_contentBottomview) {
              _contentBottomview = [[AYFictionReadContentBottomview alloc] initWithFrame:CGRectMake(0, self.pageViewController.view.top+self.pageViewController.view.height, ScreenWidth, 30) showAd:NO];
    }
    return _contentBottomview;
}
-(AYFictionReadContentTopview*)contentTopview
{
    if (!_contentTopview) {
        _contentTopview = [[AYFictionReadContentTopview alloc] initWithFrame:CGRectMake(0, 3+(_ZWIsIPhoneXSeries()?STATUS_BAR_HEIGHT:0), ScreenWidth, 13)];
    }
    return _contentTopview;
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters && [parameters isKindOfClass:AYFictionModel.class]) {
        return YES;
    }
    return NO;}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYFuctionReadViewController alloc] initWithPara:parameters];
}
@end
