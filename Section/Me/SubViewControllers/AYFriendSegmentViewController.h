//
//  AYFriendSegmentViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/23.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWR2SegmentViewController.h"
#import "ZWRChainReactionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFriendSegmentViewController : ZWR2SegmentViewController<ZWRChainReactionProtocol,ZWREventsProtocol>

@end

NS_ASSUME_NONNULL_END