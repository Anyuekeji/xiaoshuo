//
//  AYCartoonReadPageViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonReadPageViewController.h"
#import "AYReadTopView.h"
#import "AYCartoonReadBottomView.h"
#import "AYShareView.h" //分享视图
#import "NSTimer+YYAdd.h"
#import "AYCartoonReadViewController.h" //每一个page
#import "AYCartoonPageViewModel.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "AYCartoonChapterContentModel.h" //章节内容model
//#import "AYCartoonImageDownloadManager.h"
#import "ZWCacheHelper.h"
#import "AYCartoonReadMenuView.h"//目录视图
#import "AYCartoonModel.h"
#import "AYBookModel.h" //书本model
#import "AYShareManager.h" //分享管理
#import "AYBookRackManager.h"
#import "AYCartoonImageDownloadManager.h"
#import <YYKit/YYKit.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import "AYChargeSelectView.h"
#import "AYCartoonLoadProgressViewController.h"//加载进度
#import "AYReadStatisticsManager.h"
#import "AYAdmobManager.h" //admob 广告管理
#import "AYReadAleartVIew.h"

@interface AYCartoonReadPageViewController ()<AYReadTopViewDelegate,AYCartoonReadBottomViewDelegate,UIGestureRecognizerDelegate,AYCartoonReadViewControllerDelegate>
@property(nonatomic, strong) AYReadTopView *topView;
@property(nonatomic, strong) AYCartoonReadBottomView *bottomView;
@property(nonatomic, assign) BOOL editState; //编辑状态
@property(nonatomic, assign) BOOL animatinoFinished; //动画是否结束
@property (nonatomic,assign) NSInteger currentChapter;//当前章节
@property (nonatomic,strong) AYCartoonReadViewController *currentVC;
@property (nonatomic,strong) AYCartoonReadViewController *preVC;
@property (nonatomic,strong) AYCartoonReadViewController *nextVC;
@property (nonatomic,strong) AYCartoonLoadProgressViewController *loadProgressVC;
@property (nonatomic, strong) AYCartoonPageViewModel *viewModel; //分页视图
@property (nonatomic, strong) AYCartoonChapterModel *chapterModel; //分页视图
@property (nonatomic, strong) AYCartoonModel *cartoonModel; //分页视图
@end

