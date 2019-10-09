//
//  AYFictionDetailModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionModel.h"
#import "AYMeModel.h"
#import "AYCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFictionDetailModel: AYFictionModel
@property(nonatomic,strong) NSString *fictionSumSection; //小说总章节数
@property(nonatomic,copy) NSString *fictionSumComment; //小说总评论数
@property(nonatomic,strong) NSNumber *fiction_update_section;//更新到多少章节

@property(nonatomic,strong) NSString *fictionGrade; //小说评分
@property(nonatomic,strong) NSString *fictionStarNum; //小说五星数
@property(nonatomic,strong) NSMutableArray<AYMeModel*> *fictionRewardUserArray; //小说打赏人
@property(nonatomic,strong) NSString *fictionRewardCoinNum; //小说获得的打赏金币数
@property(nonatomic,strong) NSMutableArray<AYCommentModel*> *fictionCommentModel; //小说最新一条评论
@property(nonatomic,strong) NSMutableArray<AYFictionModel*> *recommentFictionList; //推荐的小说列表
+(AYFictionDetailModel*)itemWithRecord:(NSDictionary*)record;
@end

NS_ASSUME_NONNULL_END
