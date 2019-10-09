//
//  AYReadManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYReadManager.h"
#import "LETransitionNavigationDelegate.h"


@implementation AYReadManager
-(void)openFictionAniamationWithFromImage:(UIImage*)fromImage fromViewController:(UIViewController*)fromViewController  toViewController:(UIViewController*)toViewController beforeFrame:(CGRect)beforeFrame
{
      LETransitionNavigationDelegate *transitionDelegate = [[LETransitionNavigationDelegate alloc] init];
   fromViewController.navigationController.interactivePopGestureRecognizer.delegate = self;
    fromViewController.navigationController.delegate = transitionDelegate;
    UIImage *contentImage = [AYUtitle imageWithUIView:toViewController.view];
    [transitionDelegate setFlipImg:contentImage];
    
    [transitionDelegate setTransitionBeforeImgFrame:beforeFrame];
    [transitionDelegate setTransitionImg:fromImage];
    
    [fromViewController.navigationController pushViewController:toViewController animated:YES];
}
@end
