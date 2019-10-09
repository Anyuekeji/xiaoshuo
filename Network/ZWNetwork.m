 //
//  ZWNetwork.m
//  CallU
//
//  Created by 刘云鹏 on 16/3/18.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import "ZWNetwork.h"
#import "ZWDeviceSupport.h"
//#import "OpenUDID.h"
//#import "NSString+NHZW.h"
//#import "ZWUtility.h"
//#import "NSString+Encryption.h"
#import "Constants+Network.h"
#import "NSData+CommonCrypto.h"
//#import "NSString+PJR.h"

#pragma mark - Network For ZW
@implementation ZWNetwork

#pragma mark - Overwrite
/**
 *  DES加密同时加密请求地址
 */
+ (NSURL *) encodeRequestAbsoluteUrl : (NSString *) absoluteUrl {
//    NSString * key = @"用户key";
//    if ( !key ) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_DESKEY_LOST object:nil];
//        AYLog(@">> ERROR 没有加密私钥！");
//        return nil;
//    }
//    //对"api/"后面的地址要进行加密
//    NSRange theRange = [absoluteUrl rangeOfString:@"api/"];
//    NSString *plainText = [absoluteUrl substringFromIndex:theRange.location+theRange.length];
//    NSString *ciphertext = [plainText stringByDESEncryptingWithKey:@"deskey"];
//    NSURL *url = [NSURL URLWithString:[absoluteUrl stringByReplacingOccurrencesOfString:plainText withString:ciphertext]];
////    Debug(@"%@  --- %@", absoluteUrl, url);
//    return url;
    return nil;
}

/**
 *  解析结构
 *
 *  @param responseObject jsonObject
 *  @param completeBlock  成功回调
 *  @param failedBlock    失败回调
 */
