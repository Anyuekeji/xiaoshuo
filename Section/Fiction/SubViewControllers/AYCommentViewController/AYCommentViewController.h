//
//  AYCommentViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCommentViewController : LETableViewController<ZWREventsProtocol>
-(instancetype)initWithParas:(NSDictionary*)para;
@end

NS_ASSUME_NONNULL_END
