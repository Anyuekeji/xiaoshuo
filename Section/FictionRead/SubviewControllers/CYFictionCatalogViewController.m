//
//  CYFictionCatalogViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "CYFictionCatalogViewController.h"
#import "CYFictionChapterModel.h"
#import "LELineTableViewCell.h" //带下横线的cell
#import "AYFictionModel.h" //
#import "AYFictionCatlogManager.h" //目录管理

@interface CYFictionCatalogViewController ()
@property(nonatomic,strong)NSMutableArray<CYFictionChapterModel*>  *chapterArray;// 小说章节数据
@property(nonatomic,strong)NSString  *bookId;// 小说章节数据
@property(nonatomic,strong)NSString  *bookTitle;// 小说标题

@end

@implementation CYFictionCatalogViewController
-(instancetype)initWithPara:(NSDictionary*)para;
{
    self = [super init];
    if (self) {
        _bookId = para[@"id"];
        _bookTitle = para[@"title"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateData];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadFictionCatalogData];

}
#pragma mark - Init
- (void) configurateTableView{
    LERegisterCellForTable(LELineTableViewCell.class, self.tableView);
    self.tableView.showsVerticalScrollIndicator =NO;
    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.tableView setTableFooterView:footView];
    self.view.backgroundColor = RGB(243, 243, 243);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}
- (void) configurateData
{
    self.title = AYLocalizedString(@"目录");
    _chapterArray = [NSMutableArray new];
}
- (void) configurateUI
{
    
}
#pragma mark - db -

#pragma mark - network -
-(void)loadFictionCatalogData
{
    [self showHUD];
    
    [[AYFictionCatlogManager shared] fetchFictionCatlogWithFictionId:self.bookId refresh:NO success:^(NSArray<CYFictionChapterModel *> * _Nonnull fictionCatlogArray) {
        [self hideHUD];
        if (fictionCatlogArray) {
            [self.chapterArray removeAllObjects];
            [self.chapterArray addObjectsFromArray:fictionCatlogArray];
            [self.tableView reloadData];
        }
    } failure:^(NSString * _Nonnull errorString) {
        [self hideHUD];
        occasionalHint(errorString);
    }];

}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chapterArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = LEGetCellForTable(LELineTableViewCell.class, tableView, indexPath);
    CYFictionChapterModel *chapterModle = [_chapterArray safe_objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = RGB(51, 51, 51);
    cell.textLabel.text = [NSString stringWithFormat:@" %@",chapterModle.fictionSectionTitle];
    if ([chapterModle.needMoney integerValue]>0)
    {
        UIButton *lockBtn = (UIButton*)cell.accessoryView;
        if (!lockBtn)
        {
            lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            lockBtn.frame = CGRectMake(0, 0, 18, 21);
            cell.accessoryView = lockBtn;
        }
        if (![chapterModle.unlock boolValue])
        {
            [lockBtn setImage:LEImage(@"read_lock") forState:UIControlStateNormal];
            [lockBtn setImage:LEImage(@"read_lock") forState:UIControlStateHighlighted];
        }
        else
        {
            [lockBtn setImage:LEImage(@"read_unlock") forState:UIControlStateNormal];
            [lockBtn setImage:LEImage(@"read_unlock") forState:UIControlStateHighlighted];
        }
    }
    else
    {
        cell.accessoryView = nil;
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AYFictionModel *fictionModel = [AYFictionModel new];
    fictionModel.fictionID = self.bookId;
    fictionModel.fictionTitle = self.bookTitle;
    fictionModel.startChatperIndex = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [ZWREventsManager sendViewControllerEvent:kEventAYFuctionReadViewController parameters:fictionModel];
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters && [parameters isKindOfClass:NSDictionary.class]) {
        return YES;
    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[CYFictionCatalogViewController alloc] initWithPara:parameters];
}
@end
