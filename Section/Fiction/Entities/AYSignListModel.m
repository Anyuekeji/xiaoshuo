//
//  AYSignListModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/10.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYSignListModel.h"

@implementation AYSignListModel
- (NSString *)uniqueCode {
    
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),self.sign_day];
}
@end

