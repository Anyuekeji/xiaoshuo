//
//  AYCartoonSelectViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LECollectionViewController.h"
#import "ZWR2SegmentItem.h"
#import "ZWRChainReactionProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonSelectViewController : LECollectionViewController<ZWRChainReactionProtocol,ZWR2SegmentViewControllerProtocol,ZWREventsProtocol>
-(instancetype)initWithPara:(id)para;

@end

NS_ASSUME_NONNULL_END
