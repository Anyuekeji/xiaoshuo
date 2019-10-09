//
//  ViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.

#import <Foundation/Foundation.h>

#define LEDataTaskMaxConcurrent     3

@interface LEDataTaskManager : NSObject

+ (id) sharedManager;

- (void) appendSessionDataTaskWithRequest : (NSURLRequest *) request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

- (void) queue : (NSDictionary<NSURLRequest *, void(^)(NSData *data, NSURLResponse *response, NSError *error)> *) sessionTaskPair complete : (void(^)(NSError * error)) completeBlock;

@end
