//
//  UILabel+copy.m
//  CallYou
//
//  Created by allen on 2017/11/22.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import "UILabel+copy.h"

@implementation UILabel (copy)
-(void)addLongPressCopy
{
    [self setUp];
}
-(void)removeLongPressCopy
{
    NSArray *gesArray = self.gestureRecognizers;
    [gesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UILongPressGestureRecognizer class]]) {
            UILongPressGestureRecognizer *ges = obj;
            [self removeGestureRecognizer:ges];
        }
    }];
}
// 设置长按事件
- (void)setUp {
    /* 你可以在这里添加一些代码，比如字体、居中、夜间模式等 */
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longGes =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress)];
    longGes.minimumPressDuration = 0.7f;
    [self addGestureRecognizer:longGes];
}
// 长按事件
- (void)longPress {

    [self becomeFirstResponder];
    
    // 自定义 UIMenuController
    UIMenuController * menu = [UIMenuController sharedMenuController];
    UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:AYLocalizedString(@"复制") action:@selector(copyText:)];
    menu.menuItems = @[item1];
    [menu setTargetRect:CGRectMake(0, 0, 50, 20) inView:self];
    [menu setMenuVisible:YES animated:NO];
}
// 设置label能够执行那些具体操作
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(copyText:)) return YES;
    return NO;
}
// 复制方法
- (void)copyText:(UIMenuController *)menu {
    // 没有文字时结束方法
    if (!self.text) return;
    // 复制文字到剪切板
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    if (self.tag ==1264)//id lable
    {
        paste.string = [self.text removeSubString:@"ID:"];

    }
    else
    {
        paste.string = self.text;

    }
    
}
// 设置label可以成为第一响应者
- (BOOL)canBecomeFirstResponder {
    return YES;
}
@end
