//
//  AYFictionViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"
#import "ZWR2SegmentItem.h"
#import "ZWRChainReactionProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface AYFictionViewController : LETableViewController<ZWRChainReactionProtocol,ZWR2SegmentViewControllerProtocol>

@end

NS_ASSUME_NONNULL_END
