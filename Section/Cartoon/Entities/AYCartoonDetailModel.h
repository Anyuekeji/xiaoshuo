//
//  AYCartoonDetailModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonModel.h"
#import "AYCommentModel.h"
#import "AYMeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonDetailModel : AYCartoonModel
@property(nonatomic,strong) NSString *cartoonUpdateTime;//漫画更新时间
@property(nonatomic,strong) NSString *cartoonHotNum;//漫画作者
@property(nonatomic,strong) NSString *cartoonAgreeNum;//点赞人数
@property(nonatomic,strong) NSString *cartoonColletNum;//收藏人数

@property(nonatomic,strong) NSString *cartoonSumSection; //漫画总章节数
@property(nonatomic,strong) NSString *cartoonSumComment; //漫画总评论数
@property(nonatomic,strong) NSString *cartoonGrade; //漫画评分
@property(nonatomic,strong) NSString *cartoonStarNum; //漫画五星数
@property(nonatomic,strong) NSString *cartoonSurfaceplot; //漫画封面图
@property(nonatomic,strong) NSMutableArray<AYMeModel*> *cartoonRewardUserArray; //漫画打赏人
@property(nonatomic,strong) NSString *cartoonRewardCoinNum; //漫画获得的打赏金币数
@property(nonatomic,strong) NSMutableArray<AYCommentModel*> *cartoonCommentModel; //漫画最新一条评论
@property(nonatomic,strong) NSMutableArray<AYCartoonModel*> *cartoonRecommendList; //推荐的漫画列表
+(AYCartoonDetailModel*)itemWithRecord:(NSDictionary*)record;
@end

NS_ASSUME_NONNULL_END
