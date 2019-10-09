//
//  AYCommentReplyModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/1/22.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCommentReplyModel : ZWBaseModel
@property(nonatomic,strong) NSString *beCommentID; //被评论id
@property(nonatomic,strong) NSString *commentReplyID; //评论id
@property(nonatomic,strong) NSString *commentReplyName; //评论者名字
@property(nonatomic,strong) NSString *commentReplyContent; //评论内容
@end

NS_ASSUME_NONNULL_END
