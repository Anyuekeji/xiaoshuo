//
//  ViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.

#import "LEDataTaskManager.h"

static char * const LEDataTaskManagerKey    =   "com.leaf.datatask";

@interface LEDataTaskManager () {
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
}

@end

@implementation LEDataTaskManager

+ (id) sharedManager {
    static LEDataTaskManager * _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (instancetype) init {
    if ( self = [super init] ) {
        [self _setUp];
    }
    return self;
}

- (void) _setUp {
    //
    _queue = dispatch_queue_create(LEDataTaskManagerKey, DISPATCH_QUEUE_CONCURRENT);
    _semaphore = dispatch_semaphore_create(LEDataTaskMaxConcurrent);
    [[[NSURLSession sharedSession] configuration] setRequestCachePolicy:NSURLRequestReloadIgnoringCacheData];
}

- (void) appendSessionDataTaskWithRequest : (NSURLRequest *) request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    dispatch_async(_queue, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ( completionHandler ) completionHandler(data, response, error);
            dispatch_semaphore_signal(_semaphore);
        }];
        [task resume];
    });
}

- (void) queue : (NSDictionary<NSURLRequest *, void(^)(NSData *data, NSURLResponse *response, NSError *error)> *) sessionTaskPair complete : (void(^)(NSError * error)) completeBlock {
    __block NSInteger counter = sessionTaskPair.count;
    __block NSError * _fetchedError = nil;
    dispatch_semaphore_t groupSemaphore = dispatch_semaphore_create(0);
    //
    [sessionTaskPair enumerateKeysAndObjectsUsingBlock:^(NSURLRequest * _Nonnull request, void (^ _Nonnull completeHandler)(NSData *, NSURLResponse *, NSError *), BOOL * _Nonnull stop) {
        dispatch_async(_queue, ^{
            dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
            NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                completeHandler(data, response, error);
                dispatch_semaphore_signal(_semaphore);
                //统计完成的计数|如果全部完成，表示可以执行回调block了
                counter --;
                if ( counter <= 0 ) {
                    dispatch_semaphore_signal(groupSemaphore);
                }
                //如果有错误
                if ( error ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _fetchedError = error;
                    });
                }
            }];
            [task resume];
        });
    }];
    //回调执行者
    dispatch_async(_queue, ^{
        dispatch_semaphore_wait(groupSemaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completeBlock ) completeBlock(_fetchedError);
        });
    });
}

- (NSURLSessionDataTask *) dataTaskWithRequest : (NSURLRequest *) request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    return [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
}

@end
