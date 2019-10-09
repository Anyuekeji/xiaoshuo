//
//  LERefreshActivityIndicatorView.h
//  xiaoyuanplus
//
//  Created by 刘云鹏 on 14/12/10.
//  Copyright (c) 2014年 刘云鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LERefreshActivityIndicatorViewDelegate;

@interface LERefreshActivityIndicatorView : UIView

/*  矩形个数    */
@property (nonatomic, assign) NSInteger numbers;
/*  每个间距    */
@property (nonatomic, assign) CGFloat internalSpacing;
/*  矩形大小    */
@property (nonatomic, assign) CGSize size;
/*  动画延迟    */
@property (nonatomic, assign) CGFloat delay;
/*  动画持续时间  */
@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, weak) id<LERefreshActivityIndicatorViewDelegate> delegate;

+ (id) activityIndicatorView;
/**
 *  开始动画
 */
- (void) startAnimating;
/**
 *  结束动画
 */
- (void) stopAnimating;

@end

@protocol LERefreshActivityIndicatorViewDelegate <NSObject>

/**
 *  设置每个节点对象颜色
 *
 *  @param activityIndicatorView 实例
 *  @param index                 位置
 *
 *  @return 设定颜色
 */
- (UIColor *) activityIndicatorView : (id) activityIndicatorView
    rectangleBackgroundColorAtIndex : (NSInteger) index;

@end
