//
//  AYFriendChargeViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/18.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LEBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFriendChargeViewController : LEBaseViewController<ZWREventsProtocol>
-(instancetype)initWithPara:(BOOL)charge;
@end

NS_ASSUME_NONNULL_END
