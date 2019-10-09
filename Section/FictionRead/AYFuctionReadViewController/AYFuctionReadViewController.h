//
//  AYFuctionReadViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LEAFViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFuctionReadViewController : LEAFViewController<ZWREventsProtocol>
-(instancetype)initWithPara:(id)para;

//更新书本打开动画封面
@property (nonatomic, copy) void (^updateBookOpenCover)(void);

@end

NS_ASSUME_NONNULL_END
