//
//  LESegment.h
//  yckx
//
//  Created by Leaf on 15/11/14.
//  Copyright © 2015年 Leaf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LESegmentType) {
    LESegmentTypeFixedWidth         =   1,  /*固定段宽*/
    LESegmentTypeDynamicWidth       =   2,  /*动态段宽*/
};

@interface LESegment : UIView

@property (nonatomic, assign) LESegmentType type;
@property (nonatomic, strong) UIFont * normalFont;
@property (nonatomic, strong) UIFont * selectedFont;
@property (nonatomic, strong) UIColor * normalColor;
@property (nonatomic, strong) UIColor * selectedColor;
@property (nonatomic, strong) UIColor * bottomLineColor;



@property (nonatomic, assign) CGFloat itemOrginX;//orginx的起始值

//LESegmentTypeFixedWidth下下面属性有效
@property (nonatomic, assign) CGFloat itemFixedWidth;
//LESegmentTypeDynamicWidth下下面属性有效
@property (nonatomic, assign) CGFloat horizontalGap;
@property (nonatomic, assign) UIEdgeInsets itemLineInsets;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) void(^segmentDidChangeSelectedValue)(NSUInteger selectedIndex);

- (void) setItems : (NSArray<NSString *> *) items oneWidth : (CGFloat) width;
- (void) setItems : (NSArray<NSString *> *) items;

- (void) addRedPointAtIndex : (NSUInteger) index;
- (void) removeRedPointAtIndex : (NSUInteger) index;
- (CGSize) getSegmentContentSize;

@end
