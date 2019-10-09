//
//  ANBaseViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LEAFViewController.h"
#import "AYNavigationController.h"
//键盘事件监听
#import "UIViewController+AYKeyboardViewController.h"

@interface LEAFViewController ()

@end

@implementation LEAFViewController

@synthesize visiable = _visiable;

+ (id) controller {
    return [[self alloc] init];
}

+ (id) navigationController {
    return [[AYNavigationController alloc] initWithRootViewController:[self controller]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _visiable = YES;
    //导航栏控制器动画
    if ( [self shouldShowNavigationBar] ) { //如果需要显示，而现在导航栏是隐藏的，就需要显示
        if ( self.navigationController.navigationBarHidden ) {
            [self.navigationController setNavigationBarHidden:NO animated:animated];
        }
    } else {                                //如果需要隐藏，本控制器是第一个控制器或者现在导航栏是显示的，就需要隐藏
        if ( (self.navigationController.viewControllers.firstObject == self) || !self.navigationController.navigationBarHidden ) {
            [self.navigationController setNavigationBarHidden:YES animated:animated];
        }
    }
    //工具栏控制器动画
    if ( [self shouldShowToolBar] ) {       //如果需要显示，而现在工具栏是隐藏的，就显示
        if ( self.navigationController.isToolbarHidden ) {
            [self.navigationController setToolbarHidden:NO animated:NO];
        }
    } else {                                //如果需要隐藏，现在工具栏是显示的，就需要隐藏|隐藏没有动画
        if ( !self.navigationController.isToolbarHidden ) {
            [self.navigationController setToolbarHidden:YES animated:NO];
        }
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    //配置导航栏退出
    [self setUpNavigationItem];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _visiable = NO;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpForDismissKeyboard:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
    } else {
        //取消自动调整滚动视图的间距  UIViewController + Nav 会自动调整tabview的contentinset
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //一定要设要不会出现push卡顿的问题
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    //    self.extendedLayoutIncludesOpaqueBars = NO;
    //    self.modalPresentationCapturesStatusBarAppearance = NO;
}

- (void) setUpNavigationItem {
    [self configurateBackBarButtonItem];
}

- (UIEdgeInsets) contentInsets {
    CGFloat top = 0.0f;
    CGFloat bottom = 0.0f;
    if ( self.navigationController.navigationBar.isTranslucent ) {
        top = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    }

    return UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
}

- (void) dealloc {
    [self setUpForDismissKeyboard:NO];
    AYLog(@"%@ deallco",NSStringFromClass([self class]));
}

#pragma mark - Rotation
- (BOOL) shouldAutorotateToInterfaceOrientation : (UIInterfaceOrientation) toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)prefersStatusBarHidden

{
    return NO;// 返回YES表示隐藏，返回NO表示显示
}
@end
