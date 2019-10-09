//
//  AYCartoonReadModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/4.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonReadModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *cartoonID; //漫画id
@property(nonatomic,strong) NSString *currrenReadSectionId; //当前读到章节id
@property(nonatomic,strong) NSString *currrenReadSectionIndex; //当前读到第几章
@end

NS_ASSUME_NONNULL_END
