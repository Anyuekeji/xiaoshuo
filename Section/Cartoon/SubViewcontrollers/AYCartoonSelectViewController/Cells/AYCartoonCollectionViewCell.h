//
//  AYCartoonCollectionViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonCollectionViewCell : UICollectionViewCell
/**填充数据*/
-(void)filCellWithModel:(id)model;
@end


@interface ALCartoonSelectHeadView : UICollectionReusableView
/**填充数据*/
-(void)filCellWithModel:(id)model;
@end
@interface ALCartoonSelectFootView : UICollectionReusableView

@property (nonatomic, copy) void(^ayClickFootAction)(BOOL expand);

@end

NS_ASSUME_NONNULL_END
