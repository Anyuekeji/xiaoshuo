//
//  LEUtil.m
//  yckx
//
//  Created by liuyunpeng on 15/7/7.
//  Copyright (c) 2015年 liuyunpeng. All rights reserved.
//

#import "LEUtil.h"

#import "NSString+LEAF.h"

#import "LEService.h"
#import "LEFileManager.h"

/**
 *  计算需求时间和当前时间的差别
 *
 *  @param time 当前时间
 *
 *  @return 比较值
 */
NSString * LETimeByNow(NSDate * time) {
    NSString *timeText=@"";
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:(NSCalendarUnitYear |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay |
                                                         NSCalendarUnitHour |
                                                         NSCalendarUnitMinute |
                                                         NSCalendarUnitSecond)
                                               fromDate:time
                                                 toDate:[NSDate date] options:0];
    static NSDateFormatter * formatter = nil;
    if ( !formatter ) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    if ([components year]) {
        timeText = [[formatter stringFromDate:time] substringToIndex:10];
    } else if ([components month]) {
        timeText = [[formatter stringFromDate:time] substringToIndex:10];
    } else if ([components day]) {
        if ([components day] > 7) {
            timeText = [[formatter stringFromDate:time] substringToIndex:10];
        } else {
            timeText = [NSString stringWithFormat:@"%ld%@", (long)[components day],AYLocalizedString(@"天前")];
        }
    } else if ([components hour]) {
        timeText = [NSString stringWithFormat:@"%ld%@", (long)[components hour],AYLocalizedString(@"小时前")];
    } else if ([components minute]) {
        if ([components minute] < 0) {
            timeText = AYLocalizedString(@"刚刚");
        } else {
            timeText = [NSString stringWithFormat:@"%ld%@", (long)[components minute],AYLocalizedString(@"分钟前")];
        }
    } else if ([components second]) {
        if ([components second] < 30) {
            timeText =AYLocalizedString(@"刚刚");
        } else {
            timeText = [NSString stringWithFormat:@"%ld%@", (long)[components second],AYLocalizedString(@"秒前")];
        }
    } else {
        timeText = AYLocalizedString(@"刚刚");
    }
    return timeText;
}

/**
 *  NSDate对象转换成字符串形式
 *
 *  @param date   传入值
 *  @param format 格式
 *
 *  @return 字符串
 */
NSString * LEDateToText(NSDate * date, NSString * format) {
    static NSDateFormatter * formatter = nil;
    if ( !formatter ) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

/**
 *  字符串表示的时间变成NSDate对象
 *
 *  @param dateText 传入值
 *  @param formate  格式
 *
 *  @return 对象
 */
NSDate * LETextToDate(NSString * dateText, NSString * format) {
    static NSDateFormatter * formatter = nil;
    if ( !formatter ) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateText];
}
/**
 *  URL参数解析
 *
 *  @param query URL链接，带参数
 *
 *  @return 解析后的字典
 */
NSDictionary * LEParseQueryString(NSString * query) {
    if ( query ) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSArray * pairs = [query split:@"&"];
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            if ( elements.count >= 2) {
                NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                for ( NSUInteger overIndex = 2 ; overIndex < elements.count ; overIndex ++ ) {
                    val = [val stringByAppendingFormat:@"=%@", [[elements objectAtIndex:overIndex] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                [dict setObject:val forKey:key];
            } else if ( elements.count == 1 ) {
                NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [dict setObject:@"NULL" forKey:key];
            }
        }
        return dict;
    }
    return nil;
}

#import "UIImageView+YYWebImage.h"
#import "UIButton+YYWebImage.h"
/**
 全局设置按钮图片，需要UIButton+YYWebImage.h支持，注意内部模式将改变为填充满AlignmentFill
 
 @param button          按钮
 @param state           状态
 @param imageUrl        图片地址
 @param holderImageName 占位图片
 */
void LEButtonSet(UIButton * button, UIControlState state, NSString * imageUrl, NSString * holderImageName) {
    if ( button ) {
        if ( imageUrl == nil || imageUrl.length == 0 ) {
            if ( holderImageName ) {
                [button setImage:[UIImage imageNamed:holderImageName] forState:state];
            }
            return ;
        }
        NSURL * url = nil;
        if ( [imageUrl hasPrefix:API_IMAGE_HOST] || [imageUrl hasPrefix:@"http"] ) {
            url = [NSURL URLWithString:imageUrl];
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",API_IMAGE_HOST,imageUrl]];
        }
        if ( url ) {
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
            [button setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
            [button cancelImageRequestForState:state];
            LEWeakSelf(button)
            [button setImageWithURL:url
                           forState:state
                        placeholder:holderImageName == nil ? nil : [UIImage imageNamed:holderImageName] options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                            if(image && from ==YYWebImageFromRemote)
                            {
                                LEStrongSelf(button)
                                CATransition *transition = [CATransition animation];
                                transition.duration = 0.7;
                                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                transition.type = kCATransitionFade;
                                [button.layer addAnimation:transition forKey:@"btn_fade"];
                                [button setImage:image forState:state];
                            }
                        }];
        }
    }
}

/**
 *  全局设置网络图片，需要UIImageView+YYWebImage.h支持
 *
 *  @param imageView  目标图片
 *  @param imageUrl   网路地址
 *  @param holderName 占位图片名称
 */
void LEImageSet(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName) {
    LEImageSimpleSet(imageView, imageUrl, holderImageName);
}

/**
 *  全局图片设置网络图片, 注意不会对地址编码！
 *
 *  @param imageView       目标图片
 *  @param imageUrl        网络地址
 *  @param holderImageName 占位图片名称
 */
void LEImageSimpleSet(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName) {
    if ( imageView ) {
        if ( imageUrl == nil || imageUrl.length == 0 ) {
            imageView.image = holderImageName == nil ? nil : [UIImage imageNamed:holderImageName];
            return ;
        }
        NSURL * url = nil;
        if ( [imageUrl hasPrefix:API_IMAGE_HOST] || [imageUrl hasPrefix:@"http"] ) {
            url = [NSURL URLWithString:imageUrl];
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",API_IMAGE_HOST,imageUrl]];
        }
        if ( url ) {
            [imageView cancelCurrentImageRequest];
//            [imageView setImageWithURL:url
//                           placeholder:holderImageName == nil ? nil : [UIImage imageNamed:holderImageName]];
            LEWeakSelf(imageView)
            [imageView setImageWithURL:url
                           placeholder:holderImageName == nil ? nil : [UIImage imageNamed:holderImageName]
                               options:YYWebImageOptionSetImageWithFadeAnimation
                            completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                if(image && from ==YYWebImageFromRemote)
                                {
                                    LEStrongSelf(imageView)
                                    CATransition *transition = [CATransition animation];
                                    transition.duration = 0.8;
                                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                    transition.type = kCATransitionFade;
                                    [imageView.layer addAnimation:transition forKey:@"fade"];
                                    [imageView setImage:image];
                                }
                                
                                

                            }];
        }
    }
}

