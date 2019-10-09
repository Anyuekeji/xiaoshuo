//
//  NSTimer+LEAF.m
//  LE
//
//  Created by liuyunpeng on 15/10/14.
//  Copyright © 2015年 liuyunpeng. All rights reserved.
//

#import "NSTimer+LEAF.h"

@implementation NSTimer (LEAF)

-(void)pauseTimer
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate distantFuture]];
}


-(void)resumeTimer
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end
