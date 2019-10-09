//
//  UIImageView+AY.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/23.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (AY)
//增加免费角标
-(void)addOrRemoveFreeFlag:(BOOL)add;

//增加阴影
-(void)addOrRemoveShowdow:(BOOL)add;

//增加圆角
-(void)addCornorsWithValue:(CGFloat)cornorsValue;
@end

NS_ASSUME_NONNULL_END
