//
//  ZWDeviceSupport.h
//  BingoDu
//
//  Created by 刘云鹏 on 16/5/18.
//  Copyright © 2016年 NHZW. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  网络环境类型
 */
typedef NS_ENUM(NSUInteger, ZWNetworkType) {
    /**
     *  未知
     */
    ZWNetworkTypeUnknow         =   0,
    /**
     *  WIFI
     */
    ZWNetworkTypeWIFI           =   1,
    /**
     *  2G
     */
    ZWNetworkType2G             =   2,
    /**
     *  3G
     */
    ZWNetworkType3G             =   3,
    /**
     *  4G
     */
    ZWNetworkType4G             =   4,
};

/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 设备信息获取
 */
@interface ZWDeviceSupport : NSObject

/**
 *  内网IP地址
 */
+ (NSString *) ipAddress;

/**
 *  MAC地址
 */
+ (NSString *) macAddress;

/**
 *  运营商标识号码
 */
+ (NSString *) carrier;

/**
 *  运营商名称
 */
+ (NSString *) carrierName;

/**
 *  有效期为一次的UUID算法串MD5结果|下次进入将得到不同的结果
 */
+ (NSString *) onceUUID;

/**
 *  设备UUID
 */
+ (NSString *) deviceUUID;

/**
 *  网络环境类型枚举
 */
+ (ZWNetworkType) networkType;

/**
 *  app包名
 */
+ (NSString *) bundleIdentifier;

/**
 *  app版本号Version
 */
+ (NSString *) appVersion;

/**
 *  build版本号
 */
+ (NSString *) buildVersion;

/**
 *  app应用名
 */
+ (NSString *) appDisplayName;

/**
 *  设备名称字符串
 */
+ (NSString *) platformString;

/**
 *  IDFA
 */
+ (NSString *) idfaString;

/**
 *  设备名称
 */
+ (NSString *) deviceName;

/**
 *  系统版本号
 */
+ (NSString *) systemVersion;
/**
 *  获取屏幕分辨率 640*960
 */
+ (NSString *) screenSizeStirng;

/**
 *  外网IP地址
 */
+ (void) getExternalIpAddressComplete : (void (^)(NSString * ipAddress)) complete;

@end
