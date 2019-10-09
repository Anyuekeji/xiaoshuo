//
//  UIView+gestureRecognizer.h
//  CallYou
//
//  Created by allen on 2017/8/10.
//  Copyright © 2017年 李雷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (gestureRecognizer)<UIGestureRecognizerDelegate>
-(void)addTapGesutureRecognizer:(void(^)(UITapGestureRecognizer *ges)) block;
@end
