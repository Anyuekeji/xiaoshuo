//
//  AYCommentModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/8.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCommentModel.h"

@implementation AYCommentModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"commentID"           : @"discuss_id",
             @"commentName"           : @"nick_name",
             @"commentContent"           : @"content",
             @"commentTime"           : @"discuss_time",
             @"commentStarNum"           : @"star",
             @"commentReplyArray"           : @"answer",
              @"commenterHeadImage"           : @"avater",
             };
}

+ (NSDictionary<NSString *, id> *) propertyToClassPair {
    
    return @{@"commentReplyArray"  : AYCommentReplyModel.class,
             };
}
@end
