//
//  UILabel+Init.h
//  DSQiche
//
//  Created by allen on 2017/8/7.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Init)
/**初始化一个uilabel*/
+(UILabel*)lableWithTextFont:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSUInteger)numberOfLines;
@end
