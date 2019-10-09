//
//  LERefreshActivityIndicator2View.h
//  xiaoyuanplus
//
//  Created by liuyunpeng on 14/12/10.
//  Copyright (c) 2014年 liuyunpeng. All rights reserved.
//

#import "LERefreshActivityIndicatorView.h"

@interface LERefreshActivityIndicator2View : UIView

/*  圆形个数 */
@property (nonatomic, assign) NSInteger numbers;
/*  半径  */
@property (nonatomic, assign) CGFloat diameter;
/*  摆动因子,摆动圆形半径 */
@property (nonatomic, assign) CGFloat radiusFactor;
/*  摆动半径    M_PI_2 到 0 最合适  */
@property (nonatomic, assign) CGFloat angle;
/*  一次摆动时间  */
@property (nonatomic, assign) CGFloat duration;
/*  倒影距离    */
@property (nonatomic, assign) CGFloat verticalOffset;

@property (nonatomic, weak) id<LERefreshActivityIndicatorViewDelegate> delegate;

+ (id) activityIndicatorView;

/**
 *  如果你不想用默认参数，请修改后调用此函数
 */
- (void) prepared;
/**
 *  开始动画
 */
- (void) startAnimating;
/**
 *  结束动画
 */
- (void) stopAnimating;

@end
