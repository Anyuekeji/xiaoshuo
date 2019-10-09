//
//  AYBookmailViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/11.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "ZWR2SegmentViewController.h"
#import "ZWRChainReactionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYBookmailViewController : ZWR2SegmentViewController<ZWRChainReactionProtocol,ZWREventsProtocol>
-(void)updateSegmentIndex; //更新index

//是否显示导航栏
-(void)showNavagationBar:(BOOL)show animate:(BOOL)animate;
@end

NS_ASSUME_NONNULL_END
