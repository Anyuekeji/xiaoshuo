//
//  AYCommentReplyModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/1/22.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYCommentReplyModel.h"

@implementation AYCommentReplyModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"beCommentID"           : @"discuss_id",
             @"commentReplyID"           : @"further_id",
             @"commentReplyName"           : @"reply_name",
             @"commentReplyContent"           : @"further_comment",
             };
}
@end
