//
//  AYCartoonModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *cartoonID; //小说id
@property(nonatomic,strong) NSString *cartoonImageUrl;//小说图片
@property(nonatomic,strong) NSString *cartoonTitle;//小说标题
@property(nonatomic,strong) NSString *cartoonIntroduce;//小说简介
@property(nonatomic,strong) NSString *cartoonAuthor;//小说作者
@property(nonatomic,strong) NSString *cartoonCoinNum;//小说要花费的金币
@property(nonatomic,strong) NSNumber<RLMBool> *is_virtual;//是否显示虚拟的金币数  0为否 1为是
@property(nonatomic,strong) NSString *virtual_coin;//虚拟的金币数  is_virtual 1 时有效
@property(nonatomic,strong) NSNumber *isfree;//0 免费，其他收费
@property(nonatomic,strong) NSNumber<RLMInt> *cartoon_update_status;//2：连载中、1：已完结
@end

NS_ASSUME_NONNULL_END
