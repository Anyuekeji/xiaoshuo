//
//  AYSearchViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/14.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYSearchViewController : LETableViewController<ZWREventsProtocol>
-(instancetype)initWithParas:(BOOL)para;

@end

NS_ASSUME_NONNULL_END
