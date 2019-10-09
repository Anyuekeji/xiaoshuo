//
//  LESafariActivity.m
//  xiaoyuanplus
//
//  Created by 陈梦杉 on 14/12/9.
//  Copyright (c) 2014年 陈梦杉. All rights reserved.
//

#import "LESafariActivity.h"

@interface LESafariActivity ()

@property (nonatomic, strong) NSURL * URL;

@end

@implementation LESafariActivity

- (NSString *) activityType {
    return NSStringFromClass([self class]);
}

- (NSString *) activityTitle {
    return @"Open in Safari";
}

- (UIImage *) activityImage {
    return [UIImage imageNamed:@"Safari"];
}

- (BOOL) canPerformWithActivityItems : (NSArray *) activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
            return YES;
        }
    }
    return NO;
}

- (void) prepareWithActivityItems : (NSArray *) activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]]) {
            self.URL = activityItem;
            return;
        }
    }
}

- (void) performActivity {
    [[UIApplication sharedApplication] openURL:self.URL];
    [self activityDidFinish:YES];
}

@end
