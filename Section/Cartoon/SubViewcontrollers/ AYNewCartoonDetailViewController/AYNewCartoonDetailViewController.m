//
//  AYNewCartoonDetailViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/4/7.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYNewCartoonDetailViewController.h"
#import "AYNewCartoonDetailViewModel.h"
#import "AYCartoonDetailModel.h"
#import "UIImage+YYAdd.h"
#import "AYShareView.h"
#import "AYCartoonDetailTableViewCell.h"
#import "AYFictionDetailTableViewCell.h"
#import "AYBookRackManager.h"
#import "AYCoinSelectView.h" //打赏金币选择
#import "AYCartoonChapterModel.h"
#import "AYCartoonCatlogMananger.h" //漫画目录管理
#import "AYShareManager.h" //分享管理

#define BOTTOM_CARTOON_TAG 12434

#define HEADERHEIGHT (IS_IPhoneX_All ? 270 : 220)

@interface AYNewCartoonDetailViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, readwrite, strong) AYNewCartoonDetailViewModel * viewModel; //数据源
@property (nonatomic, strong) AYCartoonModel * cartoonModel; //数据源
@property (nonatomic, strong) UIView *bottomView; //漫画详情BOTTOMVIEW
@property (nonatomic, strong) UIImageView *bannerImageView; //图片
@property (nonatomic, strong) UIView  *headContainView; //头部包含视图
@property(nonatomic,  strong) UIButton *backBtn;
@property(nonatomic,  strong) UIButton *shareBtn;
@property(nonatomic,  strong) UILabel *titleLabel;
@property(nonatomic,  strong) UIPanGestureRecognizer *panGes;
@property(nonatomic,  assign) BOOL topState;//顶部状态

@end

@implementation AYNewCartoonDetailViewController

-(instancetype)initWithPara:(id)para
{
    self = [super init];
    if (self) {
        self.cartoonModel = para;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateUI];
    [self configurateData];
    [self configureNotification];
    [self loadCartoonDetailData:YES];
    // Do any additional setup after loading the view.
}
-(void)dealloc
{
    [[AYCartoonCatlogMananger shared] clearData];
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
#pragma mark - Init
- (void) configurateTableView{
    _AYFictionDetailCellsRegisterToTable(self.tableView, 1);
    self.tableView.showsVerticalScrollIndicator =NO;
    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.tableView setTableFooterView:footView];
    self.view.backgroundColor = RGB(243, 243, 243);
    //  self.tableView.bounces = NO;
}
- (void) configurateData {
    self.viewModel = [AYNewCartoonDetailViewModel viewModelWithViewController:self];
    [self addPanGesture];
    
}
- (void) configurateUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self addTopHeadView];
    [self addBottomView];
}
-(void)configureNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefresh:) name:kNotificationDetailNeedRefreshEvents object:nil];
    
}
#pragma mark - ui -

