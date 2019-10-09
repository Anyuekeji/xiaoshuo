//
//  AYFictionDetailViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionDetailViewController.h"
#import "AYFictionDetailModel.h"
#import "AYFictionDetailViewModel.h"
#import "AYFictionDetailTableViewCell.h"
#import "UIImage+YYAdd.h"
#import "AYShareView.h"
#import "AYReadManager.h"
#import "AYFuctionReadViewController.h"
#import "UIViewController+AYNavViewController.h"
#import "AYShareView.h"
#import "LETransitionNavigationDelegate.h"
#import "UITableView+YYAdd.h"
#import "AYFictionReadModel.h" //存储当前小说阅读状态
#import "CYFictionChapterModel.h"
#import "AYBookModel.h" //书本model
#import "AYShareManager.h" //分享管理
#import "AYFictionCatlogManager.h" //目录管理
#import "AYBookRackManager.h"
#import "AYReadTopView.h"
#import "AYCoinSelectView.h" //打赏金币选择
#import "AYGuideManager.h"

#define BOTTOM_ADDRACK_TAG 1232

#define BLURHEADERHEIGHT (IS_IPhoneX_All ? 470 : 400)


@interface AYFictionDetailViewController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate,AYReadTopViewDelegate>
@property (nonatomic, readwrite, strong) AYFictionDetailViewModel * viewModel; //数据源
@property (nonatomic,strong) AYFictionModel * fictionModel; //model
@property (nonatomic, strong) LETransitionNavigationDelegate *transitionDelegate;
@property (nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic,strong)UIImageView *blurImageView;//模糊图片
@property(nonatomic,  strong) UILabel *titleLabel;
@property (nonatomic, strong) AYGuideManager *guideManager; //引导管理

@end

