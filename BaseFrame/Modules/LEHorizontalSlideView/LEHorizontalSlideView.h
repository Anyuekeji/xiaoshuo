//
//  LEHorizontalSlideView.h
//  BingoDu
//
//  Created by Leaf on 16/4/14.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGestureRecognizer+LEAF.h"

static NSString * const LEHorizontalSlideGestureIdentifier = @"LE_HORIZONTAL_SLIDE_GESTURE_IDENTIFIER";

@class LEHorizontalSlideView;

@protocol LEHorizontalSlideViewDataSource <NSObject>

@required
- (NSUInteger) numberOfItemsInSlideView : (LEHorizontalSlideView *) horizontalSlideView;
- (UIView *) horizontalSlideView : (LEHorizontalSlideView *) horizontalSlideView viewForItemAtIndex : (NSUInteger) index reusingView : (UIView *) view;

@end

@protocol LEHorizontalSlideViewDelegate <NSObject>

@optional
- (void) horizontalSlideViewCurrentItemIndexDidChange:(LEHorizontalSlideView *) horizontalSlideView;

@end

@interface LEHorizontalSlideView : UIView

@property (nonatomic, weak) id<LEHorizontalSlideViewDataSource> dataSource;
@property (nonatomic, weak) id<LEHorizontalSlideViewDelegate> delegate;

@property (nonatomic, assign) NSUInteger currentItemIndex;
@property (nonatomic, readonly, assign) NSUInteger numberOfItems;
@property (nonatomic, readonly, assign) NSUInteger latestItemIndex;

/**
 *  重新加载
 */
- (void) reloadData;

@end
