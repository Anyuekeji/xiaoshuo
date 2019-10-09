//
//  AYCoinSelectView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYCoinSelectView : UIView
+(void)showCoinSelectViewInView:(UIView*)parentView model:(id)model  success :(void(^)(NSString *rewardNum)) completeBlock;
//回调
@property (nonatomic, copy) void (^coinSelectActionCancle)(void);

-(instancetype)initWithFrame:(CGRect)frame model:(id)model success :(void(^)(NSString *rewardNum)) completeBlock;
@end

NS_ASSUME_NONNULL_END
