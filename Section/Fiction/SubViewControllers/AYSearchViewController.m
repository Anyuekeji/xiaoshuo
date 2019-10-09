//
//  AYSearchViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/14.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYSearchViewController.h"
#import "EVNCustomSearchBar.h"
#import "AYFictionViewModle.h"
#import "AYFictionTableViewCell.h"
#import "AYFictionModel.h"
#import "AYCartoonViewModel.h"
#import "AYCartoonTableViewCell.h"
#import "AYCartoonModel.h"

#define kEVNScreenNavigationBarHeight 44.f
#define kEVNScreenTopStatusNaviHeight (kEVNScreenStatusBarHeight + kEVNScreenNavigationBarHeight)

#define kEVNScreenTabBarHeight (kEVN_iPhoneX ? (49.f+34.f) : 49.f)


@interface AYSearchViewController ()<EVNCustomSearchBarDelegate>
/**
 * 导航搜索框EVNCustomSearchBar
 */
@property (strong, nonatomic) EVNCustomSearchBar *searchBar;
//是否是小说
@property (assign, nonatomic) BOOL fiction;

@property (nonatomic, readwrite, strong) AYFictionViewModle * fictionViewModel; //小说数据处理
@property (nonatomic, readwrite, strong) AYCartoonViewModel * cartoonViewModel; //小说数据处理
@end

@implementation AYSearchViewController
-(instancetype)initWithParas:(BOOL)para
{
    self = [super init];
    if (self) {
        _fiction = para;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSearchBar];
    [self configurateTableView];
    [self configurateData];
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark: 设置顶部导航搜索部分
- (void)initSearchBar
{
    self.navigationItem.titleView = self.searchBar;
    if (@available(iOS 11.0, *))
    {
        [self.searchBar.heightAnchor constraintLessThanOrEqualToConstant:kEVNScreenNavigationBarHeight].active = YES;
    }
}
#pragma mark - Init
- (void) configurateTableView {
    if (_fiction)
    {
       LERegisterCellForTable([AYFictionTableViewCell class], self.tableView);
    }
    else
    {
        LERegisterCellForTable([AYCartoonTableViewCell class], self.tableView);
    }
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //关闭selfSizing功能，会影响reloaddata以后的contentoffset  ios11默认开启
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
- (void) configurateData
{
    if (_fiction) {
          self.fictionViewModel = [AYFictionViewModle viewModelWithViewController:self];
        self.fictionViewModel.viewType = -1;
    }
    else
    {
        self.cartoonViewModel = [AYCartoonViewModel viewModelWithViewController:self];
        self.cartoonViewModel.viewType = -1;


    }
  
}
#pragma mark - network -
-(void)loadSearchListWithText:(NSString*)searchText  refresh:(BOOL)refresh complete:(void(^)(void)) completeBlock
{
    if (searchText.length<=0) {
        if (completeBlock) {
            completeBlock();
        }
        return;
    }
   // [self showHUD];
    if (_fiction) {
        [_fictionViewModel getFictionListDataBySearchText:searchText refresh:refresh  success:^{
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
    else
    {
        [_cartoonViewModel getCartoonListBySearchText:searchText refresh:refresh  success:^{
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

    return _fiction?[_fictionViewModel numberOfSections]:[_cartoonViewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  _fiction?[_fictionViewModel numberOfRowsInSection:section]:[_cartoonViewModel numberOfRowsInSection:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_fiction)
    {
        id object = [self.fictionViewModel objectForIndexPath:indexPath];
        AYFictionTableViewCell* cell=   LEGetCellForTable([AYFictionTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
    }
    else
    {
        id object = [self.cartoonViewModel objectForIndexPath:indexPath];
        AYCartoonTableViewCell* cell=   LEGetCellForTable([AYCartoonTableViewCell class], tableView, indexPath);
        [cell fillCellWithModel:object];
        return cell;
    }

}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_fiction)
    {
        id object = [self.fictionViewModel objectForIndexPath:indexPath];
        CGFloat cellHeight =LEGetHeightForCellWithObject(AYFictionTableViewCell.class, object,nil);
        return  cellHeight;
    }
    else
    {
        id object = [self.cartoonViewModel objectForIndexPath:indexPath];
        CGFloat cellHeight =LEGetHeightForCellWithObject(AYCartoonTableViewCell.class, object,nil);
        return  cellHeight;
    }

}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    if (_fiction)
    {
        AYFictionModel *model = [_fictionViewModel objectForIndexPath:indexPath];
        [ZWREventsManager sendViewControllerEvent:kEventAYFictionDetailViewController parameters:model];
    }
    else
    {
        AYCartoonModel *cartoonModel  = [_cartoonViewModel objectForIndexPath:indexPath];
        [ZWREventsManager sendViewControllerEvent:kEventAYCartoonContainViewController parameters:cartoonModel];
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
    return   _fiction?_fictionViewModel.isNotAnyMoreData:_cartoonViewModel.isNotAnyMoreData;
}

- (void) leTableChockAction : (BOOL) isRefresh complete : (void (^)(void)) completeBlock {
    [self loadSearchListWithText:_searchBar.text refresh:isRefresh  complete:completeBlock];
}
#pragma mark: getter method EVNCustomSearchBar
- (EVNCustomSearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[EVNCustomSearchBar alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, ScreenWidth, kEVNScreenNavigationBarHeight)];
        
        _searchBar.backgroundColor = [UIColor clearColor]; // 清空searchBar的背景色
        _searchBar.iconImage = [UIImage imageNamed:@"EVNCustomSearchBar.bundle/searchImageBlue.png"];;
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignLeft;
        [_searchBar setPlaceholder:AYLocalizedString(@"请输入关键字")];  // 搜索框的占位符
        _searchBar.placeholderColor = UIColorFromRGB(0x666666);
        [_searchBar.cancelButton setTitle:AYLocalizedString(@"取消") forState:UIControlStateNormal];
        [_searchBar.cancelButton setTitle:AYLocalizedString(@"取消") forState:UIControlStateHighlighted];

        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
}

#pragma mark: EVNCustomSearchBar delegate method
- (BOOL)searchBarShouldBeginEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidBeginEditing:(EVNCustomSearchBar *)searchBar
{
    _fiction?[_fictionViewModel clearList]:[_cartoonViewModel clearList];
    [self.tableView reloadData];
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (BOOL)searchBarShouldEndEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidEndEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)searchBar:(EVNCustomSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadSearchListWithText:searchBar.text refresh:YES complete:nil];
}

- (BOOL)searchBar:(EVNCustomSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self loadSearchListWithText:searchBar.text refresh:YES complete:nil];
}

- (void)searchBarCancelButtonClicked:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}



#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYSearchViewController alloc] initWithParas:[parameters boolValue]];
}
@end
