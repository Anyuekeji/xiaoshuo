//
//  AYCartoonDetailSegmengViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWR2SegmentViewController.h"
#import "ZWRChainReactionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonDetailSegmengViewController : ZWR2SegmentViewController<ZWRChainReactionProtocol>
-(instancetype)initWithPara:(id)para;
@end

NS_ASSUME_NONNULL_END
