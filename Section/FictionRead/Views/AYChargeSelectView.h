//
//  AYChargeSelectView.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYChargeSelectView : UIView
-(instancetype)initWithFrame:(CGRect)frame compete:(void(^)(void)) completeBlock;


@end

@interface AYChargeSelecCell : UICollectionViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
@end

@interface AYChargeSelectContainView : UIView

-(instancetype)initWithFrame:(CGRect)frame compete:(void(^)(void)) completeBlock;

+(void)showChargeSelectInView:(UIView*)parentView  compete:(void(^)(void)) completeBlock;
@end

NS_ASSUME_NONNULL_END
