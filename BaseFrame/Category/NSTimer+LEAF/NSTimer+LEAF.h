//
//  NSTimer+LEAF.h
//  LE
//
//  Created by liuyunpeng on 15/10/14.
//  Copyright © 2015年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (LEAF)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end