@implementation AYFictionDetailViewController
-(instancetype)initWithParas:(id)para
{
    self = [super init];
    if (self) {
        _fictionModel = para;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateUI];
    [self configurateData];
    [self configureNotification];
    [self loadFictionDetailData:YES];
    [self configureNavigation];
    [self loadFictionCatalogData];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.blurImageView.alpha =0;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.transitionDelegate = nil;
    self.blurImageView.alpha =1;
    self.navigationController.delegate =self;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)dealloc
{
    //清除缓存
    [[AYFictionCatlogManager shared] clearData];
     self.transitionDelegate = nil;
    self.navigationController.delegate =self;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
#pragma mark - Init
- (void) configurateTableView{
   _AYFictionDetailCellsRegisterToTable(self.tableView, 0);
    self.tableView.showsVerticalScrollIndicator =NO;
    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.tableView setTableFooterView:footView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableTopConstraint.constant = self.topView.height;

}
- (void) configurateData {
    self.viewModel = [AYFictionDetailViewModel viewModelWithViewController:self];
}

-(void)configureNavigation
{
    [self setRightBarButtonItem:[self barButtonItemWithTitle:@"" normalColor:RGB(118, 118, 118) highlightColor:RGB(118, 118, 118) normalImage:LEImage(@"task_shared") highlightImage:LEImage(@"task_shared") leftBarItem:NO target:self action:@selector(handleShare)]];
}
- (void) configurateUI
{
    [self configureHeadView];
    [self configureBlurHeadView];
    self.view.backgroundColor = [UIColor whiteColor];
      //  [self.view addSubview:[self topView]];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,ScreenHeight-49-[AYUtitle al_safeAreaInset:self.view].bottom-[AYUtitle al_safeAreaInset:self.view].top-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0), ScreenWidth, 49)];
    [self.view addSubview:bottomView];
    bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0,0);
    bottomView.layer.shadowOpacity = 0.5;
    bottomView.layer.shadowRadius = 1;
    self.bottomView = bottomView;
    // 单边阴影 顶边
    float shadowPathWidth = bottomView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, bottomView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    bottomView.layer.shadowPath = path.CGPath;
    self.tableBottomConstraint.constant = -(bottomView.height+[AYUtitle al_safeAreaInset:self.view].bottom+[AYUtitle al_safeAreaInset:self.view].top+(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0));
    BOOL inRack = [AYBookRackManager bookInBookRack:self.fictionModel.fictionID];
    NSArray *titleArray = @[(inRack?AYLocalizedString(@"已在书架"):AYLocalizedString(@"加入书架")),([self.fictionModel.isfree integerValue]==4)?AYLocalizedString(@"免费阅读"):AYLocalizedString(@"阅读"),AYLocalizedString(@"打赏")];
    CGFloat btnWidth = ScreenWidth/3.0f;
    [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(250, 85, 108) title:obj image:nil];
        actionBtn.frame = CGRectMake(idx*btnWidth, 0, btnWidth, bottomView.height);
        actionBtn.tag = BOTTOM_ADDRACK_TAG+idx;
        actionBtn.titleLabel.numberOfLines = 0;
        actionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
         if(idx==1)
        {
            [actionBtn setBackgroundImage:[UIImage imageWithColor:RGB(250, 85, 108)] forState:UIControlStateNormal];
            [actionBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
        }
        else
        {
            [actionBtn setBackgroundImage:[UIImage imageWithColor:RGB(255, 255, 255)] forState:UIControlStateNormal];
        }
        LEWeakSelf(self)
        [actionBtn addAction:^(UIButton *btn) {
            LEStrongSelf(self)
            int tag = (int)btn.tag-BOTTOM_ADDRACK_TAG;
            if (tag==0 ) {//加入书架
                if (![AYUserManager isUserLogin]) {
                    [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                        [self addBookToBookRack];
                    }];
                }
                else
                {
                    [self addBookToBookRack];
                }
            }
            else if (tag==1 )
            {
                [ZWREventsManager sendViewControllerEvent:kEventAYFuctionReadViewController parameters:self.fictionModel];

            }
            else //打赏
            {
//                NSDictionary  *paraDic = [NSDictionary dictionaryWithObjectsAndKeys:@(NO),@"cartoon",self.fictionModel.fictionID,@"bookId", nil];
//                [ZWREventsManager sendViewControllerEvent:kEventAYWriteCommentViewController parameters:paraDic];
                [AYCoinSelectView showCoinSelectViewInView:self.view model:self.fictionModel success:^(NSString *rewardNum){
                }];
            }
        }];
        [bottomView addSubview:actionBtn];
    }];
}
-(void)configureGuide
{
    if(![AYGuideManager guideFinishWithViewType:AYGuideViewTypeFictionDetail])
    {
        AYGuideManager *guideManager= [[AYGuideManager alloc] init];
        _guideManager = guideManager;
        [_guideManager showGuideWithViewType:AYGuideViewTypeFictionDetail];
        self.view.userInteractionEnabled =NO;
        LEWeakSelf(self)
        _guideManager.guideFinish = ^{
            LEStrongSelf(self)
            self.view.userInteractionEnabled =YES;
        };
    }
}
-(void)configureBlurHeadView
{
    UIImageView *blurImageView = [UIImageView new];
    blurImageView.contentMode = UIViewContentModeScaleAspectFill;
    blurImageView.frame = CGRectMake(0, 0, ScreenWidth, BLURHEADERHEIGHT);
    [self.view addSubview:blurImageView];
    _blurImageView = blurImageView;
    _blurImageView.alpha =0;
    LEImageSetResponse(_blurImageView, self.fictionModel.fictionImageUrl, @"", ^(UIImage *image) {
        self.blurImageView.image = image;
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualView.frame = CGRectMake(0, 0, ScreenWidth, BLURHEADERHEIGHT);
        //visualView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.blurImageView addSubview:visualView];
        UIView *maskView = [[UIView alloc] initWithFrame:visualView.frame];
        [maskView setBackgroundColor:UIColorFromRGBA(0xFFFFFF, 0.3f)];
        [self.blurImageView addSubview:maskView];
//        NSDictionary * _binds = @{@"visualView":visualView};
//        [self.blurImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[visualView]-0-|" options:0 metrics:nil views:_binds]];
//        [self.blurImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[visualView]-0-|" options:0 metrics:nil views:_binds]];
        
    });
    [self.view sendSubviewToBack:self.blurImageView];
}
-(void)configureNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefresh:) name:kNotificationDetailNeedRefreshEvents object:nil];
}
-(void)configureHeadView
{
    
    [self.view addSubview:self.topView];
    self.topView.alpha =0;

    //返回btn
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, STATUS_BAR_HEIGHT+(44-32)/2.0f, 32, 32);
    [backBtn setImage:LEImage(@"btn_back_nav") forState:UIControlStateNormal];
    backBtn.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.3f);
    backBtn.layer.cornerRadius = 16.0f;
    [self.view addSubview:backBtn];
    [backBtn setEnlargeEdgeWithTop:20 right:30 bottom:30 left:30];
    LEWeakSelf(self)
    [backBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    //分享btn
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(ScreenWidth-15-32, STATUS_BAR_HEIGHT+(44-32)/2.0f, 32, 32);
    shareBtn.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.3f);
    shareBtn.layer.cornerRadius = 16.0f;
    [shareBtn setImage:LEImage(@"task_shared") forState:UIControlStateNormal];
    [self.view addSubview:shareBtn];
    [shareBtn setEnlargeEdgeWithTop:20 right:30 bottom:30 left:20];
    [shareBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        [self handleShare];
    }];
    
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:18] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    titleLable.frame = CGRectMake(55,STATUS_BAR_HEIGHT, ScreenWidth-110, 44);
    titleLable.text = self.fictionModel.fictionTitle;
    [self.view addSubview:titleLable];
    titleLable.alpha =0;
//    titleLable.backgroundColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
//    titleLable.contentEdgeInsets = UIEdgeInsetsMake(0, 55, 0, 55);
    self.titleLabel= titleLable;
}
#pragma mark -event handel -
-(void)handleRefresh:(NSNotification*)notify
{
    [self loadFictionDetailData:NO];
}
-(void)handleShare
{
    [AYShareManager ShareFictionWith:self.fictionModel parentView:self.view];
}
#pragma mark - ui -

