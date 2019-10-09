//
//  ZWBottomRefreshControl.h
//  qscode
//
//  Created by allen on 17/7/31.
//  Copyright © 2017年 2.0.2. All rights reserved.
//

#import "LERefreshControl.h"

@interface ZWBottomRefreshControl : LERefreshControl
/** 是否隐藏ForcedSpecial状态下的“已加载完”提示(YES:不显示/NO:显示) */
@property (nonatomic, assign) BOOL hiddenWhenForcedSpecial;
/** 是否强制关闭刷新控件(YES:状态变成ForcedSpecial/NO:状态变成Normal) */
- (void)forcedToCloseControl:(BOOL)forced;
@end
