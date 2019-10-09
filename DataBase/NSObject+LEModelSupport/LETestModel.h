//
//  LETestModel.h
//  CallU
//
//  Created by liuyunpeng on 16/7/27.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import "LEBaseModel.h"
#import "LERMLRealm.h"

@interface LESubModel : ZWDBBaseModel

@property (nonatomic, strong) NSString * subModelName;
@property (nonatomic, assign) NSInteger subModelId;
@property (nonatomic, strong, readonly) RLMLinkingObjects * father;

@end
RLM_ARRAY_TYPE(LESubModel);

@interface LETestModel : ZWDBBaseModel

#if RMLRealmCurrentVersion > 0
@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) NSInteger modelId;
@property (nonatomic, strong) NSString * test;
@property (nonatomic, strong) RLMArray<LESubModel *><LESubModel> * subModels;
#else
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString * title;
#endif

@end