#pragma mark - network -
-(void)addBookToBookRack
{
    [AYBookRackManager addBookToBookRackWithBookID:self.fictionModel.fictionID fiction:YES compete:^{
        NSString *result = AYLocalizedString(@"加入书架成功");
        occasionalHint(result);
        UIButton *addTagBtn = [self.bottomView viewWithTag:BOTTOM_ADDRACK_TAG];
        if (addTagBtn) {
            [addTagBtn setTitle:AYLocalizedString(@"已在书架") forState:UIControlStateNormal];
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        
    }];
}
-(void)loadFictionDetailData:(BOOL)first
{
    if (first) {
        [self showHUD];

    }

    [_viewModel getFictionDetailDataByFictionModel:_fictionModel complete:^{
        [self.tableView reloadData];
        [self loadFictionRecommendData];
        [self hideHUD];
        [self configureGuide];
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        [self hideHUD];

    }];
}
-(void)loadFictionRecommendData
{
    [_viewModel getFictionRecommend:_fictionModel complete:^{
        [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString * _Nonnull errorString) {
       // occasionalHint(errorString);
    }];
}
//提前加载目录，用于阅读
-(void)loadFictionCatalogData
{
    [[AYFictionCatlogManager shared] clearData];
    [[AYFictionCatlogManager shared] fetchFictionCatlogWithFictionId:self.fictionModel.fictionID refresh:YES success:^(NSArray<CYFictionChapterModel *> * _Nonnull fictionCatlogArray) {
        
    } failure:^(NSString * _Nonnull errorString) {
        
    }];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.viewModel objectForIndexPath:indexPath];
    UITableViewCell *cell = _AYFictionDetailGetCellByItem(object, 0, tableView, indexPath, ^(UITableViewCell *fetchCell) {
        //        if ([fetchCell isKindOfClass:[WSMeTableViewLoginoutCell class]]) {
        //            ((WSMeTableViewLoginoutCell*)fetchCell).wsLoginoutAction = ^{
        //                [weakself.tableView reloadData];
        //            };
        //        }
    });
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.viewModel objectForIndexPath:indexPath];
    static int commentIndex;//当comment为空时，下一个empty的高度也为0,就不会造成2个empty
    NSString *str = [object safe_objectAtIndex:0];
    AYFictionDetailModel *detailModel = [object safe_objectAtIndex:1];
    if([str isEqualToString:@"recomment"])
    {
        if (detailModel.recommentFictionList.count<=0) {
            return 0;
        }
    }
    if (commentIndex>0) {
        if (indexPath.row == commentIndex+1) {
            return 0;
        }
    }
    return _AYFictionDetailCellHeightByItem(object, indexPath, 0);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.viewModel objectForIndexPath:indexPath];
    NSString *str = [object safe_objectAtIndex:0];
    if([str isEqualToString:@"menu"])
    {
        AYFictionDetailModel *detailModel = [object safe_objectAtIndex:1];
        NSDictionary *paraDic = [NSDictionary dictionaryWithObjectsAndKeys:detailModel.fictionTitle,@"title",detailModel.fictionID,@"id", nil];
        [ZWREventsManager sendViewControllerEvent:kEventCYFictionCatalogViewController parameters:paraDic];
    }
    else if([str isEqualToString:@"invate"])
    {
        if ([AYUserManager isUserLogin])
        {
            [ZWREventsManager sendViewControllerEvent:kEventAYFriendSegmentViewController parameters:nil];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                [ZWREventsManager sendViewControllerEvent:kEventAYFriendSegmentViewController parameters:nil];            }];
        }
    }
    else if([str isEqualToString:@"charge"])
    {
        NSString *chargeUrl  = [NSString stringWithFormat:@"%@%@",[AYUtitle getServerUrl],@"home/privacy/icharge"];

        [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:chargeUrl animate:YES];
    }
}

#pragma mark- scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<-self.blurImageView.height)
    {
        self.blurImageView.height+=-offsetY;
        self.titleLabel.alpha =0;
        self.topView.alpha =0;
    }
    else if(offsetY>46)
    {
        self.titleLabel.alpha = offsetY/(self.topView.height+20);
        self.topView.alpha = self.titleLabel.alpha;
    }
    else
    {
        self.titleLabel.alpha =0;
        self.topView.alpha =0;
    }
}
- (LETransitionNavigationDelegate *)transitionDelegate {
    if (_transitionDelegate == nil) {
        _transitionDelegate = [[LETransitionNavigationDelegate alloc] init];
    }
    return _transitionDelegate;
}

#pragma  mark - getter and setter -

-(UIView*)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, Height_TopBar)];
        _topView.backgroundColor = [UIColor whiteColor];
        
    }
    return _topView;
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters && [parameters isKindOfClass:AYFictionModel.class]) {
        return YES;
    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYFictionDetailViewController alloc] initWithParas:parameters];
}
@end
