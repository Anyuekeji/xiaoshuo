//
//  AYUtitle.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#import "NSData+CommonCrypto.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

#define  DEFAUT_READ_FONTSIZE 20

#define  DEFAUT_FONTSIZE 16

#define  DEFAUT_BIG_FONTSIZE 18

#define  DEFAUT_NORMAL_FONTSIZE 14

#define  DEFAUT_NORMAL_BIG_FONTSIZE 15


#define  DEFAUT_SMALL_FONTSIZE 13

#define  DEFAUT_SMALL_MORE_FONTSIZE 12

#define AY_CURRENT_COUNTRY AYCountryTailand


#define  DEFAUT_READ_RENDERSIZE CGSizeMake(SCREEN_WIDTH-26, SCREEN_HEIGHT-20-32) //文本渲染size

#define  DEFAUT_PAGE_SIZE 10

#define  SHAREVIEW_TAG 10265 //分享视图的tag

//判断是否是iphonex系列
UIKIT_EXTERN BOOL _ZWIsIPhoneXSeries(void);

//小说和漫画图片的高宽
#define CELL_BOOK_IMAGE_WIDTH ((isIPhone4|| isIPhone5)?(700/2.0f):ScreenWidth)*90.0f/348.0f
//#define CELL_BOOK_WIDTH (ScreenWidth-4*20)/3.0f
#define CELL_BOOK_IMAGE_HEIGHT CELL_BOOK_IMAGE_WIDTH*(12.5f/10.0f)

#define CELL_HORZON_BOOK_IMAGE_WIDTH (ScreenWidth-32)/3.0f
//#define CELL_BOOK_WIDTH (ScreenWidth-4*20)/3.0f
#define CELL_HORZON_BOOK_IMAGE_HEIGHT CELL_HORZON_BOOK_IMAGE_WIDTH*(12.5f/10.0f)

#define RSA_PRIVATE_KEY @"-----BEGIN PRIVATE KEY-----\nMIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMSBTGntK8TM4sh7\nhOxdtq3WZCfjjb3iI0rIiD9ilWAA7qeaWsxQI8yySiy6YGVsY4YF/CNNspgRx8VO\n8EZI42/hrzlcUOB/ATg1m7MlsPYn2HwSRZ6Kjnt2kUiH/HGsck4lhwMdDoqdN+/d\no+wkNYvF7H4udQbhnr2kpke0vqWPAgMBAAECgYAv0juTZ7mIGkhye8TcdO35Hjyf\njHw5IqhuEaE+s7Ige/mYZjMEl9guf5EXk3/UDu2ldx1mRglZgrI4LT7CDAj1Cy9h\nvEVESeb3pMt7473O84237lpAYPpjzrNSqO6pzRuKGwujzkS3RkDcML0J9vflwpc8\ngbi3+dr+riV3y61SUQJBAOEmFHNl27quvakK1Y+k6DWUjC4Ecj7tRMpM4VGedbE6\nnqjt9t7nlX4OqHBJILvU1UO9XzpJlgMJvXsTqUQObRkCQQDfbm+yogqCr1Nvq/cK\nJmY87LUQHpZLKwAMouP9ccuz/jgKZdzxBJlsAxYPa2mLLc2Q84FdOI8+vrmdggXf\nHlTnAkBMetj7kiAfu/flEi8VSlkuyjUL9KqyQXralV78kK099MGsdJklgtk/Js+E\nxPJ/m36OMifE7vYsNgTNaBJZceURAkEAghmbPsfuGNSgX+khSy6634TxlXZKC3D5\ncWI0IXLuq1s/JIbV1R3ZfDR71vSzm1BLX7j6vd5eQqnqCRYZ9yaBRwJBAMnvQfN8\ntfqyirOgEC75cBORWpddsq1IqUPB0DXt9xhgE/4hBIXnhHskm1BjLFuRZoV279zQ\nrUrx0j9PELNjx/0=\n-----END PRIVATE KEY-----"

NS_ASSUME_NONNULL_BEGIN

@interface AYUtitle : NSObject
+(CGFloat) getReadFontSize;

+(UIColor*) getReadBackgroundColor;
//获取设备的唯一id
+(NSString*)getDeviceUniqueId;
//获取服务器url
+(NSString*)getServerUrl;
+(NSString*)getAppName;
//enable or disable 阅读器的pangestrue
+(void)enableReadViewPangestrue:(BOOL)enalbe;
//显示充值视图
+(void)showChargeView:(void(^)(void)) completeBlock;
@end

/**
 *  @author allen
 *  @ingroup utility
 *  @brief 网络连接
 */
@interface AYUtitle (NetWork)
/**
 判断当前网络状态是否可用，有网则返回YES，断网则返回NO
 */
+ (BOOL)networkAvailable;

/** 获取当前网络状态的描述 */
+ (NSString *)currentReachabilityString;

/** 获取当前服务器环境，方便反馈问题 */
//+ (NSString *)environment;

@end

@interface AYUtitle (Conversion)

/**
 *  MD5转换
 *  @param str 要转换的字符串
 *  @return 转换后的字符串
 */
+ (NSString *)md5:(NSString *)str;

/**
 *  根据数字，过千后转k,过万后转换为w
 *  @param numStr 转换前的数字
 *  @return 转换后的数字
 */
+ (NSString *)curZnum:(NSString*)numStr;

@end

@interface AYUtitle (AppDeletate)

/**
 *  @return 获取appdelegate
 */
+ (AppDelegate *)getAppDelegate;

@end

@interface AYUtitle (Image)

+ (UIImage*) imageWithUIView:(UIView*) view;

@end

@interface AYUtitle (Encryption)
+ (NSString *)hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key  str:(NSData*)str;
@end

/**
 */
@interface AYUtitle (FileManager)

/**
 *  遍历文件夹获得文件夹大小，返回多少M,计算缓存大小时用到
 *  @param folderPath 文件地址
 *  @return 文件大小
 */
+ (float)folderSizeAtPath:(NSString*)folderPath;

/**
 *  清理缓存
 */
+ (void)cleanCache;
/**
 *  获取app的缓存大小 m
 */
+(float)appCacheSize;


@end

/**
 *  @author allen
 *  @ingroup utility
 *  @brief 对象类型转换
 */
@interface AYUtitle (Ios11)

/**
 *  获取安全区域
 *  @param view 视图
 */
+(UIEdgeInsets)al_safeAreaInset:(UIView*)view;

@end

/**
 *  @author allen
 *  @ingroup utility
 *  @brief 对象类型转换
 */
@interface AYUtitle (Fiction)
/**
 *  获取小说的渲染内容
 */
+(CGSize)getReadContentSize;

@end

@interface AYUtitle (Date)
+ (NSDate *)getDateWithTimeStr:(NSString *)str;
@end

@interface AYUtitle (AttributedString)
//获取NSAttributedString 的高度
+ (CGFloat)getAttributedStringHeight:(NSAttributedString *)aString width:(CGFloat)width attribute:(NSDictionary*)attribute;
//获取指定size 内能容下多少个字符
+ (NSInteger)strLenthToSize:(CGSize)viewSize  str:(NSString*)introduceStr attribute:(NSDictionary*)attribute;
@end

@interface AYUtitle (Color)
//比较严肃是否相等
+ (BOOL)compareRGBAColor1:(UIColor *)color1 withColor2:(UIColor *)color2;
@end

@interface AYUtitle (AppComment)
//弹出评论界面
+ (void)addAppReview;
@end

@interface AYUtitle (Coin)
//更新用户余额
+ (void)updateUserCoin: (void(^)(void)) completeBlock;
@end
NS_ASSUME_NONNULL_END
