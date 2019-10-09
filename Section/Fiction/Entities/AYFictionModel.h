//
//  AYFictionModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/6.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFictionModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *fictionID; //小说id
@property(nonatomic,strong) NSString *fictionImageUrl;//小说图片
@property(nonatomic,strong) NSString *fictionTitle;//小说标题
@property(nonatomic,strong) NSString *fictionIntroduce;//小说简介
@property(nonatomic,strong) NSString *fictionAuthor;//小说作者
@property(nonatomic,strong) NSString *fictionCoinNum;//小说被打赏的金币
@property(nonatomic,strong) NSString *startChatperIndex;//开始阅读的章节index
@property(nonatomic,strong) NSNumber<RLMBool> *is_virtual;//是否显示虚拟的金币数  0为否 1为是
@property(nonatomic,strong) NSString *virtual_coin;//虚拟的金币数  is_virtual 1 时有效
@property(nonatomic,strong) NSNumber *isfree;//0限时免费，其他收费
@property(nonatomic,strong) NSNumber<RLMInt> *fiction_update_status;//2：连载中、1：已完结

//@property(nonatomic,strong) NSNumber<Bool> *fromFree;//是否是来自免费模块小说

@end

NS_ASSUME_NONNULL_END
