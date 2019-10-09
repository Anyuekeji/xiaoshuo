//
//  AYFictionViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionViewController.h"
#import "LERotateScrollView.h"
#import "AYFictionViewModle.h"
#import "AYFictionTableViewCell.h"
#import "AYFictionModel.h"
#import "AYBannerModel.h"
#import "AYCartoonChapterModel.h"
#import "AYCartoonModel.h"
#import "AYADSkipManager.h" //banner跳转管理
#import "AYFreeHeadView.h"
#import "AYADSkipManager.h" //banner跳转管理
#import "AYBookmailViewController.h"
#import "AYBookModel.h"
#import "AYGuideManager.h"

@interface AYFictionViewController ()<LERotateScrollViewDataSource, LERotateScrollViewDelegate>
@property (nonatomic, readwrite, strong) AYFictionViewModle * viewModel; //数据处理
@property (nonatomic, strong) LERotateScrollView *lanterSlideView; //顶部轮播
@property (nonatomic, assign) long long endTime; //结束时间
@property (nonatomic, strong) AYGuideManager *guideManager; //顶部轮播
@end

@implementation AYFictionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateData];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

#pragma mark - Init
- (void) configurateTableView {
    LERegisterCellForTable([AYFictionTableViewCell class], self.tableView);
    LERegisterCellForTable([AYFictionThreeTableViewCell class], self.tableView);
    LERegisterCellForTable([AYFictionRecomendHeadTableViewCell class], self.tableView);
    LERegisterCellForTable([AYFictionHorizontalScrollAnimateTableViewCell class], self.tableView);

    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.tableHeaderView = [self lanterSlideView];
}
- (void) configurateData
{
    self.viewModel = [AYFictionViewModle viewModelWithViewController:self];
    self.viewModel.viewType = AYFictionViewTypeHome;
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.top =self.navigationController.navigationBar.bounds.size.height;
        self.tableView.contentInset =insets;
        self.tableView.scrollIndicatorInsets = insets;
    }

}
-(void)configureGuide
{
    if(![AYGuideManager guideFinishWithViewType:AYGuideViewTypeFiction])
    {
        if(self.tabBarController.selectedIndex!=1)
        {
            return;
        }
        self.tableView.tableHeaderView =nil;        AYGuideManager *guideManager= [[AYGuideManager alloc] init];
        self.view.userInteractionEnabled =NO;
        self.view.superview.userInteractionEnabled =NO;
        _guideManager = guideManager;
        [_guideManager showGuideWithViewType:AYGuideViewTypeFiction];
        LEWeakSelf(self)
        _guideManager.guideFinish = ^{
            LEStrongSelf(self)
            self.tableView.tableHeaderView =[self lanterSlideView];
            self.view.userInteractionEnabled =YES;
            self.view.superview.userInteractionEnabled =YES;
        };

    }
}
#pragma mark - network -
-(void)loadFictionList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    if(!completeBlock)
    {
        [self showHUD];
    }
    [_viewModel getFictionListDataByAction:refresh success:^{
        if(!completeBlock)
        {
            [self hideHUD];
        }
        [self reloadSectons:@"热门畅销"];

        if (completeBlock) {
            completeBlock();
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        if(!completeBlock)
        {
            [self hideHUD];
        }
        if (completeBlock) {
            completeBlock();
        }
    }];
}
-(void)loadFreeFictionList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    [_viewModel getFictionFreeListDataByAction:refresh success:^(long  endTime) {
        if(!completeBlock)
        {
            [self hideHUD];
        }
        self.endTime = endTime;
        [self reloadSectons:@"免费专区"];
        
        if (completeBlock) {
            completeBlock();
        }
    }failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        if(!completeBlock)
        {
            [self hideHUD];
        }
        if (completeBlock) {
            completeBlock();
        }
    }];
}
-(void)loadCartoonFictionList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    [_viewModel getRecommendCartoonDataByAction:refresh success:^() {
        if(!completeBlock)
        {
            [self hideHUD];
        }
        [self reloadSectons:@"精品漫画"];
        [self.tableView setContentOffset:CGPointMake(0, 0)];
        if (completeBlock) {
            completeBlock();
        }
    }failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        if(!completeBlock)
        {
            [self hideHUD];
        }
        if (completeBlock) {
            completeBlock();
        }
    }];
}
-(void)loadTimeFreeFictionList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    [_viewModel getTimeFictionFreeListDataByAction:refresh success:^(long  endTime) {
        if(!completeBlock)
        {
            [self hideHUD];
        }
        self.endTime = endTime;
        [self reloadSectons:@"限时免费"];
        
        if (completeBlock) {
            completeBlock();
        }
    }failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        if(!completeBlock)
        {
            [self hideHUD];
        }
        if (completeBlock) {
            completeBlock();
        }
    }];
}
-(void)loadRecomendList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    [_viewModel getRecommendFictionListDataByAction:YES  success:^{
        [self reloadSectons:@"最新推荐"];
        [self configureGuide];

            if (completeBlock) {
                completeBlock();
            }
        
        } failure:^(NSString * _Nonnull errorString) {
            [self hideHUD];
            occasionalHint(errorString);
            if (completeBlock) {
                completeBlock();
            }
        }];
}
-(void)loadBannerList
{
    [_viewModel getFictionBannerDataByAction:^{
        [self.lanterSlideView reloadData];

    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}

-(void)reloadSectons:(NSString*)title
{
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.viewModel getSectionIndex:title]] withRowAnimation:UITableViewRowAnimationNone];       }];
}
#pragma mark - LETableView Configurate
- (LERefreshControl *) topRefreshControl {
    return [ZWTopRefreshControl controlWithAdsorb];
}
- (LERefreshControl *) bottomRefreshControl {
    return [ZWBottomRefreshControl control];
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
    if ([[self.viewModel getSectionTitle:indexPath.section] isEqualToString:@"最新推荐"])
    {
        AYFictionHorizontalScrollAnimateTableViewCell* cell=   LEGetCellForTable([AYFictionHorizontalScrollAnimateTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
    }
    else if ([[self.viewModel getSectionTitle:indexPath.section] isEqualToString:@"热门畅销"])
    {
        AYFictionTableViewCell* cell=   LEGetCellForTable([AYFictionTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
    }
    else
    {
        AYFictionThreeTableViewCell* cell=   LEGetCellForTable([AYFictionThreeTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    id object = [self.viewModel objectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if(!object)
    {
        return nil;
    }
    else if([object isKindOfClass:NSArray.class])
    {
        NSArray *objArray =object;
        if(objArray.count<=0)
        {
            return nil;
        }
    }
    
    if (section==1)
    {

        AYFreeHeadView *headView = [[AYFreeHeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40) endTime:self.endTime];
        headView.backgroundColor = UIColorFromRGB(0xFFE4E1);
        [headView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYFictionEidterRecommendViewController parameters:@(YES)];
        }];
        return headView;
    }
    else
    {
        AYCommonHeadView *headView = [[AYCommonHeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40) title:[_viewModel getSectionTitle:section] icon:[_viewModel getSectionIcon:section]];
        LEWeakSelf(self)
        [headView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            LEStrongSelf(self)
            if([[self.viewModel getSectionTitle:section] isEqualToString:@"最新推荐"])
            {
                    [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYFictionEidterRecommendViewController parameters:@(NO)];
            }
            else
            {
               if([[self.viewModel getSectionTitle:section] isEqualToString:@"免费专区"])
               {
                   [self bookMailViewController].currentIndex=1;
               }
               else if([[self.viewModel getSectionTitle:section] isEqualToString:@"精品漫画"])
                {
                    [self bookMailViewController].currentIndex=2;
                }
               else if([[self.viewModel getSectionTitle:section] isEqualToString:@"限时免费"])
               {
                    [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYFictionEidterRecommendViewController parameters:@(YES)];
               }
            }
        }];
        return headView;
    }
    //return nil;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.viewModel objectForIndexPath:indexPath];
    if(!object)
    {
        return 0;
    }
    else if([object isKindOfClass:NSArray.class])
    {
        NSArray *objArray =object;
        if(objArray.count<=0 || (objArray.count<=2 && indexPath.section==0))
        {
            return 0;
        }
    }
    CGFloat cellHeight =0.01f;
    if (indexPath.section==0)
    {
        cellHeight =LEGetHeightForCellWithObject(AYFictionHorizontalScrollAnimateTableViewCell.class, object,nil);
    }
    else if (indexPath.section==4)
    {
         cellHeight =LEGetHeightForCellWithObject(AYFictionTableViewCell.class, object,nil);
    }
    else
    {
         cellHeight =LEGetHeightForCellWithObject(AYFictionThreeTableViewCell.class, object,nil);
    }

    return  cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //没有数据就为0
    id object = [self.viewModel objectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if(!object)
    {
        return 0;
    }
    else if([object isKindOfClass:NSArray.class])
    {
        NSArray *objArray =object;
        if(objArray.count<=0 || (objArray.count<=2 && section==0))
        {
            return 0;
        }
        
    }
    return 40;
}
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = [_viewModel objectForIndexPath:indexPath];
    if ([model isKindOfClass:AYFictionModel.class]) {
        [ZWREventsManager sendViewControllerEvent:kEventAYFictionDetailViewController parameters:model];
        
    }
    else if ([model isKindOfClass:AYCartoonModel.class])
    {
        [ZWREventsManager sendViewControllerEvent:kEventAYNewCartoonDetailViewController parameters:model];
    }

}
//headerview  不悬停
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(velocity.y>0)
    {
        [[self bookMailViewController] showNavagationBar:NO animate:YES];
    }
    else
    {
        [[self bookMailViewController] showNavagationBar:YES animate:YES];
    }
}
#pragma mark - LELazyLoadDelegate
- (void) leTableRefreshChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:YES complete:completeBlock];
    
}

- (void) leTableLoadMoreChokeAction:(void (^)(void))completeBlock {
    [self leTableChockAction:NO complete:completeBlock];
}

- (BOOL) leTableLoadNotAnyMore {
    return self.viewModel.isNotAnyMoreData;
}

- (void) leTableChockAction : (BOOL) isRefresh complete : (void (^)(void)) completeBlock {
       [self loadFictionList:isRefresh complete:completeBlock];
    if (isRefresh)
    {
        [self loadBannerList];
        [self loadRecomendList:YES complete:nil];
        [self loadFreeFictionList:YES complete:nil];
        [self loadTimeFreeFictionList:YES complete:nil];
        [self loadCartoonFictionList:YES complete:nil];
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
        LEImageSet(imageView,fictionModle.bannerImageUrl, @"banner_default");
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        return imageView;
    }
    else
    {
        LEImageSet((UIImageView*)view, fictionModle.bannerImageUrl, @"banner_default");
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
-(LERotateScrollView*)lanterSlideView
{
    if (!_lanterSlideView)
    {
        LERotateScrollView * rotateView = [LERotateScrollView view];
        rotateView.dataSource = self;
        rotateView.delegate = self;
        _lanterSlideView = rotateView;
       rotateView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth*9/21.0f);
    }
    return _lanterSlideView;
}

-(AYBookmailViewController*)bookMailViewController
{
    UIViewController *nextViewController = self.parentViewController;
    while (nextViewController) {
        if([nextViewController isKindOfClass:AYBookmailViewController.class])
        {
            return (AYBookmailViewController*)nextViewController;
        }
        nextViewController = nextViewController.parentViewController;
    }
    return nil;
}
#pragma mark - ZWR2SegmentViewControllerProtocol -

+ (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewControllerWithSegmentRegisterItem : (id) object segmentItem : (ZWR2SegmentItem *) segmentItem {
    return [self controller];
}
#pragma mark - ZWRChainReactionProtocol
/**当前选中状态又重新选择了这个tabbar，联动效应事件 */
- (void) zwrChainReactionEventTabBarDidReClickAfterAppear {
    [self.tableView refreshing];
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
- (void) segmentDidLoadViewController {
    //加载列表数据
    [self loadBannerList];
    [self.tableView reloadData];
    [self loadRecomendList:YES complete:nil];
    [self loadFreeFictionList:YES complete:nil];
    [self loadFictionList:YES complete:nil];
    [self loadTimeFreeFictionList:YES complete:nil];
    [self loadCartoonFictionList:YES complete:nil];
}
- (NSString *) uniqueIdentifier {
    return @"1";
}

- (NSString *) segmentTitle {
    return AYLocalizedString(@"小说");
}
@end
