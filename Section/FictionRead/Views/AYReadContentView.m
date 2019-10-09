//
//  AYReadContentView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYReadContentView.h"
#import "LEBatteryView.h" //电池视图
#import "AYShowTextView.h" //显示文本视图
#import <objc/runtime.h>

@interface AYReadContentView ()
@property (nonatomic,strong) AYShowTextView *textView;
@property (nonatomic,strong) UILabel *timeLable;
@property (nonatomic,strong) UILabel *percentLabel;
@property (nonatomic,strong) LEBatteryView *battery;
@end

@implementation AYReadContentView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    //self.backgroundColor = [UIColor clearColor];

    
    _battery = [[LEBatteryView alloc]initWithLineColor:[UIColor grayColor]];
    self.battery.frame = CGRectMake(15,ScreenHeight-15-20, 20, 20);
    [self addSubview:_battery];
    [self.battery runProgress:[self getCurrentBatteryLevel]];
    
    _timeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft numberOfLines:1];
    _timeLable.text = [self getCurrentTimes];
    _timeLable.frame = CGRectMake(_battery.left+_battery.width, _battery.top, 30, 20);
    [self addSubview:_timeLable];
    
    _percentLabel = [UILabel lableWithTextFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentRight numberOfLines:1];
    _percentLabel.text = [self getCurrentTimes];
    _percentLabel.frame = CGRectMake(ScreenWidth-15-30, _battery.top, 30, 20);
    [self addSubview:_percentLabel];
    _percentLabel.text = [NSString stringWithFormat:@"%.2ld",_currentPage/_totalPage];
    
    _textView = [[AYShowTextView alloc] initWithFrame:CGRectMake(16, 13, ScreenWidth-32, ScreenHeight-13-20-15)];
    [self addSubview:_textView];
    _textView.backgroundColor = [UIColor clearColor];

    _textView.textColor = _textColor;
    _textView.string = _content;
    _textView.font = _font;
    
    [_textView setNeedsDisplay];

}

#pragma mark - help -

-(NSString*)getCurrentTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    
    NSDate *datenow = [NSDate date];
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
    
}
- (CGFloat)getCurrentBatteryLevel
{
    UIApplication *app = [UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateActive||app.applicationState==UIApplicationStateInactive) {
        Ivar ivar=  class_getInstanceVariable([app class],"_statusBar");
        id status  = object_getIvar(app, ivar);
        for (id aview in [status subviews]) {
            int batteryLevel = 0;
            for (id bview in [aview subviews]) {
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame&&[[[UIDevice currentDevice] systemVersion] floatValue] >=6.0) {
                    Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                    if(ivar) {
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            return batteryLevel;
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }
    return 0;
}
@end
