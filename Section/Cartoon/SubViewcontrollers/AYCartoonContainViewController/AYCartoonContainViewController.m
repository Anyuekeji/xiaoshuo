//
//  AYCartoonContainViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonContainViewController.h"
#import "LERotateScrollView.h"
#import "AYCartoonModel.h"
#import "AYCartoonDetailSegmengViewController.h"
#import "UIImage+YYAdd.h"
#import "UIViewController+AYNavViewController.h"
#import "AYShareView.h"
#import "AYCartoonChapterModel.h"
#import "AYBookModel.h" //书本model
#import "AYCartoonReadModel.h" //漫画的阅读状态
#import <UIImageView+YYWebImage.h> //漫画的阅读状态
#import "AYShareManager.h" //分享管理
#import "AYCartoonCatlogMananger.h" //漫画目录管理
#import "AYBookRackManager.h"
#import "AYCoinSelectView.h" //打赏金币选择

#define HEADERHEIGHT (IS_IPhoneX_All ? 270 : 220)

#define CARTOON_BOTTOM_ADDRACK_TAG 1236

@interface AYCartoonContainViewController ()<LERotateScrollViewDataSource, LERotateScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIStatusBarStyle    _statusBarStyle;
     __weak UIGestureRecognizer * _interactivePopGestureRecognizer;
}
@property (nonatomic, strong) LERotateScrollView *lanterSlideView; //顶部轮播
@property (nonatomic, strong) NSMutableArray<AYCartoonModel*> *lanterCartoonArray; //漫画轮播
@property (nonatomic, strong) AYCartoonDetailSegmengViewController *cartoonDetailSegmengViewController; //漫画详情segment
@property (nonatomic, strong) UIView *bottomView; //漫画详情segment
@property (nonatomic, strong) AYCartoonModel * cartoonModel; //数据源
@property (nonatomic, strong) UIImageView *bannerImageView; //图片
@property (nonatomic, strong) UIView  *headContainView; //头部包含视图
@property(nonatomic,  assign) CGFloat maxViewHeight;
@property(nonatomic,  strong) UIPanGestureRecognizer *panGes;
@property(nonatomic,  strong) UIScrollView *subScrooView;
@property(nonatomic,  strong) UIButton *backBtn;
@property(nonatomic,  strong) UIButton *shareBtn;
@property(nonatomic,  strong) UILabel *titleLabel;
@property(nonatomic,  assign) BOOL topState;//顶部状态
@end

@implementation AYCartoonContainViewController
-(instancetype)initWithPara:(id)para
{
    self = [super init];
    if (self)
    {
        self.cartoonModel = para;
    }
    return self;
}
-(void)dealloc
{
    [[AYCartoonCatlogMananger shared] clearData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureData];
   // [self configureNavigation];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}
//修改状态栏的状态 浅色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}
-(BOOL)shouldShowNavigationBar
{
    return NO;
}
-(void)configureData
{
    //状态栏的颜色
    _statusBarStyle = UIStatusBarStyleDefault;
    _lanterCartoonArray = [NSMutableArray new];
    [self addPanGesture];
}
-(void)configureUI
{
    self.view.backgroundColor = [UIColor whiteColor];

    //创建一个视图
    _headContainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, HEADERHEIGHT)];
    _headContainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headContainView];
    
    UIImageView *bannerImage = [[UIImageView alloc] initWithFrame:_headContainView.bounds];
    self.bannerImageView = bannerImage;
    [self.headContainView addSubview:bannerImage];
    //[self.bannerImageView setImageWithURL:[NSURL URLWithString:self.cartoonModel.cartoonImageUrl] placeholder:LEImage(@"ws_register_example_company")];
    self.bannerImageView.image =LEImage(@"ws_register_example_company");
    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    //裁减超出部分
    _bannerImageView.clipsToBounds = YES;
    [self addChildViewController:[self cartoonDetailSegmengViewController]];
    [self.view addSubview:self.cartoonDetailSegmengViewController.view];
    [self addBottomView];
    _maxViewHeight = ScreenHeight-Height_TopBar;
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
//-(void)configureNavigation
//{
//    [self setRightBarButtonItem:[self barButtonItemWithTitle:@"" normalColor:RGB(118, 118, 118) highlightColor:RGB(118, 118, 118) normalImage:LEImage(@"share") highlightImage:LEImage(@"share") leftBarItem:NO target:self action:@selector(handleShare)]];
//}
-(void)addBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,ScreenHeight-49-[AYUtitle al_safeAreaInset:self.view].bottom-[AYUtitle al_safeAreaInset:self.view].top-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0), ScreenWidth, 49)];
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
    bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0,0);
    bottomView.layer.shadowOpacity = 0.5;
    bottomView.layer.shadowRadius = 1;
    // 单边阴影 顶边
    float shadowPathWidth = bottomView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, bottomView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    bottomView.layer.shadowPath = path.CGPath;
    BOOL inRack = [AYBookRackManager bookInBookRack:self.cartoonModel.cartoonID];
    NSArray *titleArray = @[(inRack?AYLocalizedString(@"已在书架"):AYLocalizedString(@"加入书架")),([self.cartoonModel.isfree integerValue]==4)?AYLocalizedString(@"免费阅读"):AYLocalizedString(@"阅读"),AYLocalizedString(@"打赏")];
    CGFloat btnWidth = ScreenWidth/3.0f;
    [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom font:[UIFont systemFontOfSize:16] textColor:RGB(250, 85, 108) title:obj image:nil];
        actionBtn.frame = CGRectMake(idx*btnWidth, 0, btnWidth, 49);
        actionBtn.tag = CARTOON_BOTTOM_ADDRACK_TAG+idx;
        actionBtn.backgroundColor = [UIColor redColor];
        actionBtn.titleLabel.numberOfLines = 0;
        actionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [bottomView addSubview:actionBtn];

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
            int tag = (int)btn.tag-CARTOON_BOTTOM_ADDRACK_TAG;
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
            else //评论
            {
                NSDictionary *para =[NSDictionary dictionaryWithObjectsAndKeys:@(YES),@"cartoon", self.cartoonModel.cartoonID,@"bookId",nil ];
              //  [ZWREventsManager sendViewControllerEvent:kEventAYWriteCommentViewController parameters:para];
                
                [AYCoinSelectView showCoinSelectViewInView:self.view model:self.cartoonModel success:^(NSString *rewardNum){
                }];
            }
        }];
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
#pragma mark -event handel -
//-(void)handleShare
//{
//    [AYShareView showShareViewInView:self.view shareParams:nil];
//}
#pragma mark - gesture -

- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    _panGes = pan;
}

#pragma mark - net work -
-(void)addCartoonToBookRack
{
    [AYBookRackManager addBookToBookRackWithBookID:self.cartoonModel.cartoonID fiction:NO compete:^{
        NSString *result = AYLocalizedString(@"加入书架成功");
        occasionalHint(result);
        
        UIButton *addTagBtn = [self.bottomView viewWithTag:CARTOON_BOTTOM_ADDRACK_TAG];
        if (addTagBtn) {
            [addTagBtn setTitle:AYLocalizedString(@"已在书架") forState:UIControlStateNormal];
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];

}
#pragma mark - db -

//-(BOOL)cartoonIsAddToBookRack
//{
//    NSString *qureyStr = [NSString stringWithFormat:@"bookID = '%@'",self.cartoonModel.cartoonID];
//    NSArray<AYBookModel*> *booRackArray = [AYBookModel r_query:qureyStr];
//    if (booRackArray && booRackArray.count>0) //已阅读过
//    {
//        AYBookModel *bookModel = booRackArray[0];
//        if ([bookModel.isgroom boolValue]) {
//            return NO;
//        }
//        return YES;
//    }
//    return NO;
//}
#pragma mark - public -
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
-(void)subScrollViewDidScroll:(UIScrollView *)scrollView
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
-(void)switchScrollView:(UIScrollView *)scrollView
{
    _subScrooView = scrollView;
}

////获取本地小说的阅读状态
//-(AYCartoonReadModel*)localCartoonReadModel
//{
//    NSString *qureyStr = [NSString stringWithFormat:@"cartoonID = '%@'",self.cartoonModel.cartoonID];
//    NSArray<AYCartoonReadModel*> *readModelArray = [AYCartoonReadModel r_query:qureyStr];
//    if (readModelArray && readModelArray.count>0) //已阅读过
//    {
//        AYCartoonReadModel *readModel = [readModelArray objectAtIndex:0];
//        if (readModel) {
//            return readModel;
//        }
//    }
//    return nil;
//}
#pragma mark - LERotateScrollViewDataSource
- (NSUInteger) numberOfPageInRotateScrollView : (LERotateScrollView *) rotateScrollView {
    return 4;
}

- (UIView *) rotateScrollView :(LERotateScrollView *) rotateScrollView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    if (!view) {
        UIImageView *imageView = [UIImageView new];
        imageView.frame = _lanterSlideView.bounds;
        LEImageSet(imageView,@"http://pic.962.net/up/2013-11/20131111660842038745.jpg", @"ws_register_example_company");
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        return imageView;
    }
    else
    {
        LEImageSet((UIImageView*)view, @"http://pic.962.net/up/2013-11/20131111660842038745.jpg", @"ws_register_example_company");
        return view;
    }
}

#pragma mark - LERotateScrollViewDelegate
- (void) leRotateScrollView : (LERotateScrollView *) rotateScrollView didClickPageAtIndex : (NSInteger) index {
    //
}

- (void) leRotateScrollView : (LERotateScrollView *) rotateScrollView didMovedToPageAtIndex : (NSInteger) index {
    //
}

#pragma mark   - UIGesturenDelegate -
- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint movePoint = [pan translationInView:pan.view];
    [pan setTranslation:CGPointZero inView:pan.view];
    
    CGFloat absX = fabs(movePoint.x);
    CGFloat absY = fabs(movePoint.y);
    
    CGFloat offset = self.subScrooView.contentOffset.y + self.subScrooView.contentInset.top;
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
                self.subScrooView.bounces= YES;

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
        _subScrooView.scrollEnabled = YES;
        self.topState = YES;
        self.subScrooView.bounces= NO;
    }
    else
    {
        self.topState = NO;
    }

   _headContainView.height = delta;
    _titleLabel.top =_headContainView.height-_titleLabel.height;
    _bannerImageView.height = _headContainView.height;
    self.cartoonDetailSegmengViewController.view.top =_headContainView.height;
    self.cartoonDetailSegmengViewController.view.height = ScreenHeight-_bottomView.height-_headContainView.height-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0);
    
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
                self.cartoonDetailSegmengViewController.view.top =self.headContainView.height;
                self.cartoonDetailSegmengViewController.view.height = ScreenHeight-self.bottomView.height-self.headContainView.height-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0);
                self.titleLabel.top =self.headContainView.height-self.titleLabel.height;
            }completion:^(BOOL finished) {
                [self addFreeFlag];

            }];
        }
        if (self.headContainView.height<=Height_TopBar &&  self.headContainView.height>Height_TopBar-0.5f && _subScrooView.contentSize.height>self.cartoonDetailSegmengViewController.view.height && !self.topState) {
            _subScrooView.scrollEnabled = YES;
            self.topState = YES;
            self.subScrooView.bounces= NO;
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
#pragma mark -  UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if (_topView.alpha == 1.0f &&  self.subScrooView.contentOffset.y 0 ) {
//        return YES;
//    }
//    else if (_topView.alpha <1.0f ) {
//        return YES;
//    }
//    return YES;
//}

//- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
//    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
//    return fabs(translation.x) >= fabs(translation.y);
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
////    if ( [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
////        return NO;
////    }
//      return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if ( otherGestureRecognizer == [self interactivePopGestureRecognizer] ) {
//        return YES;
//    } else if ( [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] && otherGestureRecognizer.state == UIGestureRecognizerStateBegan ) {
//        return YES;
//    }
//    return NO;
//}
//
//- (UIGestureRecognizer *) interactivePopGestureRecognizer {
//    if ( !_interactivePopGestureRecognizer ) {
//        UINavigationController * navigationController = self.navigationController;
//        if ( navigationController ) {
//            _interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer;
//            _interactivePopGestureRecognizer.enabled = NO;
//        }
//    }
//    return _interactivePopGestureRecognizer;
//}
#pragma mark - getter and setter -
-(LERotateScrollView*)lanterSlideView
{
    if (!_lanterSlideView)
    {
        LERotateScrollView * rotateView = [LERotateScrollView view];
        rotateView.dataSource = self;
        rotateView.delegate = self;
        _lanterSlideView = rotateView;
        rotateView.frame = CGRectMake(0, 0, ScreenWidth, ((ScreenWidth*160/375.0f>160)?ScreenWidth*160/375.0f:160));
    }
    return _lanterSlideView;
}
-(AYCartoonDetailSegmengViewController*)cartoonDetailSegmengViewController
{
    if (!_cartoonDetailSegmengViewController)
    {
        AYCartoonDetailSegmengViewController * controller = [[AYCartoonDetailSegmengViewController alloc] initWithPara:self.cartoonModel];
        controller.view.frame = CGRectMake(0, HEADERHEIGHT, ScreenWidth,ScreenHeight-HEADERHEIGHT-49-(_ZWIsIPhoneXSeries()?STATUS_BAR_HEIGHT:0)-[AYUtitle al_safeAreaInset:self.view].bottom-[AYUtitle al_safeAreaInset:self.view].top-(_ZWIsIPhoneXSeries()?LEIphoneXSafeBottomMargin:0));
        _cartoonDetailSegmengViewController= controller;
    }
    return _cartoonDetailSegmengViewController;
}

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
    return [[AYCartoonContainViewController alloc] initWithPara:parameters];
}

@end
