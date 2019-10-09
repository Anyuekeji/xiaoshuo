//
//  AYBookRackManager.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/21.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AYBookRackManager : NSObject
//判读书籍是否在书架
+(BOOL)bookInBookRack:(NSString*)bookId;
//变为不是推荐状态
+(void)changeLocalBootToUnRecommentd:(NSString*)bookId;
//上传人气值，每次进入阅读发送 type:1为小说 2为漫画
+(void)sendBookHot:(NSString*)bookId type:(NSInteger)booktype;
//加入书到书架
+(void)addBookToBookRackWithBookID:(NSString*)bookId fiction:(BOOL)isFiction compete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock;
@end

NS_ASSUME_NONNULL_END
