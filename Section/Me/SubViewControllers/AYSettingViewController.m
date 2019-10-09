//
//  AYSettingViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/17.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYSettingViewController.h"
#import "AYMeTableViewCell.h"
#import "AppDelegate.h"
#import "LERMLRealm.h"
@interface AYSettingViewController ()
@property(nonatomic,strong)NSArray<NSString*> *itemArray;
@end

@implementation AYSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateData];
    // Do any additional setup after loading the view.
}

#pragma mark - Init
- (void) configurateTableView
{
    _AYMeCellsRegisterToTable(self.tableView, 1);
    self.tableView.showsVerticalScrollIndicator =NO;
    
    self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone;

    if ([AYUserManager isUserLogin])
    {
        UIButton *loginOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginOutBtn setTitle:AYLocalizedString(@"退出") forState:UIControlStateNormal];
        [loginOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginOutBtn.backgroundColor = RGB(250, 85, 108);
        loginOutBtn.layer.cornerRadius = 18;
        loginOutBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        loginOutBtn.frame = CGRectMake(15, 30, ScreenWidth-30, 36);
        LEWeakSelf(self)
        [loginOutBtn addAction:^(UIButton *btn) {
            LEStrongSelf(self)
            [self userLoginOut];
        }];
        
        //消除系统分割线
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 96)];
        [footView addSubview:loginOutBtn];
        [self.tableView setTableFooterView:footView];
    }
    else
    {
        [self.tableView setTableFooterView:[UIView new]];

    }
}
- (void) configurateData {
    _itemArray = @[@"lock",@"清理缓存",@"版权声明",@"关于"];
    self.title = AYLocalizedString(@"设置");
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
    UITableViewCell *cell = _AYMeGetCellByItem(object, 1, tableView, indexPath, ^(UITableViewCell *fetchCell) {

    });
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object =[_itemArray objectAtIndex:indexPath.row];
    return _AYMeCellHeightByItem(object, indexPath, 1);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object =[_itemArray objectAtIndex:indexPath.row];
    //清理缓存
    if ([object isEqualToString:@"清理缓存"]) {
        [self showHUD];
        [AYUtitle cleanCache];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHUD];
            [self.tableView reloadData];
            [LERMLRealm launchProgress];
            occasionalHint(AYLocalizedString(@"已清除缓存"));
        });
    }
    else if ([object isEqualToString:@"关于"])
    {
        [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYAboutAppViewController parameters:nil];
    }
    else if ([object isEqualToString:@"版权声明"])
    {
        NSString *copyRightUrl  = [NSString stringWithFormat:@"%@%@",[AYUtitle getServerUrl],@"home/privacy/copyright"];

        [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:copyRightUrl animate:YES];
    }
}
#pragma mark - 退出登录 -
-(void)userLoginOut
{
    [AYUserManager logout];
    [LERMLRealm switchRealm];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate changeToLoginOrMainViewController:NO];
    [ZWNetwork post:@"HTTP_User_Loginout" parameters:nil success:^(id record)
     {

     }
    failure:^(LEServiceError type, NSError *error) {
    
     }];
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    return YES;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [AYSettingViewController controller];
}
@end
