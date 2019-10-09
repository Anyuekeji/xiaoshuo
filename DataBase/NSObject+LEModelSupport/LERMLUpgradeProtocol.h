//
//  LERMLUpgradeProtocol.h
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMObject;

@protocol LERMLUpgradeProtocol <NSObject>

/**
 *  属性值合并或者转移可以实现此方法
 *
 *  @param oldSchemaVersion 版本号变更
 */
+ (void(^)(RLMObject * oldObject, RLMObject * newObject)) upgradePropertyAssignedValueChangedForSchemaVersion : (uint64_t) oldSchemaVersion;

/**
 *  属性名称变更实现此方法，映射关系为旧属性名->新属性名
 *
 *  @param oldSchemaVersion 版本号变更
 *
 *  @return 旧－>新属性名映射关系
 */
+ (NSDictionary<NSString *, NSString *> *) upgradePropertyNameModyfiedForSchemaVersion : (uint64_t) oldSchemaVersion;

@end
