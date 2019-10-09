//
//  LERMLRealm.h
//  CallU
//
//  Created by 刘云鹏 on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "LEBaseModel.h"

#define RMLRealmCurrentVersion  21

@interface LERMLRealm : NSObject
/**
 *  应用启动需要执行的操作
 */
+ (void) launchProgress;
/**
 *  清除数据库
 */
+ (void) cleanRealm;

/**
 *  切换数据库
 */
+ (void) switchRealm;
@end
