//
//  AYMeModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/6.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYMeModel : ZWBaseModel
@property (nonatomic,strong)NSString *myNickName;//我的昵称
@property (nonatomic,strong)NSString *myHeadImage;//我的头像
@property (nonatomic,strong)NSString *myId;
@property (nonatomic,strong)NSString *myToken;
@property (nonatomic,strong)NSString *coinNum;  //金币数
@property (nonatomic,strong)NSNumber *expireTime;  //过期时间
@property (nonatomic,strong)NSNumber *createTime;  //创建时间
@property (nonatomic,strong)NSNumber *gender;  //性别
@property (nonatomic,strong)NSNumber *login_type;  //1、facebook 2、google 3、zalo 4、twriter 5，游客
@property (nonatomic,strong)NSString *myJpushId;  //推送id

@end

NS_ASSUME_NONNULL_END
