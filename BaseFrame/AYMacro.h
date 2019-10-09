//
//  AYMacro.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#ifndef AYMacro_h
#define AYMacro_h

/**
 *  基本宏功能导入
 */
#ifdef DEBUG
#define Debug(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])
#define DPoint(p)  NSLog(@"%f,%f", p.x, p.y)
#define DSize(p)   NSLog(@"%f,%f", p.width, p.height)
#define DRect(p)   NSLog(@"%f,%f %f,%f", p.origin.x, p.origin.y, p.size.width, p.size.height)
#define DPrintf(fmt, ...) \
do { if (DEBUG) printf(fmt, ## __VA_ARGS__); } while (0)
#define DError(err) {if(err) Debug(@">>ERROR : %@", err);}
#else
#define Debug(format, ...)
#define DPoint(p)
#define DSize(p)
#define DRect(p)
#define DPrintf(fmt, ...)
#define DError(err)
#endif

#ifdef DEBUG
#define AYLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define AYLog(...)
#endif


#define IS_LOCAL_COUNTRY  [[LELanguageManager shareInstance] isTilandLanguage]?YES:NO

/*  空size   */
#define NANSIZE CGSizeMake(NAN, NAN)

/**
 *  输出本对象在ARC环境下的引用数
 *
 *  @param obj 对象
 *
 *  @return 输出引用数
 */
#define ARCRetainCount(obj) DPrintf(">>Retain count is %ld \n",CFGetRetainCount((__bridge CFTypeRef)obj))

/**
 *  是否为高清屏
 *
 *  @return YES|NO
 */
#define isRetina ([[UIScreen mainScreen] scale] > 1.0f)

/**
 *  是否为模拟器
 *
 *  @return YES|NO
 */
#define IsSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

/**
 *  系统版本号
 */
#define IOS_VERSION                                 [[[UIDevice currentDevice] systemVersion] floatValue]

/**
 *  系统版本比较
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/**
 *  是否为iOS7
 */
#define isIOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")

/**
 *  是否为iOS8
 */
#define isIOS8 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

/**
 *  是否为iOS11
 */
#define isIOS11 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")
/**
 *  是否为iPhone6|6s
 */
#define isIPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

/**
 *  是否为iPhone6Plus|6sPlus
 */
#define isIPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
/**
 *  是否为iPhone5|5s
 */
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
/**
 *  是否为iPhone4|4s
 */
#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

/**
 *  是否为iPhone x
 */
#define isIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO)

//判断iPHoneXr
#define SCREENSIZE_IS_XR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

//判断iPHoneX、iPHoneXs
#define SCREENSIZE_IS_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)
#define SCREENSIZE_IS_XS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

//判断iPhoneXs Max
#define SCREENSIZE_IS_XS_MAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

#define IS_IPhoneX_All ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

#define UI_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define UI_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define UI_IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)


/**
 *  是否为iPad
 */
#define isIpad ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

/**
 *  颜色设置
 */
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, v) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:v]


//弱引用
#define LEWeakSelf(type)  __weak typeof(type) weak##type = type;
//强引用
#define LEStrongSelf(type)  __strong typeof(type) type = weak##type;

#define LEIphoneXSafeBottomMargin  34.f


/**
 *  图片
 */
#define LEImage(image) [UIImage imageNamed:image]
/**
 *  屏幕宽
 */
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define SCREEN_WIDTH    ScreenWidth
/**
 *  屏幕高
 */
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define SCREEN_HEIGHT   ScreenHeight
/**
 *  NSUserDefaults
 */
#define uDefaults   [NSUserDefaults standardUserDefaults]
/**
 *  当前系统版本
 */
#define curVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

/**
 * 状态栏的高度
 */
#define STATUS_BAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

#define Height_TopBar (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT)
/**
 * tabbar的高度
 */
#define Height_TapBar (IS_IPhoneX_All ? 83.0f:49.0f)

#define Height_BottomSafe (IS_IPhoneX_All? 34.0f:0.0f)

/**
 * 导航栏的高度
 */
#define NAVIGATION_BAR_HEIGHT 44

/**
 * 标签栏的高度
 */
#define SEGMENT_BAR_HEIGHT  36




#ifndef zw_dispatch_main_sync_safe
#define zw_dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

//=====================单例==================
// @interface
#define singleton_interface(className) \
+ (className *)shared;


// @implementation
#define singleton_implementation(className) \
static className *_instance; \
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (className *)shared \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
}

#endif /* AYMacro_h */
