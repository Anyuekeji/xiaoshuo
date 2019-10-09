//
//  UIViewController+AYKeyboardViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "UIViewController+AYKeyboardViewController.h"
#import <objc/runtime.h>

@implementation UIViewController (AYKeyboardViewController)
#pragma mark - Properties
- (void) setTapGesture : (UITapGestureRecognizer *) panGesture {
    objc_setAssociatedObject(self, @selector(tapGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UITapGestureRecognizer *) tapGesture {
    return objc_getAssociatedObject(self, @selector(tapGesture));
}

#pragma mark - 键盘出现事件
- (void) setUpForDismissKeyboard : (BOOL) setUpForDissmissKeyboard {
    if ( setUpForDissmissKeyboard && self.tapGesture == nil ) {
        [self setUpActionForDismissKeyboard];
    } else if ( !setUpForDissmissKeyboard && self.tapGesture != nil ) {
        self.tapGesture = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void) enableTapGesture : (BOOL) enable {
    if ( self.tapGesture ) {
        self.tapGesture.enabled = enable;
    }
}

- (void) setUpActionForDismissKeyboard {
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(tapAnyWhereToDismissKeyboard)];
    self.tapGesture.delegate = self;
    self.tapGesture.cancelsTouchesInView = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) handleKeyboardWillShow : (NSNotification *) notif {
    if ( (self.navigationController && self.navigationController.topViewController == self) || !self.navigationController ) {
        
        CGRect rect = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGSize size = [self.view convertRect:rect toView:nil].size;
        NSTimeInterval time = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self keyboardWillShowWithSize:size
                              duration:time];
        [self.view addGestureRecognizer:self.tapGesture];
    }
}

- (void) handleKeyboardWillHide : (NSNotification *) notif {
    if ( (self.navigationController && self.navigationController.topViewController == self) || !self.navigationController ) {
        CGRect rect = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGSize size = [self.view convertRect:rect toView:nil].size;
        NSTimeInterval time = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self keyboardWillHideWithSize:size
                              duration:time];
        [self.view removeGestureRecognizer:self.tapGesture];
    }
}

- (void) tapAnyWhereToDismissKeyboard {
    [self.view endEditing:YES];
}

- (void) keyboardWillShowWithSize : (CGSize) size
                         duration : (NSTimeInterval) time {

}
- (void) keyboardWillHideWithSize : (CGSize) size
                         duration : (NSTimeInterval) time {

}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0) {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0) {
    return NO;
}
@end
