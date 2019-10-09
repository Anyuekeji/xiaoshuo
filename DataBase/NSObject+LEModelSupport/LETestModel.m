//
//  LETestModel.m
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "LETestModel.h"

@implementation LESubModel

+ (NSString *) primaryKey {
    return @"subModelId";
}

+ (NSDictionary<NSString *,RLMPropertyDescriptor *> *)linkingObjectsProperties {
    return @{
             @"father": [RLMPropertyDescriptor descriptorWithClass:LETestModel.class propertyName:@"subModels"],
             };
}

- (NSString *)uniqueCode {
    return self.subModelName ? : [NSString stringWithFormat:@"%p",self];
}

@end

@implementation LETestModel

+ (NSString *)primaryKey {
    return @"modelId";
}

+ (NSDictionary<NSString *,NSString *> *)upgradePropertyNameModyfiedForSchemaVersion:(uint64_t)oldSchemaVersion {
#if RMLRealmCurrentVersion == 1
    if ( oldSchemaVersion < 1 ) {
        return @{@"id":@"modelId",
                 @"title":@"name"};
    }
#endif
    return nil;
}

+ (void (^)(RLMObject *, RLMObject *))upgradePropertyAssignedValueChangedForSchemaVersion:(uint64_t)oldSchemaVersion {
#if RMLRealmCurrentVersion == 1
    if ( oldSchemaVersion < 1 ) {
        return  ^(RLMObject * oldObject, RLMObject * newObject) {
            newObject[@"test"] = [NSString stringWithFormat:@"%@-%@", oldObject[@"title"], oldObject[@"id"]];
        };
    }
#endif
    return nil;
}

- (NSString *)uniqueCode {
    return self.name ? : [NSString stringWithFormat:@"%p",self];
}

@end
