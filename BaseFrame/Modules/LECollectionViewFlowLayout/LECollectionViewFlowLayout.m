//
//  LECollectionViewFlowLayout.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/11.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LECollectionViewFlowLayout.h"

//居中卡片宽度与据屏幕宽度比例

@implementation LECollectionViewFlowLayout

//初始化方法
- (void)prepareLayout {
    [super prepareLayout];
}

//设置放大动画
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //扩大控制范围，防止出现闪屏现象
    CGRect bigRect = rect;
    bigRect.size.width = rect.size.width + 2*[self cellWidth];
    bigRect.origin.x = rect.origin.x - [self cellWidth];
    
    NSArray *arr = [self getCopyOfAttributes:[super layoutAttributesForElementsInRect:bigRect]];
    //屏幕中线
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width/2.0f;
    //刷新cell缩放
    for (UICollectionViewLayoutAttributes *attributes in arr) {
        CGFloat distance = fabs(attributes.center.x - centerX);
        //移动的距离和屏幕宽度的的比例
        CGFloat apartScale = distance/self.collectionView.bounds.size.width;
        //把卡片移动范围固定到 -π/4到 +π/4这一个范围内
        CGFloat scale = fabs(cos(apartScale * M_PI/2));
        //设置cell的缩放 按照余弦函数曲线 越居中越趋近于1
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return arr;
}

#pragma mark 配置方法

//卡片宽度
- (CGFloat)cellWidth {
    
    return CELL_HORZON_BOOK_IMAGE_WIDTH;
}

//卡片间隔
- (float)cellMargin {
    return 10;
}

#pragma mark 约束设定

//cell大小
- (CGSize)itemSize {
    return CGSizeMake([self cellWidth],CELL_HORZON_BOOK_IMAGE_HEIGHT);
}
//防止报错 先复制attributes
- (NSArray *)getCopyOfAttributes:(NSArray *)attributes
{
    NSMutableArray *copyArr = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        [copyArr addObject:[attribute copy]];
    }
    return copyArr;
}


//是否需要重新计算布局
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return true;
}
@end
