//
//  AYFreeBookViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/14.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"
#import "ZWR2SegmentItem.h"
#import "ZWRChainReactionProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface AYFreeBookViewController : LETableViewController<ZWRChainReactionProtocol,ZWR2SegmentViewControllerProtocol>

-(instancetype)initWithPara:(BOOL)search;
//加载搜索列表
-(void)loadSearchListWithText:(NSString*)seachText refresh:(BOOL)refresh  complete:(void(^)(void)) completeBlock;
@end

NS_ASSUME_NONNULL_END
