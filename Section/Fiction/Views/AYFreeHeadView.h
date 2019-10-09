//
//  AYFreeHeadView.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/22.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYFreeHeadView : UIView
-(instancetype)initWithFrame:(CGRect)frame  endTime:(NSInteger)endTime;
@end

@interface AYCommonHeadView : UIView
-(instancetype)initWithFrame:(CGRect)frame  title:(NSString*)title icon:(NSString*)iconName;

-(void)rotateOrStopImageView:(BOOL)rotate;
@end


@interface AYSearchHeadView : UICollectionReusableView
/**填充数据*/
-(void)filCellWithModel:(NSString*)title;
@end
NS_ASSUME_NONNULL_END
