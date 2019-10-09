//
//  UIButton+Init.m
//  DSQiche
//
//  Created by allen on 2017/8/7.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import "UIButton+Init.h"

@implementation UIButton (Init)
+(UIButton*)buttonWithType:(UIButtonType)buttonType font:(UIFont*)font textColor:(UIColor*)color title:(NSString*)title image:(UIImage*)iconImage
{
    UIButton *btn = [UIButton buttonWithType:buttonType];
    btn.titleLabel.font = font;
    [btn setTitleColor:color forState:UIControlStateNormal];
    if (title) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (iconImage){
        [btn setImage:iconImage forState:UIControlStateNormal];
    }
    return btn;
}
@end
