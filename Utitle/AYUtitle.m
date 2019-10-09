//
//  AYUtitle.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/30.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYUtitle.h"
#import <YYKit/YYKit.h>
#import "LESandBoxHelp.h"
#import "LEFileManager.h"
#import "ZWCacheHelper.h"
#import "LERMLRealm.h"
#import <SDImageCache.h>
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"
#import "LEKeyChain.h"
#import "ZWDeviceSupport.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AYBannerModel.h"
#import "AYADSkipManager.h"
#import "AYChargeSelectView.h" //充值界面

UIKIT_EXTERN BOOL _ZWIsIPhoneXSeries() {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    
    return iPhoneXSeries;
}

@implementation AYUtitle
+(CGFloat) getReadFontSize
{
    CGFloat fontsize =0;
    NSNumber *fontNum = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultReadFontSize];
    if (fontNum) {
        fontsize = [fontNum floatValue];
    }
    else
    {
        fontsize = DEFAUT_READ_FONTSIZE;
    }
    return  fontsize;
}
+(UIColor*) getReadBackgroundColor
{
    UIColor *dafalutColor =[UIColor whiteColor];
    
    NSData *objColor = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefaultReadBackColor];
    UIColor *currentColor = [NSKeyedUnarchiver unarchiveObjectWithData:objColor];
                        
    if (currentColor) {
        dafalutColor = currentColor;
    }
    return  dafalutColor;
}
+(NSString*)getDeviceUniqueId
{
    //从本地沙盒取
    NSString *uqid = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUniqueDeviceId];
    
    if (!uqid) {
        //从keychain取
        uqid = (NSString *)[LEKeyChain readObjectForKey:kUserDefaultUniqueDeviceId];
        
        if (uqid) {
            [[NSUserDefaults standardUserDefaults] setObject:uqid forKey:kUserDefaultUniqueDeviceId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } else {
            //从pasteboard取
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            id data = [pasteboard dataForPasteboardType:kUserDefaultUniqueDeviceId];
            if (data) {
                uqid = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            if (uqid) {
                [[NSUserDefaults standardUserDefaults] setObject:uqid forKey:kUserDefaultUniqueDeviceId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [LEKeyChain saveObject:uqid forKey:kUserDefaultUniqueDeviceId];
            } else {
                //获取idfa
                uqid = [ZWDeviceSupport idfaString];
                //idfa获取失败的情况，获取idfv
                if (!uqid || [uqid isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                    //idfv获取失败的情况，获取uuid
                    uqid = [ZWDeviceSupport deviceUUID];
                }
                [[NSUserDefaults standardUserDefaults] setObject:uqid forKey:kUserDefaultUniqueDeviceId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [LEKeyChain saveObject:uqid forKey:kUserDefaultUniqueDeviceId];
                
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                NSData *data = [uqid dataUsingEncoding:NSUTF8StringEncoding];
                [pasteboard setData:data forPasteboardType:kUserDefaultUniqueDeviceId];
                
            }
        }
    }
    return uqid;
}
+(NSString*)getServerUrl
{
    if (IS_LOCAL_COUNTRY)
    {
        return BASE_URL_HTTPS;
    }
    else
    {
        return BASE_URL_HTTPS_ID;
    }
}
+(NSString*)getAppName
{
    NSString *appName=
    [[NSBundle bundleWithPath:[[NSBundle mainBundle]
                               pathForResource:([[LELanguageManager shareInstance] isTilandLanguage]?@"th":@"id")
                               ofType:@"lproj"]]
     localizedStringForKey:(@"CFBundleDisplayName")
     value:nil
     table:@"InfoPlist"];
    return appName;
}
+(void)enableReadViewPangestrue:(BOOL)enalbe
{
    if(AY_CURRENT_COUNTRY != AYCountryVietnam)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEnableOrDisablePageGestureEvents object:@(enalbe)];
    }
}
+(void)showChargeView:(void(^)(void)) completeBlock
{
    if (AY_CURRENT_COUNTRY == AYCountryVietnam) {
        

    }
    else
    {
        [AYChargeSelectContainView showChargeSelectInView:[AYUtitle getAppDelegate].window compete:^{
            if (completeBlock) {
                completeBlock();
            }
        }];
    }
}
@end

@implementation AYUtitle (NetWork)

+ (BOOL)networkAvailable
{
    return [[ZWNetwork sharedInstance] isNetworkConnected];
}

+ (NSString *)currentReachabilityString {
    return [ZWNetwork currentReachabilityString];
}

//+ (NSString *)environment {
//    return ENVIRONMENT_NAME;
//}

@end

#import <CommonCrypto/CommonDigest.h>


@implementation AYUtitle (Conversion)

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSString *)curZnum:(NSString*) numStr
{
    if (numStr)
    {
        if (numStr.length >= 5)
        {
            // 评价过万
            int result = [numStr intValue] / 10000;
            char reminder = [numStr characterAtIndex:numStr.length - 1 - 3];
            return  reminder == '0' ? [NSString stringWithFormat:@"%dW", result] : [NSString stringWithFormat:@"%d.%cW", result, reminder];
        }
        else if (numStr.length == 4)
        {
            // 评价过千
            int result = [numStr intValue] / 1000;
            char reminder = [numStr characterAtIndex:numStr.length - 1 - 2];
            return  reminder == '0' ? [NSString stringWithFormat:@"%dK", result] : [NSString stringWithFormat:@"%d.%cK", result, reminder];
        } else
            return  numStr;
        
    }else
        return  @"0";
}
@end

@implementation AYUtitle (AppDeletate)

+ (AppDelegate *)getAppDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

@end

@implementation AYUtitle (Image)
+ (UIImage*) imageWithUIView:(UIView*) view
{
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return image;
}

+  (NSString *)HMacHashWithKey:(NSString *)key data:(NSString *)data{
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    //关键部分
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    //将加密结果进行一次BASE64编码。
    //NSString *hash = [HMAC base64EncodedStringWithOptions:0];
    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];

    return hash;
}