@implementation AYCartoonReadPageViewController
-(instancetype)initWithPara:(id)para
{
    self = [super init];
    if (self) {
        
        self.chapterModel = para[@"chapter"];
        self.cartoonModel = para[@"cartoon"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureData];
    [self configureNotification];
    [self loadCartoonChapterData];
    //用于阅读30分钟获取金币功能
    [[AYReadStatisticsManager shared] enterReadController];
    [[AYReadStatisticsManager shared] localBookFreeReadStatiticsTimeAviable:^{
        //缓存是否有效
    }];
    [[AYAdmobManager shared] createGADRewardBasedVideoAd];
}
-(void)dealloc
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AYCartoonImageDownloadManager shared] canleAllOperation];
    [[AYReadStatisticsManager shared] leaveReadController:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AYUtitle addAppReview];
    });
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
- (BOOL)prefersStatusBarHidden
{
    if(self.editState)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
    [[SDWebImageManager sharedManager] cancelAll];

}
#pragma mark - configure  -
-(void)configureUI
{
    LEWeakSelf(self)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        LEStrongSelf(self)
        CGPoint point = [sender locationInView:self.view];
        if(point.x < ScreenWidth * 0.3 || point.x > ScreenWidth * 0.7 || point.y <ScreenHeight * 0.3 || point.y > ScreenHeight * 0.7)
        {
            return;
        }
        self.editState = !self.editState;
    }];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [self.view addSubview:[self topView]];
    [self.view addSubview:[self bottomView]];
    _editState = NO;
    [self addOrMoveLoadingView:YES];
    //10秒超时 过了11秒就直接显示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(11 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self->_loadProgressVC)
        {
            [self.loadProgressVC setDownProgress:1.0f];
            [self addOrMoveLoadingView:NO];
            if (!self.currentVC) {
                self.currentVC= [self createCartoonReadViewControllerWith:AYCurrent];
            }
        }
    });
}
-(void)configureData
{
    _animatinoFinished = YES;
    self.editState = NO;
    _currentChapter = 0;
    _viewModel = [AYCartoonPageViewModel viewModel];
    _viewModel.currentChapterModel= self.chapterModel;
    _viewModel.currentChapterIndex =_currentChapter;
    //上传人气值
    [AYBookRackManager sendBookHot:self.cartoonModel.cartoonID type:2];
    LEWeakSelf(self)
    _viewModel.cartoonImageLodingProgress = ^(CGFloat progress)
    {
        LEStrongSelf(self)
        if (progress<0.95f && self->_loadProgressVC){
            [self.loadProgressVC setDownProgress:progress];
        }
        else
        {
            if(self->_loadProgressVC)
            {
                [self.loadProgressVC setDownProgress:1.0f];
                [self addOrMoveLoadingView:NO];
            }
            if(!self.currentVC)
            {
                self.currentVC= [self createCartoonReadViewControllerWith:AYCurrent];
            }
        }

    };
}
-(void)configureNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShare) name:kNotificationCartoonChapterShareEvents object:nil];
}
#pragma mark - UI -
-(AYCartoonReadViewController*)createCartoonReadViewControllerWith:(AYResultType)resutlType
{
    AYCartoonChapterContentModel *chapterModel;
    AYCartoonReadViewController *readController;
    if (resutlType == AYCurrent)
    {
        chapterModel = [_viewModel objectForIndexPath:_viewModel.currentChapterIndex];
        readController = [[AYCartoonReadViewController alloc] initWithChapterModel:chapterModel];
        readController.view.frame = self.view.bounds;
        readController.showAd = [_viewModel isNeedShowAD];
        LEWeakSelf(self)
        readController.cartoonChapterModel = [self.viewModel getCurrentMenuChapterModel];
        if (chapterModel) {
            self.topView.title = chapterModel.cartoonChapterTitle;
        }
        readController.chargeResultAction = ^(CYFictionChapterModel * _Nonnull chapterModel, BOOL success) {
            LEStrongSelf(self)
            [self.viewModel chapterChargeResult:chapterModel success:success];
        };

    }
    //pre current next模式 暂时不用 不删除
//    else if (resutlType == AYNext) {
//        chapterModel = [_viewModel objectForIndexPath:_viewModel.currentChapterIndex+1];
//        readController = [[AYCartoonReadViewController alloc] initWithChapterModel:chapterModel];
//        self.nextVC = readController;
//
//        readController.view.frame = CGRectMake(0, ScreenHeight, self.view.width, self.view.height);
//
//    }
//    else if (resutlType == AYPre) {
//        chapterModel = [_viewModel objectForIndexPath:_viewModel.currentChapterIndex-1];
//        readController = [[AYCartoonReadViewController alloc] initWithChapterModel:chapterModel];
//        readController.view.frame = CGRectMake(0, -ScreenHeight, self.view.width, self.view.height);
//        self.preVC = readController;
//
//    }

    readController.cartoondDelegate = self;
    [self addChildViewController:readController];
    [self.view addSubview:readController.view];
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.bottomView];
    return readController;
}

-(void)creatAddAlertController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:AYLocalizedString(@"喜欢这本书就加入书架吧") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:AYLocalizedString(@"加入书架") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartoonAddToRackEvents object:self.cartoonModel.cartoonID];
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
-(void)addOrMoveLoadingView:(BOOL)add
{
    if (add)
    {
        [self addChildViewController:self.loadProgressVC];
        [self.view addSubview:self.loadProgressVC.view];
        
    }
    else
    {
        if (self->_loadProgressVC)
        {
            [UIView animateWithDuration:0.8f animations:^{
                self.loadProgressVC.view.alpha = 0;
            } completion:^(BOOL finished) {
                [self.loadProgressVC.view removeFromSuperview];
                [self.loadProgressVC removeFromParentViewController];
                self.loadProgressVC = nil;
            }];
       
        }
    }
}

-(void)changeTopViewStatus
{
    [self.topView changeToAdvertiseMode:([_viewModel isAdvertiseSection]?YES:NO)];
    BOOL coinUnlock= [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFreeBookCoinUnlock];
    [self.topView changeCoinModeInAdverse:coinUnlock];
    
}
#pragma mark - gesture -

//防止跟tableview 点击冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *touView = touch.view;
    UIView *parView = touView.superview;
    while (parView) {
         if([parView isKindOfClass:AYCartoonReadMenuView.class] || [parView isKindOfClass:AYChargeSelectContainView.class])//相应菜单点击事件
        {
            return NO;
        }
        parView = parView.superview;
    }
    return YES;
}
#pragma mark - event handle -

-(void)handleShare
{
    [AYShareManager ShareCartoonWith:self.cartoonModel parentView:self.view];
}
#pragma mark - network -

