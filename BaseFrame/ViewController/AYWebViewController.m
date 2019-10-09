//
//  AYWebViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYWebViewController.h"

@interface AYWebViewController ()<LEWKWebViewDelegate>
@property(nonatomic,strong) NSString *url;
@end

@implementation AYWebViewController
-(instancetype)initWithPara:(id)para
{
    self = [AYWebViewController controller];
    if (self)
    {
        self.delegate = self;
        self.url = para;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadURL:[NSURL URLWithString:self.url]];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.url containsString:@"users_id="])
    {
        [AYUtitle updateUserCoin:^{
            
        }];
    }
}
- (BOOL)webBrowser:(LEWKWebViewController *)webBrowser didStartLoadingURL:(NSURL *)URL
{
    //用户问卷答题回调
    if ([[URL absoluteString] containsString:@"question://finish=1"]) {
        //刷新本地金币
        [AYGlobleConfig shared].questionTaskFinished = YES;
        [AYUtitle updateUserCoin:^{
            
        }];
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
        
    }
    return YES;
}
#pragma mark - 页面跳转 -
+ (BOOL) eventAvaliableCheck : (id) parameters
{
    if (parameters && [parameters isKindOfClass:NSString.class]) {
        return YES;
    }
    return NO;
}
+ (id) eventRecievedObjectWithParams : (id) parameters
{
    return [[AYWebViewController alloc] initWithPara:parameters];
}
@end