@end

@implementation AYUtitle (Encryption)

+(NSString *)hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key  str:(NSData*)str{
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    unsigned char result[size];
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    CCHmac(alg, cKey, strlen(cKey), str.bytes, str.length, result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:size * 2];
    for (int i = 0; i < size; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

@end


@implementation AYUtitle (FileManager)
+(float)appCacheSize
{
    long long folderSize = 0;
    //数据库大小

    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray<NSURL *> *realmFileURLs = @[
                                        config.fileURL,
                                        [config.fileURL URLByAppendingPathExtension:@"lock"],
                                        [config.fileURL URLByAppendingPathExtension:@"note"],
                                        [config.fileURL URLByAppendingPathExtension:@"management"]
                                        ];
    
    for (NSURL *URL in realmFileURLs) {
        folderSize+=[AYUtitle folderSizeAtPath:[URL absoluteString]];
    }
    //小说内容
    NSString *bookDirPath = [[LESandBoxHelp docPath] stringByAppendingPathComponent:@"AYNovel"];
    folderSize +=[AYUtitle folderSizeAtPath:bookDirPath];
    //图片缓存
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    folderSize +=[AYUtitle folderSizeAtPath:cache.diskCache.path];
    
    
    float sdImageCache = [[SDImageCache sharedImageCache] totalDiskSize]/1000.0f/1000.0f;

    folderSize +=sdImageCache;
    
    return folderSize;

}
+ (float)folderSizeAtPath:(NSString*)folderPath
{
    return  [LEFileManager sizeAtPath:folderPath];
}

+ (void)cleanCache
{
    
    NSURLCache *urlCache =[NSURLCache sharedURLCache];
    [urlCache removeAllCachedResponses];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //清空图片缓存
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
    [cache.diskCache removeAllObjects];
    
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] deleteOldFilesWithCompletionBlock:nil];
    
    [LERMLRealm cleanRealm];
    [ZWCacheHelper deleteAllCatche];
    //删除小说内容缓存
    NSString *bookDirPath = [[LESandBoxHelp docPath] stringByAppendingPathComponent:@"AYNovel"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:bookDirPath error:nil];
}

+ (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath])
    {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
@end
@implementation AYUtitle (Ios11)
+(UIEdgeInsets)al_safeAreaInset:(UIView*)view
{
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}
@end
@implementation AYUtitle (Fiction)
/**
 *  获取小说的渲染内容
 */
+(CGSize)getReadContentSize
{
    if (_ZWIsIPhoneXSeries())
    {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (@available(iOS 11.0, *)) {
            return CGSizeMake(DEFAUT_READ_RENDERSIZE.width, ScreenHeight-STATUS_BAR_HEIGHT-mainWindow.safeAreaInsets.bottom-32);
        }
    }
    else
    {
        return DEFAUT_READ_RENDERSIZE;
    }
    return CGSizeZero;
}
@end

@implementation AYUtitle (Date)

// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
- (NSDate *)getDateWithTimeStr:(NSString *)str
{
    NSTimeInterval time=[str doubleValue]/1000;//传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    return detailDate;
}

@end

@implementation AYUtitle (AttributedString)

//获取NSAttributedString 的高度
+ (CGFloat)getAttributedStringHeight:(NSAttributedString *)aString width:(CGFloat)width attribute:(NSDictionary*)attribute
{
    CGSize strSize = [[aString string] boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:attribute
                                                    context:nil].size;
    
    return ceil(strSize.height);
}
//获取指定size 内能容下多少个字符
+ (NSInteger)strLenthToSize:(CGSize)viewSize  str:(NSString*)contentStr attribute:(NSDictionary*)attribute
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];
    [str addAttributes:attribute range:NSMakeRange(0, contentStr.length)];
    CFAttributedStringRef cfAttStr = (__bridge CFAttributedStringRef)str;
    //直接桥接，引用计数不变
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(cfAttStr);
    int textPos = 0;
    NSUInteger strLength = [str length];
    if(textPos < strLength)
    {
        CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, viewSize.width, viewSize.height), NULL);
        //设置路径
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        //生成frame
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        NSRange range = NSMakeRange(frameRange.location, frameRange.length);
        CFRelease(path);
        CFRelease(framesetter);
        CFRelease(frame);
        return range.length-7;
    }
    CFRelease(framesetter);

    return 0;
}
@end


