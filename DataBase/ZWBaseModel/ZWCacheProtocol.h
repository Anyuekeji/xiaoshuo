//
//  ZWCacheProtocol.h
//  BingoDu
//
//  Created by liuyunpeng on 16/12/5.
//  Copyright © 2016年 2.1.6. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZWCacheProtocol <NSObject>
@required
/**
 *  对象唯一识别符
 */
- (NSString *)uniqueCode;
@end
