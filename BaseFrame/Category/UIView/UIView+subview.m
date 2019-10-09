//
//  UIView+subview.m
//  DSQiche
//
//  Created by allen on 2017/7/29.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import "UIView+subview.h"

@implementation UIView (subview)
-(BOOL)containSubview:(UIView*)subview
{
    return [subview isDescendantOfView:self];
}
@end