@implementation AYUtitle (Color)
+ (BOOL)compareRGBAColor1:(UIColor *)color1 withColor2:(UIColor *)color2
{
    CGFloat red1,red2,green1,green2,blue1,blue2,alpha1,alpha2;
    //取出color1的背景颜色的RGBA值
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    //取出color2的背景颜色的RGBA值
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    NSString *red1_str  = [NSString stringWithFormat:@"%.5f",red1];
    NSString *green1_str  = [NSString stringWithFormat:@"%.5f",green1];
    
    NSString *blue1_str  = [NSString stringWithFormat:@"%.5f",blue1];
    NSString *red2_str  = [NSString stringWithFormat:@"%.5f",red2];
    NSString *green2_str  = [NSString stringWithFormat:@"%.5f",green2];
    NSString *blue2_str  = [NSString stringWithFormat:@"%.5f",blue2];
    if (([red1_str isEqualToString:red2_str])&&([green1_str isEqualToString:green2_str])&&([blue1_str isEqualToString:blue2_str]))
    {
        return YES;
    } else {
        return NO;
    }
}
@end

@implementation AYUtitle (AppComment)
//弹出评论界面
+ (void)addAppReview
{
    BOOL hasCommentd = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultUserHasAppCommented];
    NSDate *beforeData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultUserAppCommentedShowTime];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:beforeData];//秒
    if(((time>2*24*3600) && !hasCommentd) || !beforeData)//两天后提示
    {
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:AYLocalizedString(@"喜欢อ่านเลย么? 给个五星好评吧!") message:nil preferredStyle:UIAlertControllerStyleAlert];
        //跳转APPStore 中应用的撰写评价页面
        UIAlertAction *review = [UIAlertAction actionWithTitle:AYLocalizedString(@"喜欢，我要评论") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultUserHasAppCommented];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     
                                     NSURL *appReviewUrl = [NSURL URLWithString:[NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@?action=write-review",@"1440719422"]];
                                     
                                     if (@available(iOS 10.0, *)) {
                                         [[UIApplication sharedApplication] openURL:appReviewUrl options:@{} completionHandler:nil];
                                     }
                                     else
                                     {
                                         [[UIApplication sharedApplication] openURL:appReviewUrl];
                                     }
                                     
                                 }];

        [alertVC addAction:review];

        //判断系统,是否添加五星好评的入口
        if (@available(iOS 10.3, *)) {
            if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
                UIAlertAction *fiveStar = [UIAlertAction actionWithTitle:AYLocalizedString(@"喜欢，五星好评") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultUserHasAppCommented];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    [[UIApplication sharedApplication].keyWindow endEditing:YES];
                    //  五星好评
                    [SKStoreReviewController requestReview];
                    
                }];
                [alertVC addAction:fiveStar];
            }
        } else {
        }
        //去反馈
        UIAlertAction *notLikeReview = [UIAlertAction actionWithTitle:AYLocalizedString(@"不喜欢，我要反馈") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultUserHasAppCommented];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYAdverseViewController parameters:nil];
        }];
        [alertVC addAction:notLikeReview];
        //不做任何操作
        UIAlertAction *noReview = [UIAlertAction actionWithTitle:AYLocalizedString(@"用用再说") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC removeFromParentViewController];
        }];
        [alertVC addAction:noReview];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[[UIApplication sharedApplication]keyWindow] rootViewController] presentViewController:alertVC animated:YES completion:nil];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultUserAppCommentedShowTime];

            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
}
@end

@implementation AYUtitle (Coin)
+ (void)updateUserCoin: (void(^)(void)) completeBlock
{
    AppDelegate *appDel =(AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDel updateUserCoin:completeBlock];
}

@end

