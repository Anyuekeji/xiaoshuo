//
//  AYCartoonChapterModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCommentModel.h"

NS_ASSUME_NONNULL_BEGIN


@class  CYFictionChapterModel;

@interface AYCartoonChapterModel : ZWDBBaseModel


@property(nonatomic,strong) NSString *cartoonId;//id
@property(nonatomic,strong) NSString *cartoontTitle;//漫画标题
@property(nonatomic,strong) NSNumber *cartoon_update_status;//2：连载中、1：已完结

@property(nonatomic,strong) NSNumber *cartoon_update_section;//更新到多少章节

@property(nonatomic,strong) NSNumber<RLMInt> *cartoonChapterId;//id
@property(nonatomic,strong) NSString *cartoonChapterTitle;//title
@property(nonatomic,strong) NSString *startChapterIndex;//title
@property(nonatomic,strong) NSNumber<RLMInt> *needMoney;//是否要收费
@property(nonatomic,strong) NSNumber<RLMBool> *unlock;//收费情况下是否已解锁
@property(nonatomic,strong) NSNumber<RLMFloat> *coinNum;//解锁需要的 金币数
@property(nonatomic,strong) NSString *cartoonUpdateTime;//漫画更新时间，用来判断是否读取本地数据

-(CYFictionChapterModel*)modelToFictionModel;
@end



NS_ASSUME_NONNULL_END
