//
//  AYADSkipManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/1/10.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *广告，推送，banner跳转管理
 */
@interface AYADSkipManager : NSObject
//更加model来跳转
+(void)adSkipWithModel:(id)model;
@end

NS_ASSUME_NONNULL_END
