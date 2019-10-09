//
//  AYBookModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/27.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBookModel.h"

@implementation AYBookModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"bookID"           : @"book_id",
             @"bookImageUrl"           : @"bpic",
             @"bookTitle"           : @"other_name",
             @"bookIntroduce"           : @"desc",
             @"bookAuthor"           : @"writer_name",

             };
}
+ (NSArray *)ignoredProperties {
    return @[@"bookIntroduce",
             @"bookAuthor",@"bookReaderChapter",@"users_id",@"bookDestinationType",@"isFree"
             ];
}
- (NSString *)uniqueCode
{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),[self.bookID stringValue]];
}
+ (NSString *) primaryKey {
    return @"bookID";
}
#pragma mark - ZWCacheProtocol

@end
