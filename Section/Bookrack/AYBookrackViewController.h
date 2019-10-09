//
//  AYBookrackViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "LECollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYBookrackViewController : LECollectionViewController
//判读书籍是否在书架
-(BOOL)bookIsAddToBookRack:(NSString*)bookId;
//变为不是推荐状态
-(void)changeLocalBookToUnRecommentd:(NSString*)bookId;
@end

NS_ASSUME_NONNULL_END
