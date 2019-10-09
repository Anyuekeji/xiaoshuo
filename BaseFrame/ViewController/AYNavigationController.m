//
//  AYNavigationController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYNavigationController.h"

@interface AYNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation AYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AYNavigationController * __weak weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.interactivePopGestureRecognizer setEnabled:YES];
        self.interactivePopGestureRecognizer.delegate = weakSelf;
    }
}
#pragma mark - 旋转
- (BOOL) shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

+ (void) configurateNavigationBarColor : (UIColor *) color {

//    [[UINavigationBar appearance] setBackgroundImage:[[AYNavigationController imageWithColor:color] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forBarMetrics:UIBarMetricsDefault];
//    if ( [UINavigationBar.appearance respondsToSelector:@selector(setTranslucent:)] ) {
//        [UINavigationBar.appearance setTranslucent:NO];
//    }
}

+ (UIImage *) imageWithColor : (UIColor *) color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark GestureRecognizerDelegate 实现
- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.viewControllers.count > 1;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}
@end
