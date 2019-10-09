//
//  LEUtil.h
//  yckx
//
//  Created by liuyunpeng on 15/7/7.
//  Copyright (c) 2015年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  计算需求时间和当前时间的差别
 *
 *  @param time 当前时间
 *
 *  @return 比较值
 */
NSString * LETimeByNow(NSDate * time);

/**
 *  NSDate对象转换成字符串形式
 *
 *  @param date   传入值
 *  @param format 格式
 *
 *  @return 字符串
 */
NSString * LEDateToText(NSDate * date, NSString * format);

/**
 *  字符串表示的时间变成NSDate对象
 *
 *  @param dateText 传入值
 *  @param format  格式
 *
 *  @return NSDate对象
 */
NSDate * LETextToDate(NSString * dateText, NSString * format);

/**
 *  URL参数解析
 *
 *  @param query URL链接，带参数
 *
 *  @return 解析后的字典
 */
NSDictionary * LEParseQueryString(NSString * query);

/**
 全局设置按钮图片，需要UIButton+YYWebImage.h支持，注意内部模式将改变为填充满AlignmentFill

 @param button          按钮
 @param state           状态
 @param imageUrl        图片地址
 @param holderImageName 占位图片
 */
void LEButtonSet(UIButton * button, UIControlState state, NSString * imageUrl, NSString * holderImageName);

/**
 *  全局设置网络图片，需要UIImageView+YYWebImage.h支持
 *
 *  @param imageView  目标图片
 *  @param imageUrl   网路地址
 *  @param holderName 占位图片名称
 */
void LEImageSet(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName);

/**
 *  全局设置网络图片，需要UIImageView+YYWebImage.h支持
 *
 *  @param imageView  目标图片
 *  @param imageUrl   网路地址
 *  @param holderName 占位图片名称
 *  @param ^responseBlock  拿到的图片
 */
void LEImageSetResponse(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName, void(^responseBlock)(UIImage * image));


/**
 *  检测当前链接是否有效
 *
 *  @param imageUrl  目标图片
 *  @return  YES : 有效链接， NO：无效链接
 */
BOOL HPCheckImageUrlValid(NSString *imageUrl);

/**
 *  全局图片设置网络图片, 注意不会对地址编码！
 *
 *  @param imageView       目标图片
 *  @param imageUrl        网络地址
 *  @param holderImageName 占位图片名称
 */
void LEImageSimpleSet(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName);

/**
 *  全局图片设置，需要UIImageView+YYWebImage.h支持,将在沙盒tmp文件夹中创建对应的缓存文件
 *
 *  @param imageView       目标图片
 *  @param imageUrl        网络地址
 *  @param holderImageName 占位图片名称
 */
void LEImageCacheInTmp(UIImageView * imageView, NSString * imageUrl, NSString * holderImageName);

/**
 *  打印所有可用字体
 */
void LEPrintAllFonts();

/**
 *  文字内容在固定宽度固定字体下的高度
 *
 *  @param text 内容
 *  @param font 字体
 *  @param limitWidth 最大宽度
 *
 *  @return 最小高度
 */
CGFloat LETextHeight(NSString * text, UIFont * font, CGFloat limitWidth);

/**
 *  文字内容在字体固定下最大占有宽度
 *
 *  @param text 内容
 *  @param font 字体
 *
 *  @return 最小宽度
 */
CGFloat LETextWidth(NSString * text, UIFont * font);

/**
 *  拨打电话
 *
 *  @param phoneNumber 电话号码
 */
void LETelephone(NSString * phoneNumber);
