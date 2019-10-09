//
//  AYCoinSectionModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/27.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYCoinSectionModel : NSObject
@property(nonatomic,strong) NSMutableAttributedString* sectionTitle;
@property(nonatomic,strong) NSMutableArray *subItemArray;
@property(nonatomic,assign) BOOL expand;
@end

NS_ASSUME_NONNULL_END
