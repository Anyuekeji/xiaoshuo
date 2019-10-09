//
//  AYRewardView.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/19.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *获取奖励弹出视图
 */
@interface AYRewardView : UIView
+(void)showRewardViewWithTitle:(NSString*)title coinStr:(NSString*)cointStr  detail:(NSString*)detailStr  actionStr:(NSString*)actionStr;
@end

NS_ASSUME_NONNULL_END
