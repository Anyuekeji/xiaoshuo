//
//  AYAPPUpdateModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/1/4.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYAPPUpdateModel : ZWBaseModel
@property(nonatomic,strong) NSString *version_code; //版本号
@property(nonatomic,strong) NSString *apk_url;//更新链接
@property(nonatomic,strong) NSString *upgrade_point;//更新提示
@property(nonatomic,strong) NSString *types;//1升级，0不升级，2强制升级
@end

NS_ASSUME_NONNULL_END
