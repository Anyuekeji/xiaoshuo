//
//  ViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LEEnvironmentType) {
    LEDistribution      =   0,
    LEGrayEnvironment   =   1,
    LEDevelopment       =   2,
    LEPersonal          =   3,
};

static NSString * const LEDistributionKey       = @"LEDistributionKey";
static NSString * const LEGrayEnvironmentKey    = @"LEGrayEnvironmentKey";
static NSString * const LEDevelopmentKey        = @"LEDevelopmentKey";
static NSString * const LEPersonalKey           = @"LEPersonalKey";

static NSString * const LEReachHostKey          = @"LEReachHostName";
static NSString * const LEApiServiceKey         = @"LEAPI_Service";

static NSString * const LEBaseUrlKey            = @"LEBaseUrlKey";
static NSString * const LESSLUrlKey             = @"LESSLUrlKey";
static NSString * const LEIDSSLUrlKey             = @"LEIDSSLUrlKey";

static NSString * const LEImageUrlKey           = @"LEImageUrlKey";
static NSString * const LEIDImageUrlKey           = @"LEIDImageUrlKey";

static NSString * const LEAPINameKey            = @"api";
static NSString * const LEAPIDescriptionKey     = @"desc";

@interface LEConfigurate : NSObject

@property (nonatomic, readonly, assign) LEEnvironmentType environment;
@property (nonatomic, readonly, strong) NSString * fileName;
@property (nonatomic, readonly, strong) NSString * environmentGroupKey;
@property (nonatomic, strong) NSMutableDictionary * configurateDictionary;

+ (id) configurationWithEnvironment : (LEEnvironmentType) type fileName : (NSString *) fileName;

- (NSString *) reachHostName;
- (NSString *) baseUrlPrefix;
- (NSString *) sslUrlPrefix;
- (NSString *) imageUrlPrefix;
- (void) setImageUrlPrefix:(NSString*)newUrl;
- (void) setSslUrlPrefix:(NSString*)newUrl;
- (void) setBaseUrlPrefix:(NSString*)newUrl;

- (NSString *) descriptionOfApi : (NSString *) apiName;
- (NSString *) api : (NSString *) apiName;
@end
