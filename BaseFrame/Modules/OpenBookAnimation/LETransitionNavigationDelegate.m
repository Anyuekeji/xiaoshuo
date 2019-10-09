//
//  TETransitionNavigationDelegate.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETransitionNavigationDelegate.h"
#import "LErectAnimationPush.h"
#import "LErectAnimationPop.h"
#import "AYFuctionReadViewController.h"
#import "AYCommentViewController.h"
#import "AYLogiinViewController.h"
#import "AYTaskShareViewController.h"
#import "AYSearchViewController.h"
#import "AYBookmailViewController.h"
#import "LEWKWebViewController.h"

@interface LETransitionNavigationDelegate ()

@property (nonatomic, strong) LErectAnimationPush *customPush;
@property (nonatomic, strong) LErectAnimationPop *customPop;

@end
@implementation LETransitionNavigationDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (([toVC isKindOfClass:[AYFuctionReadViewController class]] &&![fromVC isKindOfClass:[LEWKWebViewController class]] &&![fromVC isKindOfClass:[AYCommentViewController class]] && ![fromVC isKindOfClass:[AYLogiinViewController class]] && ![fromVC isKindOfClass:[AYTaskShareViewController class]]&& ![fromVC isKindOfClass:[AYSearchViewController class]]&& ![fromVC isKindOfClass:[AYBookmailViewController class]]) || ([fromVC isKindOfClass:[AYFuctionReadViewController class]] && ![toVC isKindOfClass:[AYCommentViewController class]] && ![toVC isKindOfClass:[AYLogiinViewController class]]&& ![toVC isKindOfClass:[AYTaskShareViewController class]]&& ![toVC isKindOfClass:[AYSearchViewController class]]&& ![toVC isKindOfClass:[AYBookmailViewController class]]&& ![toVC isKindOfClass:[LEWKWebViewController class]])) {
        if (operation == UINavigationControllerOperationPush) {
            return self.customPush;
        }
        else if (operation == UINavigationControllerOperationPop) {
            return self.customPop;
        }
    }
    return nil;
}

/** 转场过渡的图片 */
- (void)setTransitionImg:(UIImage *)transitionImg{
    self.customPush.transitionImg = transitionImg;
    self.customPop.transitioImg = transitionImg;
    
}
- (void)setFlipImg:(UIImage *)flipImg{
    self.customPush.flipImg = flipImg;
    self.customPop.flipImg = flipImg;
    
}
/** 转场前的图片frame */
- (void)setTransitionBeforeImgFrame:(CGRect)frame{
    
    self.customPush.transitionBeforeImgFrame = frame;
    
    self.customPop.transitionBeforeImgFrame = frame;
}

/** 转场后的图片frame */
- (void)setTransitionAfterImgFrame:(CGRect)frame{
    self.customPush.transitionAfterImgFrame = frame;
    self.customPop.transitionAfterImgFrame = frame;
    
}

- (LErectAnimationPush *)customPush {
    if (_customPush == nil) {
        _customPush = [[LErectAnimationPush alloc] init];
    }
    return _customPush;
}

- (LErectAnimationPop *)customPop {
    if (_customPop == nil) {
        _customPop = [[LErectAnimationPop alloc] init];
    }
    return _customPop;
}

@end
