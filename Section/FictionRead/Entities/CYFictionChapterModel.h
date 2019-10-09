//
//  CYFictionChapterModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/9.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYFictionChapterModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *fictionID; //小说id
@property(nonatomic,strong) NSString *fictionSectionTitle;//小说章节标题
@property(nonatomic,strong) NSNumber<RLMInt> *fictionSectionID;//小说章节ID 跟其他章节是唯一的 可以通过他来排序
@property(nonatomic,strong) NSNumber<RLMInt> *needMoney;//收费类型 0 不收费 1 千字收费 2 每章收费 3整本收费  4广告

@property(nonatomic,strong) NSNumber<RLMBool> *unlock;//收费情况下是否已解锁
@property(nonatomic,strong) NSNumber<RLMBool> *advertise;//是否是免费插入广告的章节

@property(nonatomic,strong) NSNumber<RLMFloat> *coinNum;//解锁需要的 金币数
@property(nonatomic,strong) NSString *fictionUpdateTime;//小说更新时间，用来判断是否读取本地数据

@end

NS_ASSUME_NONNULL_END
