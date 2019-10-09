//
//  AYFreeBookViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/14.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYFreeBookViewController.h"
#import "LERotateScrollView.h"
#import "AYFictionViewModle.h"
#import "AYFictionTableViewCell.h"
#import "AYADSkipManager.h" //banner跳转管理
#import "AYBannerModel.h"
#import "AYBookModel.h"
#import "AYBookmailViewController.h"

@interface AYFreeBookViewController ()<LERotateScrollViewDataSource, LERotateScrollViewDelegate>
@property (nonatomic, readwrite, strong) AYFictionViewModle * viewModel; //数据处理
@property (nonatomic, strong) LERotateScrollView *lanterSlideView; //顶部轮播
@property (nonatomic, assign) BOOL search; //是否来自搜索

@end

@implementation AYFreeBookViewController
-(instancetype)initWithPara:(BOOL)search
{
    self = [super init];
    if (self) {
        self.search = search;
    }
    return self;
}

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
    LERegisterCellForTable([AYFreeBookTableViewCell class], self.tableView);
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    if (!self.search)
    {
        self.tableView.tableHeaderView = [self lanterSlideView];
    }
}
- (void) configurateData
{
    self.viewModel = [AYFictionViewModle viewModelWithViewController:self];
    self.viewModel.viewType = AYFictionViewTypeFree;
}
#pragma mark - network -
-(void)loadFreeFictionList:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    [_viewModel getFictionFreeListDataByAction:refresh success:^(long  endTime) {
     
        [self.tableView reloadData];
        if (completeBlock) {
            completeBlock();
        }
    }failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        if (completeBlock) {
            completeBlock();
        }
    }];
}
-(void)loadBannerList
{
    [_viewModel getFreeBookBannerDataByAction:^{
        [self.lanterSlideView reloadData];
        
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}
-(void)loadSearchListWithText:(NSString*)seachText refresh:(BOOL)refresh  complete:(void(^)(void)) completeBlock
{
    [self.viewModel getFictionListDataBySearchText:seachText refresh:refresh success:^{
        [self.tableView reloadData];
        if (completeBlock) {
            completeBlock();
        }
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
        if (completeBlock) {
            completeBlock();
        }
    }];
}
#pragma mark - LETableView Configurate
- (LERefreshControl *) topRefreshControl {
    if (self.search) {
        return nil;
    }
    return [ZWTopRefreshControl controlWithAdsorb];
}
- (LERefreshControl *) bottomRefreshControl {
    if (self.search) {
        return nil;
    }
    return [ZWBottomRefreshControl control];
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
    id object = [self.viewModel objectForIndexPath:indexPath];
    AYFreeBookTableViewCell* cell=   LEGetCellForTable([AYFreeBookTableViewCell class], tableView, indexPath);
    [cell fillCellWithModel:object freeFlag:(self.search?YES:NO)];
    return cell;
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
        if(objArray.count<=0)
        {
            return 0;
        }
    }
    CGFloat cellHeight =0.01f;
    cellHeight =LEGetHeightForCellWithObject(AYFictionTableViewCell.class, object,nil);
    return  cellHeight;
}
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AYBookModel *model = [_viewModel objectForIndexPath:indexPath];
    model.bookDestinationType= @(1);
    [AYADSkipManager adSkipWithModel:model];
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
    if (!_search) {
        [self loadBannerList];
    }
    [self loadFreeFictionList:isRefresh complete:completeBlock];
    
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
    [self loadFreeFictionList:YES complete:nil];
}

- (NSString *) uniqueIdentifier {
    return @"2";
}

- (NSString *) segmentTitle {
    return AYLocalizedString(@"免费");
}
@end
