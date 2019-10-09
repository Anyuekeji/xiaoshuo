//
//  UIView+LEAF.h
//  LE
//
//  Created by 刘云鹏 on 15/10/14.
//  Copyright © 2015年 刘云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LEAF)

/**
 * frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * center.y = centerY
 */
@property (nonatomic) CGFloat centerY;

/**
 * 在屏幕的x相对位置
 */
@property (nonatomic, readonly) CGFloat screenX;

/**
 * 在屏幕y相对位置
 */
@property (nonatomic, readonly) CGFloat screenY;

/**
 * 在屏幕的绝对x位置
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * 在屏幕的绝对y位置
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * 屏幕的绝对矩形位置
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * frame.size
 */
@property (nonatomic) CGSize size;

/**
 * 当前屏幕下宽度
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 * 当前屏幕下高度
 */
@property (nonatomic, readonly) CGFloat orientationHeight;

/**
 * 在所有子view中遍历找到第一个符合条件的子view
 */
- (UIView*)descendantOrSelfWithClass:(Class)cls;

/**
 * 在所有父view中遍历找到第一个符合条件的父view
 */
- (UIView*)ancestorOrSelfWithClass:(Class)cls;

/**
 *  添加点击事件
 *
 *  @param block 事件
 */
- (void)setTapActionWithBlock:(void (^)(void))block;

/**
 *  添加长按事件
 *
 *  @param block 事件
 */
- (void)setLongPressActionWithBlock:(void (^)(void))block;

/**
 *  移走所有子view
 */
- (void) removeAllSubviews;

/**
 * 背景ImageView，必须在setUpBackgroundImageView之后才生效
 */
- (UIImageView *) backgroundImageView;
/**
 * 设置背景图片
 */
- (void) setBackgroundImage : (UIImage *) backgroundImage;
/**
 * 背景图片
 */
- (UIImage *) backgroundImage;
/**
 *  使得存在背景图片
 */
- (void) setUpBackgroundImageView;

@end

/**
 *  边框
 */
@interface UIView (Borders)

/* Create your borders and assign them to a property on a view when you can via the create methods when possible. Otherwise you might end up with multiple borders being created.
 */

///------------
/// Top Border
///------------
-(CALayer*)createTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(UIView*)createViewBackedTopBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(void)addTopBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;
-(void)addViewBackedTopBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;


///------------
/// Top Border + Offsets
///------------

-(CALayer*)createTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;
-(UIView*)createViewBackedTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;
-(void)addTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;
-(void)addViewBackedTopBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andTopOffset:(CGFloat)topOffset;

///------------
/// Right Border
///------------

-(CALayer*)createRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(UIView*)createViewBackedRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addViewBackedRightBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;

///------------
/// Right Border + Offsets
///------------

-(CALayer*)createRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(UIView*)createViewBackedRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addViewBackedRightBorderWithWidth: (CGFloat)width color:(UIColor*)color rightOffset:(CGFloat)rightOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;

///------------
/// Bottom Border
///------------

-(CALayer*)createBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(UIView*)createViewBackedBottomBorderWithHeight: (CGFloat)height andColor:(UIColor*)color;
-(void)addBottomBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;
-(void)addViewBackedBottomBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;

///------------
/// Bottom Border + Offsets
///------------

-(CALayer*)createBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;
-(UIView*)createViewBackedBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addViewBackedBottomBorderWithHeight: (CGFloat)height color:(UIColor*)color leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset andBottomOffset:(CGFloat)bottomOffset;

///------------
/// Left Border
///------------

-(CALayer*)createLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(UIView*)createViewBackedLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;
-(void)addViewBackedLeftBorderWithWidth: (CGFloat)width andColor:(UIColor*)color;

///------------
/// Left Border + Offsets
///------------

-(CALayer*)createLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(UIView*)createViewBackedLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;
-(void)addViewBackedLeftBorderWithWidth: (CGFloat)width color:(UIColor*)color leftOffset:(CGFloat)leftOffset topOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;

@end
