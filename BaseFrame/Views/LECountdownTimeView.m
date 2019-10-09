//
//  LECountdownTimeView.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/22.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LECountdownTimeView.h"
@interface LECountdownTimeView ()
//@property(nonatomic,assign) long long endTime;
@property(nonatomic,strong)dispatch_source_t timer;

@property(nonatomic,strong) UILabel *dayLable;
@property(nonatomic,strong) UILabel *hourLable;
@property(nonatomic,strong) UILabel *minuteLable;
@property(nonatomic,strong) UILabel *secondLable;

@end
@implementation LECountdownTimeView

-(instancetype)initWithFrame:(CGRect)frame endTime:(long long)endTime
{
    self = [super initWithFrame:frame];
    if (self) {
        [self startCalculteTime:endTime];
    }
    return self;
}
-(void)createTimeViewWithDay:(NSString*)day hour:(NSString*)hour min:(NSString*)mintue  seconds:(NSString*)second
{
    
    if (self.hourLable)
    {
        if (day) {
            self.dayLable.text = day;
        }
        self.hourLable.text = hour;
        self.minuteLable.text = mintue;
        self.secondLable.text = second;

    }
    else
    {
        CGFloat startOriginX = 2;
        if (day)
        {
            self.dayLable =   [self createLableWithText:day];
            self.dayLable.left = startOriginX;
            startOriginX += self.dayLable.width+3;
            [self addSubview:self.dayLable];
            
            //创建天
            UILabel *dayTextLalbe = [self createLableWithText:AYLocalizedString(@"天")];
            dayTextLalbe.left = startOriginX;
            dayTextLalbe.backgroundColor = [UIColor clearColor];
            dayTextLalbe.textColor = UIColorFromRGB(0x444444);
            dayTextLalbe.font = [UIFont systemFontOfSize:13];
            startOriginX += dayTextLalbe.width+3;
            [self addSubview:dayTextLalbe];
        }
  
        
        //创建小时
        self.hourLable = [self createLableWithText:hour];
        self.hourLable.left = startOriginX;
        startOriginX += self.hourLable.width+3;
        [self addSubview:self.hourLable];
        
        //创建:
        UILabel *maoLalbe = [self createLableWithText:@":"];
        maoLalbe.left = startOriginX;
        maoLalbe.backgroundColor = [UIColor clearColor];
        maoLalbe.textColor = UIColorFromRGB(0x444444);

        startOriginX += maoLalbe.width+3;
        [self addSubview:maoLalbe];
        
        //创建分钟
        self.minuteLable = [self createLableWithText:mintue];
        self.minuteLable.left = startOriginX;
        startOriginX += self.minuteLable.width+3;
        [self addSubview:self.minuteLable];
        
        //创建:
        maoLalbe = [self createLableWithText:@":"];
        maoLalbe.left = startOriginX;
        startOriginX += maoLalbe.width+3;
        maoLalbe.backgroundColor = [UIColor clearColor];
        maoLalbe.textColor = UIColorFromRGB(0x444444);

        [self addSubview:maoLalbe];
        //创建秒
        self.secondLable = [self createLableWithText:second];
        self.secondLable.left = startOriginX;
        startOriginX += self.secondLable.width+3;
        [self addSubview:self.secondLable];
    }
}

-(UILabel *)createLableWithText:(NSString*)timeStr
{
    UILabel *timeLable = [UILabel lableWithTextFont:[UIFont boldSystemFontOfSize:13] textColor:UIColorFromRGB(0xffffff) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    timeLable.layer.cornerRadius = 5.0f;
    timeLable.clipsToBounds = YES;
    timeLable.text = timeStr;
    CGFloat strWidth = LETextWidth(timeStr, timeLable.font);
    timeLable.frame = CGRectMake(0, (self.height-26)/2.0f, (strWidth<26 && ![timeStr containsString:@":"])?26:strWidth, 26);
    timeLable.backgroundColor = UIColorFromRGB(0X444444);
    return timeLable;
}
-(void)startCalculteTime:(long long)endTime
{

    LEWeakSelf(self)
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    long long currentTime = (long long)[datenow timeIntervalSince1970];
    // 计算时间差值
    NSInteger secondsCountDown = endTime - currentTime;
    if (secondsCountDown<=0) {
        return;
    }
    if (_timer == nil) {
        __block NSInteger timeout = secondsCountDown; // 倒计时时间
        if (timeout!=0)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC,  0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                LEStrongSelf(self)
                if(timeout <= 0){ //  当倒计时结束时做需要的操作: 关闭 活动到期不能提交
                    dispatch_source_cancel(self.timer);
                    self.timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                    });
                }
                else
                {
                    // 倒计时重新计算 时/分/秒
                    NSInteger days = (int)(timeout/(3600*24));
                    NSInteger hours = (int)((timeout-days*24*3600)/3600);
                    NSInteger minute = (int)(timeout-days*24*3600-hours*3600)/60;
                    NSInteger second = timeout - days*24*3600 - hours*3600 - minute*60;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *day =[NSString stringWithFormat:@"%02ld", days];
                        NSString *hour =[NSString stringWithFormat:@"%02ld", hours];
                        NSString *min =[NSString stringWithFormat:@"%02ld",minute];
                        NSString *sec =[NSString stringWithFormat:@"%02ld",second];
                        [self createTimeViewWithDay:((days<=0)?nil:day) hour:hour min:min seconds:sec];
                        
                    });
                    timeout--; // 递减 倒计时-1(总时间以秒来计算)
                }
            });
            dispatch_resume(_timer);
        }
    }
}
@end
