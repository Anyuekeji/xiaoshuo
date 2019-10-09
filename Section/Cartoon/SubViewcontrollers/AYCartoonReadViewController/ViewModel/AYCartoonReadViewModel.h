//
//  AYCartoonReadViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

NS_ASSUME_NONNULL_BEGIN
@class AYCartoonChapterContentModel;
@interface AYCartoonReadViewModel : AYBaseViewModle
/**
 *  数据组
 */
- (NSInteger) numberOfSections;
/**
 *  数据行
 */
- (NSInteger) numberOfRowsInSection:(NSInteger)section;

/**
 *  获取对象
 */
- (id) objectForIndexPath : (NSIndexPath *) indexPath;


@property(nonatomic,strong) AYCartoonChapterContentModel *cartoonDetailModel; //章节数据



@end

NS_ASSUME_NONNULL_END
