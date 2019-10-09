//
//  AYCommentModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"
#import "AYCommentReplyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCommentModel : ZWBaseModel
@property(nonatomic,strong) NSString *commentFictionID; //评论书架的id
@property(nonatomic,strong) NSString *commentID; //评论id
@property(nonatomic,strong) NSString *commentName; //评论者名字
@property(nonatomic,strong) NSString *commentContent; //评论内容
@property(nonatomic,strong) NSString *commentTime; //评论内容
@property(nonatomic,strong) NSString *commentStarNum; //评论五星数
@property(nonatomic,strong) NSString *commenterHeadImage; //评论者头像
@property(nonatomic,strong) NSArray<AYCommentReplyModel*> *commentReplyArray; //评论回复的数组
@end

NS_ASSUME_NONNULL_END
