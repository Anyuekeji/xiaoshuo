//
//  ZWBaseModel.m
//  CallU
//
//  Created by liuyunpeng on 16/3/8.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "ZWBaseModel.h"

@implementation ZWBaseModel

@end

@implementation ZWDBBaseModel
- (NSString *)uniqueCode {
    return [NSString stringWithFormat:@"%p",self];
}
@end