-(void)loadCartoonChapterData
{
    [self showHUD];
    [_viewModel startLoadCartoon:(self.chapterModel.startChapterIndex?[self.chapterModel.startChapterIndex integerValue]:-1)  success:^(AYResultType resultType) {
        if (resultType == AYCurrent) {
            [self hideHUD];
            if (!self->_loadProgressVC) {
                        self.currentVC= [self createCartoonReadViewControllerWith:resultType];
            }
   
        }
        
    } failure:^(NSString * _Nonnull errorString, AYResultType failType) {
        [self hideHUD];
        occasionalHint(errorString);
    }];
}
#pragma mark - private -
//是否当前章节有数据
-(BOOL)hasCurrentChapter
{
    AYCartoonChapterContentModel* chapterModel = [_viewModel objectForIndexPath:_viewModel.currentChapterIndex];
    if (chapterModel) {
        return YES;
    }
    return NO;
}
#pragma mark - AYCartoonReadViewControllerDelegate -
//返回
-(void)cartoonReadScrollViewDidScroll:(UIScrollView *)scrollView
{
    self.editState =NO;
}

//下一章
-(void)nextChapterInReadViewController
{
    [self nextChapterInCartoonReadBottompView:_bottomView];
}
//上一章
-(void)preChapterInReadViewController
{
    [self previousChapterInCartoonReadBottomView:self.bottomView];

}
#pragma mark - AYReadTopViewDelegate -
//返回
-(void)backInReadTopView:(AYReadTopView *)topView
{
    [[AYReadStatisticsManager shared] leaveReadController:YES];
    [[AYCartoonImageDownloadManager shared] canleAllOperation];
    [_viewModel saveCartoonReadModel];
    if (![AYBookRackManager bookInBookRack:self.cartoonModel.cartoonID]) {
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

   [AYShareManager ShareCartoonWith:self.cartoonModel parentView:self.view];
    
}
-(void)switchUnlockModeInAdverttiseModeIReadTopView:(AYReadTopView *)topView unlockMode:(BOOL)unlockAdvertise
{
    [AYReadAleartVIew shareReadAleartViewWithTitle:(unlockAdvertise?AYLocalizedString(@"不想付费购买，您可以"):AYLocalizedString(@"不想看广告，您可以")) okActionTitle:(unlockAdvertise?AYLocalizedString(@"看视频解锁该章节"):AYLocalizedString(@"开始付费阅读")) okCancle:YES cancleActionTitle:AYLocalizedString(@"取消") parentView:nil okBlock:^(bool ok){
        if (!ok)
        {
            return;
        }
        if(!topView ) //广告 上的点击
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultFreeBookCoinUnlock];
        }
        else //广告上的点击
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
                else
                {
                    [self.currentVC showUnlockTypeView:YES];
                }
            }
            else
            {
                [self.currentVC showUnlockTypeView:NO];

            }
            [[NSUserDefaults standardUserDefaults] setBool:!advertise forKey:kUserDefaultFreeBookCoinUnlock];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

#pragma mark - AYCartoonReadBottomViewDelegate -
//上一章
-(void)previousChapterInCartoonReadBottomView:(AYCartoonReadBottomView *)bottomView
{
    [_viewModel preChapter:^(AYResultType resultType) {
        if (self.currentVC)
        {

            [self changeNewPage:NO resutlType:resultType];
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);

    }];
}
//下一章
-(void)nextChapterInCartoonReadBottompView:(AYCartoonReadBottomView *)bottomView
{
    [_viewModel nextChapter:^(AYResultType resultType) {
        if (self.currentVC) {
            [self changeNewPage:YES resutlType:resultType];
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}
-(void)changeNewPage:(BOOL)next resutlType:(AYResultType) resultType
{
    if (![self hasCurrentChapter])
    {
        [self showHUD];
        [self.viewModel loadChatperWithIndex:(int)self.viewModel.currentChapterIndex success:^(AYResultType failType) {
            [self hideHUD];

            [self startChangeNewPage:next resutlType:resultType];
        } failure:^(NSString * _Nonnull errorString, AYResultType failType) {
            [self hideHUD];

        }];
    }
    else
    {
        [self startChangeNewPage:next resutlType:resultType];
    }
    
}

-(void)startChangeNewPage:(BOOL)next resutlType:(AYResultType) resultType
{
 dispatch_async(dispatch_get_main_queue(), ^{
        AYCartoonReadViewController*readController = [self  createCartoonReadViewControllerWith:AYCurrent];
        readController.view.top =next?ScreenHeight:-ScreenHeight;
        readController.view.alpha = 0.1f;
        [UIView animateWithDuration:0.6f animations:^{
            
            self.currentVC.view.top = next?-ScreenHeight:ScreenHeight;
            self.currentVC.view.alpha = 0.1f;
            readController.view.alpha = 1.0f;
            readController.view.top = self.view.top;
            //            if (next) {
            //                self.nextVC.view.alpha = 1.0f;
            //                self.nextVC.view.top = self.view.top;
            //            }
            //            else
            //            {
            //                self.preVC.view.alpha = 1.0f;
            //                self.preVC.view.top = self.view.top;
            //            }
            
        } completion:^(BOOL finished) {
            if (finished)
            {
                [self.currentVC removeFromParentViewController];
                [self.currentVC.view removeFromSuperview];
                self.currentVC =nil;
                self.currentVC = readController;
                //                if (next) {
                //                    [self.preVC removeFromParentViewController];
                //                    [self.preVC.view removeFromSuperview];
                //                    self.currentVC = self.nextVC;
                //                    self.preVC = self.currentVC;
                //                }
                //                else
                //                {
                //                    [self.nextVC removeFromParentViewController];
                //                    [self.nextVC.view removeFromSuperview];
                //                    self.currentVC = self.preVC;
                //                    self.nextVC = self.currentVC;
                //
                //                }
                //                [self createCartoonReadViewControllerWith:resultType];
                
                [self.view bringSubviewToFront:self.topView];
                [self.view bringSubviewToFront:self.bottomView];
            }
            
            
        }];
    });
    AYLog(@"input changeNewPage");
}
//菜单
-(void)menuInCartoonReadBottomView:(AYCartoonReadBottomView *)bottomView
{
    self.editState =NO;
    AYCartoonModel *cartoonModel = [AYCartoonModel new];
    cartoonModel.cartoonID =  self.cartoonModel.cartoonID;
    cartoonModel.cartoonTitle = self.cartoonModel.cartoonTitle;
    [AYCartoonReadMenuView showMenuViewInView:self.view cartoonModel:cartoonModel currentChapterIndex:_viewModel.currentChapterIndex    menuList:nil  chapterSelect:^(AYCartoonChapterModel * _Nonnull chapterModel, NSInteger chapterIndex) {
        self.chapterModel = chapterModel;
        self.chapterModel.startChapterIndex = [NSString stringWithFormat:@"%d",(int)chapterIndex];
        [self loadCartoonChapterData];
    }];
}
//评论
-(void)commentInCartoonReadBottomView:(AYCartoonReadBottomView *)bottomView
{
    self.editState =YES;

    NSDictionary *paraDic = [NSDictionary dictionaryWithObjectsAndKeys:@(AYCommentTypeCartoon),@"type",_chapterModel.cartoonId,@"book_id", nil];
    [ZWREventsManager sendViewControllerEvent:kEventAYCommentViewController parameters:paraDic];
    

}
#pragma  mark - getter and setter -
-(AYCartoonLoadProgressViewController*)loadProgressVC
{
    if (!_loadProgressVC)
    {
        _loadProgressVC = [[AYCartoonLoadProgressViewController alloc] init];
        _loadProgressVC.view.frame = self.view.bounds;
        _loadProgressVC.cartoonImageUrl = _cartoonModel.cartoonImageUrl;
    }
    return _loadProgressVC;
}
-(AYReadTopView*)topView
{
    if (!_topView) {
        _topView = [[AYReadTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, Height_TopBar)];
        _topView.delegate = self;
    }
    return _topView;
}
-(AYCartoonReadBottomView*)bottomView
{
    if (!_bottomView) {
        CGFloat bottomHeight = (_ZWIsIPhoneXSeries()?70:49);
        _bottomView = [[AYCartoonReadBottomView alloc] initWithFrame:CGRectMake(0, ScreenHeight-bottomHeight, ScreenWidth, bottomHeight)];
        _bottomView.delegate = self;
    }
    return _bottomView;
}
-(void)setEditState:(BOOL)editState
{
    if(!_animatinoFinished)
    {
        return;
    }

    _editState = editState;
    _animatinoFinished = NO;
    
    if(editState == YES)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            self.topView.transform =CGAffineTransformIdentity;
            self.bottomView.transform = CGAffineTransformIdentity;
            [self changeTopViewStatus];
        } completion:^(BOOL finished) {
            self.animatinoFinished = YES;
        }];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIView animateWithDuration:0.5 animations:^{
            self.topView.transform = CGAffineTransformMakeTranslation(0,-Height_TopBar-50);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0,70);
        } completion:^(BOOL finished) {
            self.animatinoFinished = YES;
        }];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters  && [parameters isKindOfClass:NSDictionary.class]) {
        return YES;
    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYCartoonReadPageViewController alloc] initWithPara:parameters];
}

@end
