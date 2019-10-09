//
//  AYTaskDayItem.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/8.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYTaskDayItem : NSObject
@property(nonatomic,strong) NSString *itmeImage; //图片名称
@property(nonatomic,strong) NSString *itemFinishImage; //任务已经完成图片名称

@property(nonatomic,strong) NSString *itmeTitle; //item标题
@property(nonatomic,strong) NSString *itemAction; //item标题

@property(nonatomic,strong) NSString *itmeIntroduce; //简介
@property(nonatomic,assign) BOOL itemFinish; //是否完成
@property(nonatomic,assign) BOOL advertiseLoading; //广告正在加载中

@end

NS_ASSUME_NONNULL_END
