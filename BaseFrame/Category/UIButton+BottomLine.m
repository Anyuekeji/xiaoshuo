//
//  UIButton+BottomLine.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/3.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "UIButton+BottomLine.h"

@implementation UIButton (BottomLine)
-(void)setBottomLineStyleWithColor:(UIColor*)lineColor
{
    UIView* _underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [_underLine setBackgroundColor:lineColor];
    _underLine.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:_underLine];
    
    NSDictionary *_views = @{@"line":_underLine};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[line]-0-|" options:0 metrics:nil views:_views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[line(==0.8)]-3-|" options:0 metrics:nil views:_views]];
}
@end
