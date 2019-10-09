//
//  UILabel+Init.m
//  DSQiche
//
//  Created by allen on 2017/8/7.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import "UILabel+Init.h"

@implementation UILabel (Init)
+(UILabel*)lableWithTextFont:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSUInteger)numberOfLines
{
    UILabel *label = [UILabel new];
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    label.numberOfLines=  numberOfLines;
    
    return label;
    
}
@end