/**
 *  全局设置网络图片，需要UIImageView+YYWebImage.h支持
 *
 *  @param imageView  目标图片
 *  @param imageUrl   网路地址
 *  @param holderName 占位图片名称
 *  @param ^responseBlock  拿到的图片
 */
void LEImageSetResponse(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName, void(^responseBlock)(UIImage * image)){
    if ( imageView ) {
        if ( imageUrl == nil || imageUrl.length == 0 ) {
            imageView.image = holderImageName == nil ? nil : [UIImage imageNamed:holderImageName];
            return ;
        }
        NSURL * url = nil;
        if ( [imageUrl hasPrefix:API_IMAGE_HOST] || [imageUrl hasPrefix:@"http"]) {
            url = [NSURL URLWithString:imageUrl];
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",API_IMAGE_HOST,imageUrl]];
        }
        if ( url ) {
            [imageView cancelCurrentImageRequest];
            [imageView setImageWithURL:url
                           placeholder:holderImageName == nil ? nil : [UIImage imageNamed:holderImageName]
                               options:YYWebImageOptionSetImageWithFadeAnimation
                            completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                if ( responseBlock ) {
                                    responseBlock(image);
                                }
                            }];
        }
    }
}

/**
 *  检测当前链接是否有效
 *
 *  @param imageUrl  目标图片
 */
BOOL HPCheckImageUrlValid(NSString *imageUrl) {
    if (!imageUrl) return NO;
    NSURL * url = nil;
    if ([imageUrl hasPrefix:API_IMAGE_HOST] || [imageUrl hasPrefix:@"http"]) {
        url = [NSURL URLWithString:imageUrl];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",API_IMAGE_HOST,imageUrl]];
    }
    return !!url;
}

/**
 *  全局图片设置，需要AFNetworking支持,将在沙盒tmp文件夹中创建对应的缓存文件
 *
 *  @param imageView       目标图片
 *  @param imageUrl        网络地址
 *  @param holderImageName 占位图片名称
 */
void LEImageCacheInTmp(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName) {
    if ( imageUrl ) {
        NSString * fileName = [imageUrl md5];
        if ( [LEFileManager isFileExistsInTmp:fileName] ) {
            NSString * filePath = [LEFileManager filePathInTmpWithFileName:fileName];
            UIImage * image = [UIImage imageWithContentsOfFile:filePath];
            imageView.image = image;
        } else {
            LEImageSetResponse(imageView, imageUrl, holderImageName, ^(UIImage *image) {
                if ( image && ![LEFileManager isFileExistsInTmp:fileName] ) {
                    NSString * filePath = [LEFileManager createFileInTmpWithFileName:fileName];
                    NSData *imageData = UIImagePNGRepresentation(image);
                    [imageData writeToFile:filePath atomically:YES];
                }
            });
        }
    } else {
        imageView.image = holderImageName == nil ? nil : [UIImage imageNamed:holderImageName];
    }
}

/**
 *  打印所有可用字体
 */
void LEPrintAllFonts() {
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily) {
        DPrintf("----------------------\n");
        DPrintf("Family name: %s\n", [[familyNames objectAtIndex:indFamily] UTF8String]);
        fontNames = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        for ( indFont = 0; indFont<[fontNames count]; ++indFont) {
            DPrintf("--Font name: %s\n", [[fontNames objectAtIndex:indFont] UTF8String]);
        }
    }
    familyNames = nil;
    fontNames = nil;
}

/**
 *  文字内容在固定宽度固定字体下的高度
 *
 *  @param text 内容
 *  @param font 字体
 *  @param limitWidth 最大宽度
 *
 *  @return 最小高度
 */
CGFloat LETextHeight(NSString * text, UIFont * font, CGFloat limitWidth) {
    return ceil([text boundingRectWithSize:CGSizeMake(limitWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil].size.height);
}

/**
 *  文字内容在字体固定下最大占有宽度
 *
 *  @param text 内容
 *  @param font 字体
 *
 *  @return 最小宽度
 */
CGFloat LETextWidth(NSString * text, UIFont * font) {
    return ceil([text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0.0f) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil].size.width);
}

/**
 *  拨打电话
 *
 *  @param phoneNumber 电话号码
 */
void LETelephone(NSString * phoneNumber) {
    if ( phoneNumber ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]];
    }
}

