//
//  AYSignInView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/5.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SIGN_LINEVIEW_TAG 56455

NS_ASSUME_NONNULL_BEGIN

@interface AYSubSignInView : UIView
-(instancetype)initWithFrame:(CGRect)frame  coinNum:(NSInteger)coinNum;

@property(nonatomic,assign)BOOL selected;
@end


@interface AYSignInView : UIView
-(instancetype)initWithFrame:(CGRect)frame  dayNum:(NSInteger)signDayNum compete:(void(^)(void)) completeBlock;;
@end

//任务里的
@interface AYTaskSignInView : UIView
-(instancetype)initWithFrame:(CGRect)frame  dayNum:(NSInteger)signDayNum compete:(void(^)(void)) completeBlock;

@property (nonatomic, copy) void (^signDataLoadFinish)(void);

@end

@interface AYSignInContainView : UIView
-(instancetype)initWithFrame:(CGRect)frame  dayNum:(NSInteger)signDayNum compete:(void(^)(void)) completeBlock;;

+(void)showSignViewInView:(UIView*)parentView  frame:(CGRect)frame dayNum:(NSInteger)signDayNum bottom:(BOOL)isFromBottom compete:(void(^)(void)) completeBlock;;
@end

NS_ASSUME_NONNULL_END
