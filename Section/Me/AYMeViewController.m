//
//  AYMeViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYMeViewController.h"
#import "AYMeViewModel.h"
#import "AYMeTableViewCell.h"
#import "AYSignInView.h" //签到view
#import "AYShareView.h" 
#import "AYInvationViewController.h"
#import "AYSignManager.h"

@interface AYMeViewController ()
@property (nonatomic, readwrite, strong) AYMeViewModel * viewModel; //数据源
@end

@implementation AYMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurateTableView];
    [self configurateData];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([AYUserManager isUserLogin] ) {
        [self.tableView reloadData];
    }

    //由于任务栏隐藏了导航栏，会改变当前view的高度 所以要重置高度
    self.view.height = self.parentViewController.view.height-Height_TapBar;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Init
- (void) configurateTableView{
    _AYMeCellsRegisterToTable(self.tableView, 0);
    self.tableView.showsVerticalScrollIndicator =NO;
    self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone;

    //消除系统分割线
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    [self.tableView setTableFooterView:footView];
    self.view.backgroundColor = RGB(243, 243, 243);
}
- (void) configurateData {
    self.viewModel = [AYMeViewModel viewModelWithViewController:self];
}
#pragma mark - fb -

-(void)evokeFacebook
{
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/1699295950216055"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL])
    {
        [[UIApplication sharedApplication] openURL:facebookURL];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com"]];
    }
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
    UITableViewCell *cell = _AYMeGetCellByItem(object, 0, tableView, indexPath, ^(UITableViewCell *fetchCell) {

    });
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.viewModel objectForIndexPath:indexPath];
    return _AYMeCellHeightByItem(object, indexPath, 0);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.viewModel objectForIndexPath:indexPath];
    if ([object isEqualToString:@"FB在线客服"])
    {
        [self evokeFacebook];
    }
    else if ([object isEqualToString:@"常见问题"])
    {
//        [ZWREventsManager sendViewControllerEvent:kEventAYQuestionAndAnswerViewController parameters:nil ];
        LEWeakSelf(self)
        [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYQuestionAndAnswerViewController parameters:nil animated:YES callBack:^(id obj) {
            LEStrongSelf(self)
            self.tabBarController.selectedIndex =2;
        }];

    }
    else if ([object isEqualToString:@"意见反馈"])
    {
        [ZWREventsManager sendViewControllerEvent:kEventAYAdverseViewController parameters:nil];
    }
    else if ([object isEqualToString:@"作者投稿"])
    {
        NSString *url = [NSString stringWithFormat:@"%@home/active/writer",[AYUtitle getServerUrl]];
          [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:url animate:YES];
    }
    else if ([object isEqualToString:@"设置"])
    {
        [ZWREventsManager sendViewControllerEvent:kEventAYSettingViewController parameters:nil];
    }
    else if ([object isEqualToString:@"金币明细"])
    {
        
        if ([AYUserManager isUserLogin])
        {
            [ZWREventsManager sendViewControllerEvent:kEventAYRecordSegmentViewController parameters:nil];
        }
        else
        {
            [ZWREventsManager sendViewControlleWithCallBackEvent:kEventAYLogiinViewController parameters:nil animated:YES callBack:^(id obj) {
             [ZWREventsManager sendViewControllerEvent:kEventAYRecordSegmentViewController parameters:nil];      }];
        }

    }
    else if ([object isEqualToString:@"head"])
    {
        if (![AYUserManager isUserLogin]) {
            //登录
            [ZWREventsManager sendViewControllerEvent:kEventAYLogiinViewController parameters:nil];
        }
    }
}
@end
