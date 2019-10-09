//
//  AYCartoonReadModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/4.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonReadModel.h"

@implementation AYCartoonReadModel
- (NSString *)uniqueCode {
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),self.currrenReadSectionId];

}

+ (NSString *) primaryKey {
    return @"currrenReadSectionId";
}

@end
