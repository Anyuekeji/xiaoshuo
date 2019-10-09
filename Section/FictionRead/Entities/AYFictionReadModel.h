//
//  AYFictionReadModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/1.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFictionReadModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *fictionID; //小说id
@property(nonatomic,strong) NSString *currrenReadSectionId; //当前读到章节id
@property(nonatomic,strong) NSString *currrenReadPageIndex; //当前读到第几页
@property(nonatomic,strong) NSNumber<RLMDouble> *currrenFontsize; //当前阅读的size大小
@property(nonatomic,strong) NSString *currrenReadSectionIndex; //当前读到第几章

@end

NS_ASSUME_NONNULL_END
