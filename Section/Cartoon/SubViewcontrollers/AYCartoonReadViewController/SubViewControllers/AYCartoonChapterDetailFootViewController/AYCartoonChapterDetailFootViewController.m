//
//  AYCartoonChapterDetailFootViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonChapterDetailFootViewController.h"
#import "AYCartoonChapterDetailFooterViewModel.h"
#import "AYFictionDetailTableViewCell.h"
#import "AYCartoonChapterModel.h"

@interface AYCartoonChapterDetailFootViewController ()
@property (nonatomic, readwrite, strong) AYCartoonChapterDetailFooterViewModel * viewModel; //数据源
@property(nonatomic,strong)AYCartoonChapterModel *chapterModel;

@end

@implementation AYCartoonChapterDetailFootViewController
-(instancetype)initWithChapterModel:(AYCartoonChapterModel*)chapterModel
{
    self = [super init];
    if (self)
    {
        _chapterModel = chapterModel;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateUI];
    [self configurateData];
    // Do any additional setup after loading the view.
}

#pragma mark - Init
- (void) configurateTableView{
    _AYFictionDetailCellsRegisterToTable(self.tableView, 2);
    self.tableView.showsVerticalScrollIndicator =NO;
    self.tableView.bounces = NO;
    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.tableView setTableFooterView:footView];
    self.view.backgroundColor = RGB(255, 255, 255);
}
- (void) configurateData {
    self.viewModel = [AYCartoonChapterDetailFooterViewModel viewModelWithViewController:self];
    _viewModel.chapterModel = _chapterModel;
    [self.tableView reloadData];
}
- (void) configurateUI
{
    
}
#pragma mark - network -

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.viewModel objectForIndexPath:indexPath];
    UITableViewCell *cell = _AYFictionDetailGetCellByItem(object, 2, tableView, indexPath, ^(UITableViewCell *fetchCell) {
        
    });
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.viewModel objectForIndexPath:indexPath];
    return _AYFictionDetailCellHeightByItem(object, indexPath, 2);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
#pragma mark - getter and setter -

@end
