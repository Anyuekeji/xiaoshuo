//
//  AYQAModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/26.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AYQAModel : ZWBaseModel
@property (nonatomic,strong)NSString *question;//问题
@property (nonatomic,strong)NSString *answer;//答案
@property (nonatomic,assign) BOOL expand;//是否展开
@property (nonatomic,assign) BOOL qaId;//是否展开

@end

NS_ASSUME_NONNULL_END
