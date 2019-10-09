//
//  AYFictionReadModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/1.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionReadModel.h"

@implementation AYFictionReadModel
- (NSString *)uniqueCode {

    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),[self.fictionID stringValue]];
}

+ (NSString *) primaryKey {
    return @"currrenReadSectionId";
}
@end
