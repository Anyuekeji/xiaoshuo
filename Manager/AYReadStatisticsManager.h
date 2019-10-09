//
//  AYReadStatisticsManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/19.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYReadStatisticsManager : NSObject
singleton_interface(AYReadStatisticsManager)

//进入阅读也
-(void)enterReadController;

//离开阅读页
-(void)leaveReadController:(BOOL)leave;

//用户读完一本书的某一章节
-(void)userReadFinishOneChapter:(NSString*)bookId  chapterId:(NSString*)chapterId;

//广告解锁小说每天阅读的机会是否用完
-(BOOL)advertiseReadDayCountFinished;

//进入广告阅读
-(void)localBookFreeReadStatiticsTimeAviable:(void(^)(void)) completeBlock;
@end

NS_ASSUME_NONNULL_END
