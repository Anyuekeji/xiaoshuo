//
//  ZWRChainReactionProtocol.h
//  CallU
//
//  Created by Leaf on 16/5/26.
//  Copyright © 2016年 NHZW. All rights reserved.
//

/**
 *  @author 陈梦杉
 *  @ingroup model
 *  @brief 联动效应协议
 */
@protocol ZWRChainReactionProtocol <NSObject>

@optional
/**
 *  当前选中状态又重新选择了这个tabbar，会向当前所在控制器发送本请求事件
 */
- (void) zwrChainReactionEventTabBarDidReClickAfterAppear;

@end
