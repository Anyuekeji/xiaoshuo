//
//  AYCartoonChapterDetailFooterViewModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/15.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBaseViewModle.h"

NS_ASSUME_NONNULL_BEGIN
@class AYCartoonChapterModel;

@interface AYCartoonChapterDetailFooterViewModel : AYBaseViewModle
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
/**
 *  数据对象
 */
@property(nonatomic,strong)AYCartoonChapterModel *chapterModel;

@end

NS_ASSUME_NONNULL_END
