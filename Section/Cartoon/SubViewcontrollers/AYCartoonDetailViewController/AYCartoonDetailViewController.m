//
//  AYCartoonDetailViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonDetailViewController.h"
#import "AYCartoonDetailModel.h"
#import "AYCartoonDetailViewModel.h"
#import "UIImage+YYAdd.h"
#import "AYShareView.h"
#import "AYCartoonDetailTableViewCell.h"
#import "AYFictionDetailTableViewCell.h"
#import "AYCartoonContainViewController.h"

@interface AYCartoonDetailViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, readwrite, strong) AYCartoonDetailViewModel * viewModel; //数据源
@property (nonatomic, strong) AYCartoonModel * cartoonModel; //数据源
@property (nonatomic, strong) AYCartoonContainViewController * cartoonContainViewController; //数据源

@end

@implementation AYCartoonDetailViewController
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
    self.viewModel = [AYCartoonDetailViewModel viewModelWithViewController:self];

}
- (void) configurateUI
{

}
-(void)configureNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefresh:) name:kNotificationDetailNeedRefreshEvents object:nil];
    
}
#pragma mark - network -
-(void)loadCartoonDetailData:(BOOL)first
{
    if (first) {
        [self showHUD];

    }
    [_viewModel getCartoonDetailDataByCartoonModel:self.cartoonModel complete:^{
        if ([self cartoonContainViewController]) {
            [self.cartoonContainViewController setSurfaceplot:self.viewModel.cartoonDetailModel.cartoonSurfaceplot];
        }
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
    AYCartoonDetailModel *detailModel = [object safe_objectAtIndex:1];
    if([str isEqualToString:@"menu"])
    {
        NSDictionary *paraDic = [NSDictionary dictionaryWithObjectsAndKeys:detailModel.cartoonTitle,@"title",detailModel.cartoonID,@"id", nil];
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
    if ([self cartoonContainViewController]) {
        [self.cartoonContainViewController subScrollViewDidScroll:scrollView];
    }
}
#pragma mark -event handel -
-(void)handleRefresh:(NSNotification*)notify
{
    [self loadCartoonDetailData:NO];
}
#pragma mark- getter and setter -
-(AYCartoonContainViewController*)cartoonContainViewController
{
    if (!_cartoonContainViewController)
    {
        UIViewController *nextViewController = self.parentViewController;
        while (nextViewController) {
            if ([nextViewController isKindOfClass:AYCartoonContainViewController.class]) {
                return (AYCartoonContainViewController*)nextViewController;
            }
            nextViewController = nextViewController.parentViewController;
        }
    }
    return _cartoonContainViewController;
}
#pragma mark - ZWR2SegmentViewControllerProtocol -

+ (UIViewController<ZWR2SegmentViewControllerProtocol> *) viewControllerWithSegmentRegisterItem : (id) object segmentItem : (ZWR2SegmentItem *) segmentItem {
    return [[AYCartoonDetailViewController alloc] initWithPara:object];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self cartoonContainViewController]) {
            [self.cartoonContainViewController switchScrollView:self.tableView];
        }
    });

}
- (void) segmentViewWillDisappear {
    
}
/**
 *  当进入显示栏位的时候将会调用此方法，可实现相关逻辑
 */
- (void) segmentDidLoadViewController {
    //加载列表数据
    [self.tableView launchRefreshing];

}

- (NSString *) uniqueIdentifier {
    return @"0";
}

- (NSString *) segmentTitle {
    return AYLocalizedString(@"详情");
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYCartoonDetailViewController controller];
}

@end
