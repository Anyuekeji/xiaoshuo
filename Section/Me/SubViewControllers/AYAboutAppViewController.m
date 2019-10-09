//
//  AYAboutAppViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/1/9.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYAboutAppViewController.h"
#import "AYMeTableViewCell.h"

@interface AYAboutAppViewController ()
@property(nonatomic,strong)NSArray<NSString*> *itemArray;
@end

@implementation AYAboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configurateTableView];
    [self configurateData];
    // Do any additional setup after loading the view.
}
#pragma mark - Init

-(void)configureUI
{
    self.view.backgroundColor = UIColorFromRGB(0xf7f7f7);
    UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 180)];
    UIImageView *iconImage = [UIImageView new];
    iconImage.image = LEImage(@"app_icon");
    iconImage.frame = CGRectMake((ScreenWidth-60)/2.0f, 50, 60, 60);
    [headView addSubview:iconImage];
    UILabel *titleLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:DEFAUT_NORMAL_FONTSIZE] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    titleLable.text =[AYUtitle getAppName];
    titleLable.frame = CGRectMake(50, iconImage.top+iconImage.height+3, ScreenWidth-100, 20);
    [headView addSubview:titleLable];
    self.tableView.tableHeaderView = headView;
}
- (void) configurateTableView
{
   self.tableView.showsVerticalScrollIndicator =NO;
   self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
   [self.tableView setTableFooterView:[UIView new]];
   LERegisterCellForTable(AYMeTableViewCell.class, self.tableView);
}
- (void) configurateData {
    _itemArray = @[@"版本",@"隐私策略"];
    self.title = AYLocalizedString(@"关于");
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object =[_itemArray objectAtIndex:indexPath.row];
    AYMeTableViewCell *cell = LEGetCellForTable(AYMeTableViewCell.class, tableView, indexPath);
    [cell filCellWithModel:object];
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object =[_itemArray objectAtIndex:indexPath.row];
    return  LEGetHeightForCellWithObject(AYMeTableViewCell.class, object, nil);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //隐私政策
    if (indexPath.row ==1) {
            [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:[NSString stringWithFormat:@"%@home/privacy/index",[AYUtitle getServerUrl]] animate:YES];
       // https://apiland.qrxs.cn/home/privacy/index
    }
}

#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYAboutAppViewController controller];
}
@end
