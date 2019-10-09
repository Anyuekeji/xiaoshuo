//
//  LEAlertView+ZW.m
//  CallU
//
//  Created by liuyunpeng on 16/5/12.
//  Copyright © 2016年 liuyunpeng. All rights reserved.
//

#import "LEAlertView+ZW.h"
#import "TKAlertCenter.h"

UIKIT_EXTERN void occasionalHint(NSString *message) {
    if ([message isKindOfClass:NSNull.class]) {
        return;
    }
    if (message && message.length<1) {
        return;
    }
    static dispatch_semaphore_t semaphore = nil;

    if ( semaphore == nil ) semaphore = dispatch_semaphore_create(1);
//    if ([[TKAlertCenter defaultCenter] isAcitive]) {
//        return ;
//    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
       
            if ([message containsString:@"The operation"]) {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:AYLocalizedString(@"网络出现问题")];
            } else {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:message];
            }
            //一个展示时间过后再恢复信号量
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6f * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_semaphore_signal(semaphore);
            });
        });
    });
}
