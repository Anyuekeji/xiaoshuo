//
//  LELineTableViewCell.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LELineTableViewCell.h"
@interface LELineTableViewCell()

/**底部线*/
@property (strong, nonatomic) UIView *underLine;
@property (nonatomic,strong) NSArray<NSLayoutConstraint*> *hotConstraintArray;
@end
@implementation LELineTableViewCell

-(void)setUp
{
    [self configBaiseUI];
}
-(void)configBaiseUI
{
    _underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [_underLine setBackgroundColor:UIColorFromRGB(0xe7e7e7)];
    _underLine.translatesAutoresizingMaskIntoConstraints=NO;
    [self.contentView addSubview:_underLine];
    
    [self configurateBaseConstraints];
}

- (void)configurateBaseConstraints
{
    NSDictionary *_views = @{@"line":self.underLine};
    
    _hotConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[line]-0-|" options:0 metrics:nil views:_views];
    [self.contentView addConstraints:_hotConstraintArray];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[line(==0.5)]-0-|" options:0 metrics:nil views:_views]];
    
}
-(void)hideOrShowLine:(BOOL)show
{
    _underLine.hidden=!show;
    
}
-(void)bottomLineRightMoveWithValue:(CGFloat)value
{
    [self.contentView removeConstraints:_hotConstraintArray];
    
    NSDictionary *_views = @{@"line":self.underLine};
    NSDictionary *_metrics = @{@"rightoffset":@(value)};
    NSArray<NSLayoutConstraint*> *tempConstraintArray;
    tempConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-rightoffset-[line]-0-|" options:0 metrics:_metrics views:_views];
    [self.contentView addConstraints:tempConstraintArray];
    _hotConstraintArray = tempConstraintArray;
}
-(void)bottomLineCenterWithOffset:(CGFloat)offset
{
    [self.contentView removeConstraints:_hotConstraintArray];
    
    NSDictionary *_views = @{@"line":self.underLine};
    NSDictionary *_metrics = @{@"rightoffset":@(offset)};
    NSArray<NSLayoutConstraint*> *tempConstraintArray;
    tempConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-rightoffset-[line]-rightoffset-|" options:0 metrics:_metrics views:_views];
    [self.contentView addConstraints:tempConstraintArray];
    _hotConstraintArray = tempConstraintArray;
}
@end
