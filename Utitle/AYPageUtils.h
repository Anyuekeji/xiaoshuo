//
//  AYPageUtils.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYPageUtils : NSObject
@property (nonatomic, copy  ) NSString   *contentText; //要分页的内容
@property (nonatomic, assign) NSUInteger contentFont; //字体大小
@property (nonatomic, assign) CGSize     textRenderSize; //每页的size


- (void)paging;
/**
 *  一共分了多少页
 *
 *  @return 一章所分的页数
 */
- (NSUInteger)pageCount;
/**
 *  获得page页的文字内容
 *
 *  @param page 页
 *
 *  @return 内容
 */
- (NSString *)stringOfPage:(NSUInteger)page;

- (NSInteger)locationWithPage:(NSInteger)page;

- (NSInteger)pageWithTextOffSet:(NSInteger)OffSet;
@end

NS_ASSUME_NONNULL_END
