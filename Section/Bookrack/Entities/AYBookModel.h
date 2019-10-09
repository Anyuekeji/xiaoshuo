//
//  AYBookModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/27.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYBookModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *bookID; //小说id
@property(nonatomic,strong) NSString *bookImageUrl;//小说图片
@property(nonatomic,strong) NSString *bookTitle;//小说标题
@property(nonatomic,strong) NSString *bookIntroduce;//小说简介
@property(nonatomic,strong) NSString *bookAuthor;//小说作者
@property(nonatomic,strong) NSNumber<RLMInt> *bookDestinationType;//1详情页、2阅读页

@property(nonatomic,strong) NSString *bookReaderChapter;//小说阅读到多少章
@property(nonatomic,strong) NSString *users_id;//用户id
@property(nonatomic,strong) NSNumber<RLMInt> *type;//1为小说。2为漫画 nil 为推荐的书籍
@property(nonatomic,strong) NSNumber<RLMBool> *isgroom;//是否是推荐
@property(nonatomic,strong) NSNumber<RLMInt> *isfree;//4是免费

@end

NS_ASSUME_NONNULL_END
