//
//  AYTaskRecordViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/27.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"
#import "ZWR2SegmentItem.h"
#import "ZWRChainReactionProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface AYTaskRecordViewController : LETableViewController<ZWRChainReactionProtocol,ZWR2SegmentViewControllerProtocol>

@end

NS_ASSUME_NONNULL_END
