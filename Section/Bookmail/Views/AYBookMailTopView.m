//
//  AYBookMailTopView.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/31.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYBookMailTopView.h"
#import "EVNCustomSearchBar.h" //搜索框
@interface AYBookMailTopView ()<EVNCustomSearchBarDelegate>
/**
 * 导航搜索框EVNCustomSearchBar
 */
@property (strong, nonatomic) EVNCustomSearchBar *searchBar;
@end
@implementation AYBookMailTopView

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    [self addSubview:self.searchBar];
}
#pragma mark - getter -
- (EVNCustomSearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[EVNCustomSearchBar alloc] initWithFrame:CGRectMake(15, STATUS_BAR_HEIGHT+7, ScreenWidth-30,30)];
        _searchBar.top =STATUS_BAR_HEIGHT+ (self.height-STATUS_BAR_HEIGHT-self.searchBar.height)/2.0f;
        _searchBar.backgroundColor = [UIColor clearColor]; // 清空searchBar的背景色
        _searchBar.iconImage = [UIImage imageNamed:@"search_img"];
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignCenter;
        [_searchBar setPlaceholder:AYLocalizedString(@"搜索书名，作者")];  // 搜索框的占位符
        _searchBar.placeholderColor = UIColorFromRGB(0xCCCCCC);
        _searchBar.textFont =[UIFont systemFontOfSize:14];
        _searchBar.delegate = self; // 设置代理
        //[_searchBar sizeToFit];
    }
    return _searchBar;
}
#pragma mark: EVNCustomSearchBar delegate method
- (void)searchBarTextDidBeginEditing:(EVNCustomSearchBar *)searchBar
{
    [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYSearchViewController parameters:nil];
    [searchBar resignFirstResponder];
}
@end
