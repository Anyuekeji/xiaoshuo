//
//  AYMeViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/7.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYMeViewModel : AYBaseViewModle
/**
 *  数据组
 */
- (NSInteger) numberOfSections;
/**
 *  数据行
 */
- (NSInteger) numberOfRowsInSection:(NSInteger)section;

///**
// *  获取对象所在索引
// */
//- (NSIndexPath *) indexPathForObject : (id) object;
/**
 *  获取对象
 */
- (id) objectForIndexPath : (NSIndexPath *) indexPath;
@end

NS_ASSUME_NONNULL_END

