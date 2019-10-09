//
//  LErectAnimationPush.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LErectAnimationPush : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) UIImage *transitionImg;

@property (nonatomic, strong) UIImage *flipImg;

@property (nonatomic, assign) CGRect transitionBeforeImgFrame;

@property (nonatomic, assign) CGRect transitionAfterImgFrame;
@end

NS_ASSUME_NONNULL_END
