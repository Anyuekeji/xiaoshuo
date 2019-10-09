//
//  AYCartoonChapterContentModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/4.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonChapterImageUrlModel : ZWDBBaseModel
@property(nonatomic,strong) NSString *cartoonImageUrl;//图片地址
@property(nonatomic,strong) NSNumber<RLMDouble> *cartoonImageHeight; //图片高度
//解密图片地址
-(void)decodeImageUrl;
@end

RLM_ARRAY_TYPE(AYCartoonChapterImageUrlModel)

@interface AYCartoonChapterContentModel : AYCartoonChapterModel
@property(nonatomic,strong) NSString *chapterAgreeNum;//章节点赞人数
@property(nonatomic,strong) AYCommentModel *cartoonChatperCommentModel; //漫画当前章节最新一条评论
@property(nonatomic,strong) RLMArray<AYCartoonChapterImageUrlModel> *cartoonImageUrlArray; //当前章节的漫画图片数
@property(nonatomic,strong) NSString *cartoonChapterCommentNum;//title
@property(nonatomic,strong) NSNumber<RLMBool> *hit_status; //是否已点赞

+(AYCartoonChapterContentModel*)itemWithRecord:(NSDictionary*)record;

@end

NS_ASSUME_NONNULL_END
