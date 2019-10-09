//
//  LECollectionHelper.h
//  CallU
//
//  Created by liuyunpeng on 16/4/12.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LECollectionHelperProtocol <NSObject>

@required
+ (UICollectionViewCell<LECollectionHelperProtocol> *) collectionCellItem;
+ (NSString *) identifier;
- (CGSize) fittingSize;

@optional
+ (CGSize) cellSize;

@end

BOOL LERegisterXibForCollection(NSString * xibName, UICollectionView * collectionView);

BOOL LERegisterCellForCollection(Class<LECollectionHelperProtocol> cellClass, UICollectionView * collectionView);

id LEGetCellForCollection(Class<LECollectionHelperProtocol> cellClass, UICollectionView * collectionView, NSIndexPath * indexPath);

CGSize LEGetSizeForCellWithObject(Class<LECollectionHelperProtocol> cellClass, id obj, ...);

BOOL LEConfigurateCollectionCellBehaviorsFunctions(Class<LECollectionHelperProtocol> cellClass, SEL selector, ...);

void LEReleaseCellForCollection(UICollectionView * collectionView);
