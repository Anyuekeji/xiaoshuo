//
//  AYFictionTableViewCell.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/2.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LELineTableViewCell.h"


NS_ASSUME_NONNULL_BEGIN

@interface AYFictionTableViewCell : LELineTableViewCell
-(void)fillCellWithModel:(id)model;
@end

//免费书籍界面cell
@interface AYFreeBookTableViewCell : AYFictionTableViewCell
/**
 *freeFlag 是否添加免费标记
 */
-(void)fillCellWithModel:(id)model freeFlag:(BOOL)freeFlag;
@end

//漫画界面cell
@interface AYCartoonTableViewCell : AYFictionTableViewCell
@end


//推荐头部cell
@interface AYFictionRecomendHeadTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
@end


//一行三个cell
@interface AYFictionThreeTableViewCell : LETableViewCell
@property (strong, nonatomic) UICollectionView *collectionView;
-(void)fillCellWithModel:(id)model;
@end

//一行三个cell，水平可以滚动
@interface AYFictionHorizontalScrollAnimateTableViewCell : LETableViewCell
-(void)fillCellWithModel:(id)model;
@property (strong, nonatomic) UICollectionView *collectionView;

@end

//collection cell
@interface AYFictionHorizontalScrollCollectionViewCell : UICollectionViewCell
-(void)filCellWithModel:(id)model;
@end

@interface AYFictionCollectionViewCell : UICollectionViewCell
-(void)filCellWithModel:(id)model;
@end

//热门搜索
@interface AYHotSearchTableViewCell : UICollectionViewCell
-(void)filCellWithModel:(id)model row:(NSInteger)row;
@end
NS_ASSUME_NONNULL_END