+ (void)doAnalysisResponseObject:(id)responseObject completion:(void (^)(id))completeBlock failure:(void (^)(LEServiceError, NSError *))failedBlock {
    if(!responseObject)
    {
        failedBlock(LERequestErrorUnknow, [self errorWithLEServiceErrorType:LERequestErrorUnknow localizedDescriptionValue:AYLocalizedString(@"未知错误")]);
        return;
    }
    if ( [responseObject isKindOfClass:[NSDictionary class]] && responseObject[API_RCODE_KEY])
    {
        if ([responseObject[API_RCODE_KEY] integerValue] == 0 &&
            completeBlock )
        {
                if ( [responseObject objectForKey:@"result"] )
                {
                    completeBlock([responseObject objectForKey:@"result"]);
                }
                else
                {
                    //数据中没有data的情况
                    completeBlock(nil);
                }
        } else if ( responseObject[API_RCODE_KEY] == [NSNull null] && failedBlock ) {
            failedBlock(LEServiceErrorFeachedNone, [self errorWithLEServiceErrorType:LEServiceErrorNotMatchData localizedDescriptionValue:@"空指针异常!"]);
        }
        else if ([responseObject[API_RCODE_KEY] integerValue] == 401 ) {
            AYLog(@"您的账号在其他地方登录http");
            occasionalHint(@"您的账号在其他地方登录");
            if(failedBlock)
            {
                failedBlock(LERequestErrorTokenExpire,[self errorWithLEServiceErrorType:            LERequestErrorTokenExpire
 localizedDescriptionValue:@""]);
            }
        }
        else if ([responseObject[API_RCODE_KEY] integerValue] == TOKEN_EXPIRE_CODE ) {
            //toekn过期
            [ZWREventsManager sendNotCoveredViewControllerEvent:kEventAYLogiinViewController parameters:nil];
            if (completeBlock)
            {
                 completeBlock(nil);
            }
          occasionalHint(responseObject[API_RMES_KEY]);
        }
        else if ([responseObject[API_RCODE_KEY] integerValue] != 0 && failedBlock ) {
            id errorObj= responseObject[API_RMES_KEY];
            if ([errorObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *errodDic = (NSDictionary*)errorObj;
                NSArray *valueArray = [errodDic allValues];
                __block  NSString *errorString = @"";
                if(valueArray.count>0)
                {
                    [valueArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        NSString *transString = [NSString stringWithString:[obj[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        errorString = [errorString stringByAppendingString:transString];
                        errorString= [errorString stringByAppendingString:@","];
                        
                    }];
                    failedBlock(LERequestErrorUnknow, [self errorWithLEServiceErrorType:LERequestErrorUnknow localizedDescriptionValue:errorString]);
                }
                else
                {
                    failedBlock(LERequestErrorUnknow, [self errorWithLEServiceErrorType:LERequestErrorUnknow localizedDescriptionValue:@""]);
                }

            }
            else
              failedBlock(LERequestErrorUnknow, [self errorWithLEServiceErrorType:LERequestErrorUnknow localizedDescriptionValue:responseObject[API_RMES_KEY]]);
        }
    }
    else
    {
          failedBlock(LERequestErrorUnknow, [self errorWithLEServiceErrorType:LERequestErrorUnknow localizedDescriptionValue:@""]);
    }
}

+ (BOOL) isTokenExpiration : (NSString *) code {
    if ( code ) {
        return [code isEqualToString:@"user.kick.out"] || [code isEqualToString:@"user.not.login"] || [code isEqualToString:@"user.error"];
    }
    return NO;
}

+ (BOOL) isUserPickOut : (NSString *) code {
    if ( code ) {
        return [code isEqualToString:@"sf.kick.out"];
    }
    return NO;
}

+ (NSDictionary *) DESCHttpHeaderWithRequestParams : (NSDictionary *) parameters {
    NSMutableDictionary * requestHeader = [NSMutableDictionary dictionary];
    //添加用户id
 //   [requestHeader addValue:([CYUserInfoHelp userId] ? [CYUserInfoHelp userId]: @"")
   //                  forKey:@"uid"];
//    //添加地理位置
//    [requestHeader addValue:([ZWLocationManager longitude] ? [ZWLocationManager longitude] : @"")
//                     forKey:@"lon"];
//    [requestHeader addValue:([ZWLocationManager latitude] ? [ZWLocationManager latitude] : @"")
//                     forKey:@"lat"];
    //IDFA
    [requestHeader addValue:([ZWDeviceSupport idfaString]? [ZWDeviceSupport idfaString] : @"")
                     forKey:@"mc"];
    //设备ID
 //   [requestHeader addValue:[OpenUDID value]
                   //  forKey:@"deviceId"];
    //appKey
   // [requestHeader addValue:@"1000002"
   //                  forKey:@"appkey"];
    //设备名称
    [requestHeader addValue:[ZWDeviceSupport platformString]
                     forKey:@"deviceName"];
    //网络环境
    [requestHeader addValue:[AYUtitle currentReachabilityString]
                     forKey:@"gsm"];
    //客户端｜服务器版本号
    [requestHeader addValue:[ZWDeviceSupport appVersion]
                     forKey:@"c-version"];
    [requestHeader addValue:SERVER_VERSION
                     forKey:@"s-version"];
    //mac地址
    [requestHeader addValue:[[ZWDeviceSupport macAddress] stringByReplacingOccurrencesOfString:@":" withString:@""]
                     forKey:@"ac"];
    //
//    //拼凑参数MD5token
//    NSMutableArray *parameterArray = [[NSMutableArray alloc] initWithCapacity:parameters.count];
//    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        if ( [obj isKindOfClass:[NSNumber class]] ) {
//            [parameterArray addObject:[obj stringValue]];
//        } else if ( [obj isKindOfClass:[NSString class]] ) {
//            [parameterArray addObject:obj];
//        } else {
//            [parameterArray addObject:[NSString stringWithFormat:@"%@", obj]];
//        }
//    }];
//    //排序
//    NSArray *sortedArray = [parameterArray sortedArrayUsingComparator:^NSComparisonResult(NSString *p1, NSString *p2) {
//        return [p1 compare:p2];
//    }];
//    //组合
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
//    NSString *timeIntervalString = [NSString stringWithFormat:@"%.lf", timeInterval*1000];
//    NSString *newString = [NSString stringWithFormat:@"1000002*^df55adyu4$%@%@", timeIntervalString, [sortedArray componentsJoinedByString:@""]];
//    NSString *md5String = [[ZWUtility md5:newString] uppercaseString];
//    NSString *token = [NSString stringWithFormat:@"%@", md5String];
//    //加入头中
//    [requestHeader addValue:timeIntervalString
//                     forKey:@"timestamp"];
//    [requestHeader addValue:token
//                     forKey:@"token"];
    //加密的网络请求头要加入服务器返回的token
//    if ([CYUserInfoHelp isUserLogin]) {
//        //增加授权令牌
//        [requestHeader addValue:[NSString stringWithFormat:@"Bearer %@",[CYUserInfoHelp accessToken]]
//                         forKey:@"Authorization"];
//    }

    return requestHeader;
}

+ (NSDictionary *) httpHeaderWithReqeustParams:(NSDictionary *)parameters {
    AYLog(@"the parameters is %@",parameters);
    NSMutableDictionary * requestHeader = [NSMutableDictionary dictionary];
    //添加用户id
    //[requestHeader addValue:[ZWDeviceSupport bundleIdentifier]
                   //  forKey:@"from_id"];
//    [requestHeader addValue:@"0"
//                     forKey:@"os"];
//    [requestHeader addValue:[ZWDeviceSupport screenSizeStirng]
//                     forKey:@"screen"];
//    [requestHeader addValue:[ZWDeviceSupport carrierName]
//                     forKey:@"operator"];
//    //添加地理位置
//    [requestHeader addValue:([ZWLocationManager longitude] ? [ZWLocationManager longitude] : @"")
//                     forKey:@"longitude"];
//    [requestHeader addValue:([ZWLocationManager latitude] ? [ZWLocationManager latitude] : @"")
//                     forKey:@"latitude"];
//    //IDFA
//    [requestHeader addValue:([ZWDeviceSupport idfaString]? [ZWDeviceSupport idfaString] : @"")
//                     forKey:@"mei"];
    //设备ID
   // [requestHeader addValue:[OpenUDID value]
            //         forKey:@"device"];
////    //appKey
////    [requestHeader addValue:@"1000002"
////                     forKey:@"appkey"];
//    //设备名称
//    [requestHeader addValue:[ZWDeviceSupport platformString]
//                     forKey:@"deviceName"];
//    //网络环境
//    [requestHeader addValue:[AYUtitle currentReachabilityString]
//                     forKey:@"network"];
    
    //mac地址
    //  [requestHeader addValue:[[ZWDeviceSupport macAddress] stringByReplacingOccurrencesOfString:@":" withString:@""]
    // forKey:@"mac"];
    //  NSString *willMd5String = [NSString stringWithFormat:@"%@%@%@",[ZWDeviceSupport idfaString],[ZWDeviceSupport deviceName],[ZWDeviceSupport macAddress]];
    // NSString *headMd5String = [AYUtitle md5:willMd5String];
    //[requestHeader addValue:headMd5String
    //  forKey:@"utma"];
//    //客户端｜服务器版本号
    if ([[LELanguageManager shareInstance] isTilandLanguage]) {
        [requestHeader addValue:@"0b3f34gsrertrd7029dde7c2ba372093" forKey:@"apiKey"];
    }
    else
    {
        [requestHeader addValue:@"2005d96e1b2450ffb8991140105d37c2"
                         forKey:@"apiKey"];
    }

    //组合
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeIntervalString = [NSString stringWithFormat:@"%.lf", timeInterval];
    [requestHeader addValue:[ZWDeviceSupport appVersion]
                     forKey:@"version"];
    [requestHeader addValue:timeIntervalString
                     forKey:@"timestamp"];
    [requestHeader addValue:@"iphone"
                     forKey:@"deviceType"];
    //设备ID
    [requestHeader addValue:[AYUtitle getDeviceUniqueId]
             forKey:@"deviceToken"];
    if ([AYUserManager isUserLogin] && ![parameters.allKeys containsObject:@"token"]) {
        [requestHeader addValue:[AYUserManager userItem].myToken
         forKey:@"token"];
    }
//    //
    //拼凑参数MD5token
    NSMutableArray *parameterArray = [[NSMutableArray alloc] init];
    [parameterArray addObjectsFromArray:parameters.allKeys];
    [parameterArray addObject:@"apiKey"];
    [parameterArray addObject:@"timestamp"];
    [parameterArray addObject:@"deviceType"];
    [parameterArray addObject:@"version"];
    [parameterArray addObject:@"deviceToken"];

    if ([AYUserManager isUserLogin] && ![parameters.allKeys containsObject:@"token"])
    {
        [parameterArray addObject:@"token"];
    }
    //排序
    NSArray *sortedArray = [parameterArray sortedArrayUsingComparator:^NSComparisonResult(NSString *p1, NSString *p2) {
        return [p1 compare:p2];
    }];
    AYLog(@"the sign key is %@",sortedArray);

    __block NSString *apiSignStr =@"";
    [sortedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *valueObj =[parameters objectForKey:obj];
        NSString *value =[valueObj isKindOfClass:NSNumber.class]?[(NSNumber*)valueObj stringValue]:(NSString*)valueObj;
                    if (value) {
                      //apiSignStr = [apiSignStr stringByAppendingString:[value URLEncodedString]];
                      apiSignStr = [apiSignStr stringByAppendingString:value];
                    }
                    else
                    {
                        value = [requestHeader objectForKey:obj];
                       // apiSignStr = [apiSignStr stringByAppendingString:[value URLEncodedString]];
                        apiSignStr = [apiSignStr stringByAppendingString:value];
                    }

    }];
    NSData *willSignData = [apiSignStr dataUsingEncoding:NSUTF8StringEncoding];
    AYLog(@"will sig str is %@",apiSignStr);
    NSString *entst = [AYUtitle hmacStringUsingAlg:kCCHmacAlgMD5 withKey:([[LELanguageManager shareInstance] isTilandLanguage]?@"02sr3c23492d83ed3f5ctrtrtd3133ed":@"3297b5dea6d4c6cad2249b3dc328d92a") str:willSignData];
    AYLog(@"sig result is %@",entst);
   [requestHeader addValue:entst
                     forKey:@"apiSign"];
    return requestHeader;
}



+ (NSData *)encodeRequestWithPostParameters:(NSDictionary *)parameters {
//    if ( parameters ) {
//        NSMutableDictionary * codeParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
//        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            if ( [obj isKindOfClass:[NSNumber class]] ) {
//                [codeParameters setObject:[obj stringValue] forKey:key];
//            }
//        }];
//        Byte iv[] = {1,2,3,4,5,6,7,8};
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:codeParameters options:0 error:nil];
//        NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSString * encodeString = [json encryptedWithDESUsingKey:@"[ZWUserHelper desKey]" andIV:[NSData dataWithBytes:iv length:8]];
//        return [encodeString dataUsingEncoding:NSUTF8StringEncoding];
//    }
    return [[NSData alloc] init];
}

+ (NSDictionary *) createParamsWithConstruct : (void(^)(NSMutableDictionary * params)) constructBlock {
    if ( constructBlock ) {
        NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
        constructBlock(dictionary);
        return dictionary;
    }
    return @{};
}

@end

#pragma mark - Parameters Creation Functions
@implementation NSMutableDictionary (ZWParams)
- (void) addValue : (id) value forKey : (id<NSCopying>) key {
    if ( value && key ) {
        [self setObject:value forKey:key];
    }
}
- (void) addValue : (id) value forKey : (id<NSCopying>) key inCondition : (BOOL) condiction {
    if ( condiction ) {
        [self addValue:value forKey:key];
    }
}

- (void) print {
    Debug(@"%@", self);
}
@end

UIKIT_EXTERN id ZWRequestPair(NSString * urlKey,
                              NSString * method,
                              NSDictionary * params,
                              void(^success)(id record),
                              void(^failure)(LEServiceError type, NSError * error)) {
    return [ZWNetwork requestPairWithURLKey:urlKey requestMethod:method parameters:params success:success failure:failure];
}

UIKIT_EXTERN void ZWQueueRequest(NSArray * (^constructBlock)(void),
                                 void (^completion)(NSError * error)) {
    [ZWNetwork queue:constructBlock completeBlock:completion];
}
