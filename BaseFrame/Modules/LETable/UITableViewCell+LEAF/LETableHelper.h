//
//  LETableHelper.h
//  BingoDu
//
//  Created by 刘云鹏 on 16/3/16.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LETableHelperProtocol <NSObject>

@required
+ (NSString *) identifier;
- (CGFloat) fittingSizeHeight;

@optional
+ (CGFloat) estimatedHeight;
+ (CGFloat) cellHeight;

@end

UIKIT_EXTERN BOOL LERegisterXibForTable(NSString * xibName, UITableView * tableView);

UIKIT_EXTERN BOOL LERegisterCellForTable(Class<LETableHelperProtocol> cellClass, UITableView * tableView);

UIKIT_EXTERN id LEGetCellForTable(Class<LETableHelperProtocol> cellClass, UITableView * tableView, NSIndexPath * indexPath);

UIKIT_EXTERN CGFloat LEGetHeightForCellWithObject(Class<LETableHelperProtocol> cellClass, id obj, ...);

UIKIT_EXTERN BOOL LEConfigurateCellBehaviorsFunctions(Class<LETableHelperProtocol> cellClass, SEL selector, ...);

UIKIT_EXTERN void LEReleaseCellForTable(UITableView * tableView);