-(void)addTopHeadView
{
    //创建一个视图
    _headContainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, HEADERHEIGHT)];
    _headContainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headContainView];
    self.tableTopConstraint.constant = _headContainView.height;
    
    UIImageView *bannerImage = [[UIImageView alloc] initWithFrame:_headContainView.bounds];
    self.bannerImageView = bannerImage;
    [self.headContainView addSubview:bannerImage];
    //[self.bannerImageView setImageWithURL:[NSURL URLWithString:self.cartoonModel.cartoonImageUrl] placeholder:LEImage(@"ws_register_example_company")];
    self.bannerImageView.image =LEImage(@"ws_register_example_company");
    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    //裁减超出部分
    _bannerImageView.clipsToBounds = YES;
    [self addFreeFlag];
    
    //返回btn
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, STATUS_BAR_HEIGHT+(44-32)/2.0f, 32, 32);
    [backBtn setImage:LEImage(@"btn_back_nav") forState:UIControlStateNormal];
    backBtn.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.5f);
    backBtn.layer.cornerRadius = 16.0f;
    [self.headContainView addSubview:backBtn];
    [backBtn setEnlargeEdgeWithTop:20 right:30 bottom:30 left:30];
    LEWeakSelf(self)
    [backBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    //分享btn
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(ScreenWidth-15-32, STATUS_BAR_HEIGHT+(44-32)/2.0f, 32, 32);
    shareBtn.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.5f);
    shareBtn.layer.cornerRadius = 16.0f;
    [shareBtn setImage:LEImage(@"task_shared") forState:UIControlStateNormal];
    [self.headContainView addSubview:shareBtn];
    [shareBtn setEnlargeEdgeWithTop:20 right:30 bottom:30 left:20];
    [shareBtn addAction:^(UIButton *btn) {
        LEStrongSelf(self)
        [AYShareManager ShareCartoonWith:self.cartoonModel parentView:self.view];
        
    }];
    
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:18] textColor:RGB(51, 51, 51) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    titleLable.frame = CGRectMake(15, HEADERHEIGHT-44, ScreenWidth-80, 44);
    titleLable.text = self.cartoonModel.cartoonTitle;
    [self.headContainView addSubview:titleLable];
    self.titleLabel= titleLable;
}
-(void)addBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,ScreenHeight-49-[AYUtitle al_safeAreaInset:self.view].bottom-[AYUtitle al_safeAreaInset:self.view].top-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0), ScreenWidth, 49)];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0,0);
    bottomView.layer.shadowOpacity = 0.5;
    bottomView.layer.shadowRadius = 1;
    // 单边阴影 顶边
    float shadowPathWidth = bottomView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, bottomView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    bottomView.layer.shadowPath = path.CGPath;
    self.tableBottomConstraint.constant = -(bottomView.height+[AYUtitle al_safeAreaInset:self.view].bottom+[AYUtitle al_safeAreaInset:self.view].top+(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0));
    BOOL inRack = [AYBookRackManager bookInBookRack:self.cartoonModel.cartoonID];
    NSArray *titleArray = @[(inRack?AYLocalizedString(@"已在书架"):AYLocalizedString(@"加入书架")),([self.cartoonModel.isfree integerValue]==4)?AYLocalizedString(@"免费阅读"):AYLocalizedString(@"阅读"),AYLocalizedString(@"打赏")];
    CGFloat btnWidth = ScreenWidth/3.0f;
    [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(250, 85, 108) title:obj image:nil];
        actionBtn.frame = CGRectMake(idx*btnWidth, 0, btnWidth, bottomView.height);
        actionBtn.tag = BOTTOM_CARTOON_TAG+idx;
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
            int tag = (int)btn.tag-BOTTOM_CARTOON_TAG;
            if (tag==0 ) {//加入书架
                if (![AYUserManager isUserLogin]) {
                    [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
                        [self addCartoonToBookRack];
                    }];
                }
                else
                {
                    [self addCartoonToBookRack];
                }
            }
            else if (tag==1 )
            {
                AYCartoonChapterModel *chapterModel = [AYCartoonChapterModel new];
                chapterModel.cartoonId = self.cartoonModel.cartoonID;
                chapterModel.cartoontTitle = self.cartoonModel.cartoonTitle;
                NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:chapterModel,@"chapter",self.cartoonModel,@"cartoon", nil];
                [ZWREventsManager sendViewControllerEvent:kEventAYCartoonReadPageViewController parameters:para];
                
            }
            else //打赏
            {
                [AYCoinSelectView showCoinSelectViewInView:self.view model:self.cartoonModel success:^(NSString *rewardNum){
                }];
            }
        }];
        [bottomView addSubview:actionBtn];
    }];
}
//免费漫画，增加免费标签
-(void)addFreeFlag
{
    if ([self.cartoonModel.isfree integerValue]!=4) {
        return;
    }
    UILabel *freeFlagLable=(UILabel*)[self.bannerImageView viewWithTag:126458];
    if (freeFlagLable)
    {
        [freeFlagLable removeFromSuperview];
        freeFlagLable = nil;
    }
    freeFlagLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:10] textColor:RGB(255, 255, 255) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    freeFlagLable.tag = 126458;
    freeFlagLable.backgroundColor =RGB(255, 59, 98);
    [self.bannerImageView addSubview:freeFlagLable];
    freeFlagLable.text = AYLocalizedString(@"免费");
    freeFlagLable.frame = CGRectMake(self.bannerImageView.width-70, self.bannerImageView.height-30, 100, 20);
    freeFlagLable.transform =CGAffineTransformMakeRotation (-M_PI_4);
}
#pragma mark - private -

-(void)setSurfaceplot:(NSString*)surfaceUrl
{
    if (!surfaceUrl || surfaceUrl.length<5) {
        LEImageSet(self.bannerImageView, self.cartoonModel.cartoonImageUrl, @"ws_register_example_company");
        
    }
    else
    {
        LEImageSet(self.bannerImageView, surfaceUrl, @"ws_register_example_company");
    }
    
}
#pragma mark - gesture -

- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    _panGes = pan;
}
#pragma mark - network -
-(void)loadCartoonDetailData:(BOOL)first
{
    if (first) {
        [self showHUD];
    }
    [_viewModel getCartoonDetailDataByCartoonModel:self.cartoonModel complete:^{
        [self setSurfaceplot:self.viewModel.cartoonDetailModel.cartoonSurfaceplot];
        [self.tableView reloadData];
        [self loadCartoonRecommendData];
        [self hideHUD];
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        [self hideHUD];
    }];
}
-(void)loadCartoonRecommendData
{
    [_viewModel getCartoonRecommend:self.cartoonModel complete:^{
        [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString * _Nonnull errorString) {
    }];
}
-(void)addCartoonToBookRack
{
    [AYBookRackManager addBookToBookRackWithBookID:self.cartoonModel.cartoonID fiction:NO compete:^{
        NSString *result = AYLocalizedString(@"加入书架成功");
        occasionalHint(result);
        
        UIButton *addTagBtn = [self.bottomView viewWithTag:BOTTOM_CARTOON_TAG];
        if (addTagBtn) {
            [addTagBtn setTitle:AYLocalizedString(@"已在书架") forState:UIControlStateNormal];
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
    
}
#pragma mark   - UIGesturenDelegate -
- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint movePoint = [pan translationInView:pan.view];
    [pan setTranslation:CGPointZero inView:pan.view];
    
    CGFloat absX = fabs(movePoint.x);
    CGFloat absY = fabs(movePoint.y);
    
    CGFloat offset = self.tableView.contentOffset.y + self.tableView.contentInset.top;
    if (self.topState && offset>0)
    {
        return;
    }
    // 如果左右滑动,就不要出现上下滑动,提升使用体验
    if (absX > absY ) {
        if (movePoint.x<0) {
            return;
            
        }else{
            return;
        }
    } else if (absY > absX) {
        
        
        if (movePoint.y<0) {
            //AYLog(@"向上滑动");
            
        }else{
            
            
            //AYLog(@"向下滑动");
            if (self.topState && offset<=0)
            {
                self.topState =NO;
                self.tableView.bounces= YES;
                
            }
        }
    }
    CGFloat delta = _headContainView.frame.size.height + movePoint.y;
    if (delta<Height_TopBar+30) {
        [UIView animateWithDuration:0.2 animations:^{
            self.titleLabel.left = 50;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.titleLabel.left = 15;
        }];
    }
    if (delta <= Height_TopBar) {
        delta = Height_TopBar;
        self.tableView.scrollEnabled = YES;
        self.topState = YES;
        self.tableView.bounces= NO;
    }
    else
    {
        self.topState = NO;
    }
    
    _headContainView.height = delta;
    _titleLabel.top =_headContainView.height-_titleLabel.height;
    _bannerImageView.height = _headContainView.height;
    self.tableTopConstraint.constant = _headContainView.height;
    
    CGFloat ratio = (_headContainView.height - Height_TopBar) / (HEADERHEIGHT - Height_TopBar);
    if (_headContainView.frame.size.height<HEADERHEIGHT) {
        self.bannerImageView.alpha = ratio;
    }
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        
        CGFloat delta = _bannerImageView.frame.size.height + movePoint.y;
        if (delta<=HEADERHEIGHT)
        {
        }
        else
        {
            [UIView animateWithDuration:0.2f animations:^{
                self.headContainView.height = HEADERHEIGHT;
                self.bannerImageView.height = self.headContainView.height;
                self.tableTopConstraint.constant = self.headContainView.height;
                self.titleLabel.top =self.headContainView.height-self.titleLabel.height;
            }completion:^(BOOL finished) {
                [self addFreeFlag];
                
            }];
        }
        if (self.headContainView.height<=Height_TopBar &&  self.headContainView.height>Height_TopBar-0.5f && self.tableView.contentSize.height>self.tableView.height && !self.topState) {
            self.tableView.scrollEnabled = YES;
            self.topState = YES;
            self.tableView.bounces= NO;
        }
        else
        {
            
        }
    }
    else
    {
        [self addFreeFlag];
    }
    
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
    UITableViewCell *cell = _AYFictionDetailGetCellByItem(object, 1, tableView, indexPath, ^(UITableViewCell *fetchCell) {
    });
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.viewModel objectForIndexPath:indexPath];
    NSString *str = [object safe_objectAtIndex:0];
    AYCartoonDetailModel *detailModel = [object safe_objectAtIndex:1];
    if([str isEqualToString:@"recomment"])
    {
        if (detailModel.cartoonRecommendList.count<=0) {
            return 0;
        }
    }
    return _AYFictionDetailCellHeightByItem(object, indexPath, 1);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.viewModel objectForIndexPath:indexPath];
    NSString *str = [object safe_objectAtIndex:0];
    if([str isEqualToString:@"menu"])
    {
        [ZWREventsManager sendViewControllerEvent:kEventAYCartoonSelectViewController  parameters:self.cartoonModel];
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
    if (!self.topState) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
    else
    {
        CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;
        //
        if (offset>20 && !scrollView.bounces) {
            scrollView.bounces =YES;
        }
        else if(offset<10 && scrollView.bounces)
        {
            scrollView.bounces =NO;
        }
    }
}
#pragma mark -event handel -
-(void)handleRefresh:(NSNotification*)notify
{
    [self loadCartoonDetailData:NO];
}
#pragma mark- getter and setter -


#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters && [parameters isKindOfClass:AYCartoonModel.class]) {
        return YES;
    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYNewCartoonDetailViewController alloc] initWithPara:parameters];
}


@end
