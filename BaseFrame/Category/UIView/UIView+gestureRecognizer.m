//
//  UIView+gestureRecognizer.m
//  CallYou
//
//  Created by allen on 2017/8/10.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import "UIView+gestureRecognizer.h"
#import <objc/runtime.h>

static char kTapgestureKey;

@implementation UIView (gestureRecognizer)
-(void)addTapGesutureRecognizer:(void(^)(UITapGestureRecognizer *ges)) block
{
    objc_setAssociatedObject(self, &kTapgestureKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.enabled = YES;
    tap.delegate = self;
    
    [self addGestureRecognizer:tap];
}
-(void)handleTap:(UIGestureRecognizer*)ges
{
    void (^block)() = objc_getAssociatedObject(self, &kTapgestureKey);
    block(ges);
}
//防止跟tableview 点击冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {//判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }//否则手势存在
     return YES;
}

@end
