//
//  AYSearchViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/14.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYSearchViewController.h"
#import "EVNCustomSearchBar.h"
#import "AYFictionTableViewCell.h"
#import "AYSearchViewModel.h"
#import "AYFreeHeadView.h"
#import "AYBookModel.h" //书本model
#import "AYADSkipManager.h" //banner跳转管理
#import "AYFreeBookViewController.h" //免费
#import "AYFictionModel.h"

#define kEVNScreenNavigationBarHeight 44.f
#define kEVNScreenTopStatusNaviHeight (kEVNScreenStatusBarHeight + kEVNScreenNavigationBarHeight)

#define kEVNScreenTabBarHeight (kEVN_iPhoneX ? (49.f+34.f) : 49.f)


@interface AYSearchViewController ()<EVNCustomSearchBarDelegate>
/**
 * 导航搜索框EVNCustomSearchBar
 */
@property (strong, nonatomic) EVNCustomSearchBar *searchBar;
@property (strong, nonatomic) AYFreeBookViewController *freeBookViewController;

@property (nonatomic, readwrite, strong) AYSearchViewModel * viewModel; //数据处理

@end

@implementation AYSearchViewController
//-(instancetype)initWithParas:(BOOL)para
//{
//    self = [super init];
//    if (self) {
//    }
//    return self;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSearchBar];
    [self configurateCollectionView];
    [self.collectionView reloadData];
    [self configurateData];
    [self loadHotBook];
    [self loadHotSearchText];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
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
- (void) configurateCollectionView
{
    [self.collectionView registerClass:[AYHotSearchTableViewCell class] forCellWithReuseIdentifier:@"AYHotSearchTableViewCell"];
    //防止添加书架cell，因为复用被图片覆盖
    [self.collectionView registerClass:[AYFictionCollectionViewCell class] forCellWithReuseIdentifier:@"AYFictionCollectionViewCell"];
   self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[AYSearchHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AYSearchHeadView"];
}
- (void) configurateData
{
    self.viewModel = [AYSearchViewModel viewModelWithViewController:self];
}
-(void)reloadSectons:(NSInteger)section
{
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    }];
}
#pragma mark - network -
-(void)loadHotSearchText
{
    [_viewModel getHotSearchListDataByAction:YES success:^{
        [self reloadSectons:0];
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}
-(void)loadHotBook
{
    [_viewModel getHotBookListDataByAction:YES success:^{
        [self reloadSectons:1];
    } failure:^(NSString * _Nonnull errorString) {
        occasionalHint(errorString);
    }];
}
#pragma mark  - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_viewModel numberOfRowsInSection:section];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [_viewModel numberOfSections];
}
#pragma mark-  - UICollectionViewDelegate -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AYBookModel *obj = [_viewModel objectForIndexPath:indexPath];
    if ([obj isKindOfClass:AYBookModel.class]) {
        obj.bookDestinationType= @(2);
        [AYADSkipManager adSkipWithModel:obj];
    }
    else if ([obj isKindOfClass:AYFictionModel.class]) {
        [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYFuctionReadViewController parameters:obj];
    }

    

}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    id obj = [_viewModel objectForIndexPath:indexPath];

    if (indexPath.section ==0)
    {
        AYHotSearchTableViewCell *cell = (AYHotSearchTableViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"AYHotSearchTableViewCell" forIndexPath:indexPath];
        [cell filCellWithModel:obj row:indexPath.row];
        return cell;

    }
    else
    {
        AYFictionCollectionViewCell *cell = (AYFictionCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"AYFictionCollectionViewCell" forIndexPath:indexPath];
        [cell filCellWithModel:obj];
        return cell;

    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section ==0)
    {
        return CGSizeMake((ScreenWidth-30-10)/2.0f, 30);
    }
    else
    {
        
        CGFloat cellWidth =(ScreenWidth-2*15-2*20)/3.0f;
        return CGSizeMake(cellWidth, cellWidth*(142.0f/100.0f)+53);
    }
    
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        AYSearchHeadView *header =(AYSearchHeadView*) [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AYSearchHeadView" forIndexPath:indexPath];
        [header filCellWithModel:(indexPath.section==0)?AYLocalizedString(@"热门搜索"):AYLocalizedString(@"人气热书")];
        return header;
        
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if([_viewModel numberOfRowsInSection:section]<=0)
    {
        return CGSizeMake(self.view.bounds.size.width-30, 0);

    }
    return CGSizeMake(self.view.bounds.size.width-30, 50);
}
//这个是两行cell之间的间距（上下行cell的间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 15,0, 15);//分别为上、左、下、右
}
#pragma mark: getter method EVNCustomSearchBar
- (EVNCustomSearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[EVNCustomSearchBar alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, ScreenWidth, kEVNScreenNavigationBarHeight)];
        
        _searchBar.backgroundColor = [UIColor clearColor]; // 清空searchBar的背景色
        _searchBar.iconImage = [UIImage imageNamed:@"search_img"];;
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignLeft;
        [_searchBar setPlaceholder:AYLocalizedString(@"搜索书名，作者")];  // 搜索框的占位符
        _searchBar.placeholderColor = UIColorFromRGB(0xCCCCCC);
        _searchBar.textFont =[UIFont systemFontOfSize:14];
        [_searchBar.cancelButton setTitle:AYLocalizedString(@"取消") forState:UIControlStateNormal];
        [_searchBar.cancelButton setTitle:AYLocalizedString(@"取消") forState:UIControlStateHighlighted];

        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
}
-(AYFreeBookViewController*)freeBookViewController
{
    if (!_freeBookViewController)
    {
        _freeBookViewController = [[AYFreeBookViewController alloc] initWithPara:YES];
        _freeBookViewController.view.frame = self.view.bounds;
        [self addChildViewController:_freeBookViewController];
        [self.view addSubview:_freeBookViewController.view];
        
    }
    return _freeBookViewController;
}
#pragma mark: EVNCustomSearchBar delegate method
- (BOOL)searchBarShouldBeginEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidBeginEditing:(EVNCustomSearchBar *)searchBar
{

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
    if (searchText.length<=0) {
        [UIView animateWithDuration:0.3f animations:^{
            self.freeBookViewController.view.alpha = 0;

        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.freeBookViewController.view.alpha =1.0f;
            
        }];
        [self.freeBookViewController loadSearchListWithText:searchText refresh:YES complete:nil];
    }
}

- (BOOL)searchBar:(EVNCustomSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
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
    return [AYSearchViewController controller];
}
@end
