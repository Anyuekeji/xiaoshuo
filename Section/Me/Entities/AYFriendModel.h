//
//  AYFriendModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/22.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFriendModel : ZWBaseModel
@property (nonatomic,strong)NSString *friendName;//朋友名字
@property (nonatomic,strong)NSString *invateTime;//邀请时间
@property (nonatomic,strong)NSString *coinNum;//赠送数
@end

NS_ASSUME_NONNULL_END
