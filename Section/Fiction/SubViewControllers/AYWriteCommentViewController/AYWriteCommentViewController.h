//
//  AYWriteCommentViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LEAFViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYWriteCommentViewController : LEAFViewController<ZWREventsProtocol>
-(instancetype)initWithPara:(NSDictionary*)paras;

@end

NS_ASSUME_NONNULL_END
