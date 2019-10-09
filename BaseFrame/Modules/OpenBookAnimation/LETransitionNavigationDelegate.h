//
//  TETransitionNavigationDelegate.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LETransitionNavigationDelegate : NSObject
/** 转场过渡的图片 */
- (void)setTransitionImg:(UIImage *)transitionImg;
/** 转场过渡的图片 */
- (void)setFlipImg:(UIImage *)flipImg;

/** 转场前的图片frame */
- (void)setTransitionBeforeImgFrame:(CGRect)frame;
/** 转场后的图片frame */
- (void)setTransitionAfterImgFrame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END
