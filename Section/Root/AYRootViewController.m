//
//  AYRootViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYRootViewController.h"
#import "AYBookrackViewController.h" //书架
#import "AYCartoonViewController.h" //漫画
#import "AYFictionViewController.h" //小说
#import "AYMeViewController.h" //我的
#import "AYNavigationController.h"
#import "UITabBarController+LETabBarController.h"
#import "AYTaskViewController.h" //任务
#import "AYBookmailViewController.h" //书城

@interface AYRootViewController ()<UITabBarControllerDelegate>
{
    UITabBarController * _tabbarController;
}
// 当前显示控制器
@property (nonatomic, strong) UIViewController * currentViewController;

@end

@implementation AYRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurateTabBarController];
    [self setUpCurrentChildViewController];
  //  [self changeTabBarSelectedIndex];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.view.top<=0)//书本打开动画会改变view的frame ，s所以要重新设置view的frame
    {
        self.view.frame = CGRectMake(0, Height_TopBar, ScreenWidth, SCREEN_HEIGHT-Height_TopBar);
    }


}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(BOOL)shouldShowNavigationBar
{
    return YES;
}
- (BOOL)prefersStatusBarHidden{
    return NO;
}
#pragma mark - init -
+ (UINavigationController *) navigationController {
    AYNavigationController *nav = [[AYNavigationController alloc] initWithRootViewController:[[self alloc] init]];
    nav.navigationBar.barTintColor = [UIColor whiteColor];
    
    return nav;
}
- (void) setUpNavigationItem {
    [super setUpNavigationItem];
}
- (void)configurateTabBarController {
    NSDictionary *barButtonTitleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18.0f],
                                                   NSForegroundColorAttributeName:[UIColor blackColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:barButtonTitleTextAttributes];
    

    //字体
    [UITabBarController setAppearanceTitleFont:[UIFont systemFontOfSize:11] color:UIColorFromRGB(0xfa556c) shadowColor:nil shadowOffset:NANSIZE forState:UIControlStateSelected];
    
    [UITabBarController setAppearanceTitleFont:[UIFont systemFontOfSize:11] color:UIColorFromRGB(0x666666) shadowColor:nil shadowOffset:NANSIZE forState:UIControlStateNormal];
    [UITabBarController setTitlePositionAdjustment:UIOffsetZero];
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
}
- (void)setUpCurrentChildViewController {
    [[self tabBarController] didMoveToParentViewController:self];
    [self.view addSubview:_tabbarController.view];
    self.currentViewController = _tabbarController;
    [self setNavigationBarViewStyle:AYNavigationBarViewStyleBookrack];
}
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tabbarController.view.frame = self.view.bounds;
}
#pragma mark - event handle -
-(void)changeTabBarSelectedIndex
{
    [self tabbarController].selectedIndex=1;
}
#pragma mark - getter and setter -

- (UITabBarController *) tabbarController {
    if ( !_tabbarController ) {
        _tabbarController = [[UITabBarController alloc] init];
        _tabbarController.delegate = self;
        _tabbarController.viewControllers =
        @[[AYBookrackViewController controller],
          //[AYFictionViewController controller],
          [AYBookmailViewController controller],
          [AYTaskViewController controller],
          [AYMeViewController controller],
          ];
        //Tabbar设置
        UITabBar * tabbar = _tabbarController.tabBar;
        tabbar.autoresizesSubviews = YES;
        [_tabbarController setTabBarItemAtIndex:0
                                          title:AYLocalizedString(@"书架")
                                    normalImage:[UIImage imageNamed:@"tab_bookrack"]
                                  selectedImage:[UIImage imageNamed:@"tab_bookrack_select"]];
        
        [_tabbarController setTabBarItemAtIndex:1
                                          title:AYLocalizedString(@"书城")
                                    normalImage:[UIImage imageNamed:@"tab_bookmail"]
                                  selectedImage:[UIImage imageNamed:@"tab_bookmail_select"]];
//        [_tabbarController setTabBarItemAtIndex:2
//                                          title:AYLocalizedString(@"漫画")
//                                    normalImage:[UIImage imageNamed:@"tab_manhua"]
//                                  selectedImage:[UIImage imageNamed:@"tab_mahua_select"]];
        
        [_tabbarController setTabBarItemAtIndex:2
                                          title:AYLocalizedString(@"任务")
                                    normalImage:[UIImage imageNamed:@"tab_task"]
                                  selectedImage:[UIImage imageNamed:@"tab_task_select"]];
        [_tabbarController setTabBarItemAtIndex:3
                                          title:AYLocalizedString(@"我的")
                                    normalImage:[UIImage imageNamed:@"tab_my"]
                                  selectedImage:[UIImage imageNamed:@"tab_my_select"]];
        //添加到主体
        [self addChildViewController:_tabbarController];
    }
    return _tabbarController;
}

- (UITabBarController *) tabBarController {
    return [self tabbarController];
}
#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ( [viewController isKindOfClass:[AYBookmailViewController class]] ) {
        [self setNavigationBarViewStyle:AYNavigationBarViewStyleBookmail];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AYBookmailViewController *bookMailController = (AYBookmailViewController*)viewController;
            [bookMailController updateSegmentIndex];
        });

    } else if ([viewController isKindOfClass:[AYTaskViewController class]])
    {
        [self setNavigationBarViewStyle:AYRNavigationBarViewStyleTask];
    } else if ( [viewController isKindOfClass:[AYBookrackViewController class]] )
    {
        [self setNavigationBarViewStyle:AYNavigationBarViewStyleBookrack];
    }
    else if ( [viewController isKindOfClass:[AYMeViewController class]] )
    {
        [self setNavigationBarViewStyle:AYRNavigationBarViewStyleMe];
    }
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}
@end
