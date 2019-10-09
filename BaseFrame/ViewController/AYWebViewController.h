//
//  AYWebViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LEWKWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYWebViewController : LEWKWebViewController<ZWREventsProtocol>
-(instancetype)initWithPara:(id)para;
@end

NS_ASSUME_NONNULL_END
