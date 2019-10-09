//
//  AYFictionFreeViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/21.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LETableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFictionFreeViewController : LETableViewController<ZWREventsProtocol>
-(instancetype)initWithParas:(NSDictionary*)para;
@end

NS_ASSUME_NONNULL_END
