//
//  AYBookRackManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/21.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYBookRackManager.h"
#import "AYBookModel.h" //书本model
#import "AYBookrackViewController.h"

@implementation AYBookRackManager
+(BOOL)bookInBookRack:(NSString*)bookId
{
    BOOL rook = [[AYBookRackManager getBookrackViewController] bookIsAddToBookRack:bookId];
    return rook;
}
+(void)changeLocalBootToUnRecommentd:(NSString*)bookId
{
    [[AYBookRackManager getBookrackViewController] changeLocalBookToUnRecommentd:bookId];
}
//获取书架controller
+(AYBookrackViewController*)getBookrackViewController
{
    UINavigationController *rootNavViewController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
     UIViewController *rootSubViewController = rootNavViewController.viewControllers[0];
    NSArray<UIViewController*> *rootSubViewControllers =rootSubViewController.childViewControllers;
    for (UIViewController *subViewController in rootSubViewControllers)
    {
        if ([subViewController isKindOfClass:UITabBarController.class]){
                UITabBarController *tabController =(UITabBarController*)subViewController;
            return (AYBookrackViewController*)tabController.viewControllers[0];
        }
    }
    return nil;
}

+(void)sendBookHot:(NSString*)bookId type:(NSInteger)booktype
{
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:@(booktype)  forKey:@"type"];
        if (booktype ==1) {
            [params addValue:bookId forKey:@"book_id"];
        }
        else
        {
            [params addValue:bookId forKey:@"cartoon_id"];
        }
    }];
    [ZWNetwork post:@"HTTP_Post_Popularity" parameters:para success:^(id record)
     {
         //刷新书架
              [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddBookRackSuccess object:nil];
     } failure:^(LEServiceError type, NSError *error) {
     }];
}
//加入书到书架
+(void)addBookToBookRackWithBookID:(NSString*)bookId fiction:(BOOL)isFiction compete:(void(^)(void)) completeBlock failure : (void(^)(NSString * errorString)) failureBlock
{
    if([AYBookRackManager bookInBookRack:bookId])
    {
        occasionalHint(AYLocalizedString(@"已在书架"));
        if(completeBlock)
        {
            completeBlock();
        }
        return ;
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        [params addValue:bookId forKey:@"book_id"];
        [params addValue:(isFiction?@(1):@(2)) forKey:@"type"];
    }];
    [ZWNetwork post:@"HTTP_Post_Bookrack _Add" parameters:para success:^(id record)
     {
         //刷新书架
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddBookRackSuccess object:nil];
        [AYBookRackManager changeLocalBootToUnRecommentd:bookId];
         if (completeBlock) {
             completeBlock();
         }
     } failure:^(LEServiceError type, NSError *error) {
         if (failureBlock) {
             failureBlock([error localizedDescription]);
         }
     }];
}
@end
