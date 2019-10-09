//
//  ViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/10/29.
//  Copyright © 2018年 liuyunpeng. All rights reserved.

#import "LEConfigurate.h"

@implementation LEConfigurate

+ (id) configurationWithEnvironment:(LEEnvironmentType)type fileName:(NSString *)fileName {
    return [[self alloc] initWithEnvironment:type fileName:fileName];
}

- (instancetype) initWithEnvironment:(LEEnvironmentType)type fileName:(NSString *)fileName {
    if ( self = [super init] ) {
        _environment = type;
        _fileName = fileName;
        [self setUp];
    }
    return self;
}

- (void) setUp {
    NSString * filePath = [[NSBundle mainBundle] pathForResource:self.fileName ? self.fileName : @"LEAPI" ofType:@"plist"];
    if ( filePath ) {
        _configurateDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        [self initEnvironmentGroupKey];
    } else {
        DPrintf(">>LEConfigurate: File Named %s not found!\n", self.fileName ? self.fileName.UTF8String : [@"LEAPI" UTF8String]);
    }
}

- (void) initEnvironmentGroupKey {
    switch ( _environment ) {
        case LEDistribution:
            _environmentGroupKey = LEDistributionKey;
            break;
        case LEGrayEnvironment:
            _environmentGroupKey = LEGrayEnvironmentKey;
            break;
        case LEDevelopment:
            _environmentGroupKey = LEDevelopmentKey;
            break;
        case LEPersonal:
            _environmentGroupKey = LEPersonalKey;
            break;
        default:
            _environmentGroupKey = LEDistributionKey;
            break;
    }
}

- (NSString *) reachHostName {
    return [_configurateDictionary objectForKey:LEReachHostKey];
}

- (NSString *) baseUrlPrefix {
    return [[_configurateDictionary objectForKey:_environmentGroupKey] objectForKey:LEBaseUrlKey];
}
- (NSString *) imageUrlPrefix {
    return [[_configurateDictionary objectForKey:_environmentGroupKey] objectForKey:([[LELanguageManager shareInstance] isTilandLanguage]?LEImageUrlKey:LEIDImageUrlKey)];
}
- (NSString *) sslUrlPrefix {
    return [[_configurateDictionary objectForKey:_environmentGroupKey] objectForKey:([[LELanguageManager shareInstance] isTilandLanguage]?LESSLUrlKey:LEIDSSLUrlKey)];
}
- (void) setImageUrlPrefix:(NSString*)newUrl
{
    
    NSDictionary *dic = [_configurateDictionary objectForKey:_environmentGroupKey];
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    [mutDic setObject:newUrl forKey:LEImageUrlKey];
    [_configurateDictionary setObject:mutDic forKey:_environmentGroupKey];

}
- (void) setSslUrlPrefix:(NSString*)newUrl
{
    NSDictionary *dic = [_configurateDictionary objectForKey:_environmentGroupKey];
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mutDic setObject:newUrl forKey:LESSLUrlKey];
       [_configurateDictionary setObject:mutDic forKey:_environmentGroupKey];


}
- (void) setBaseUrlPrefix:(NSString*)newUrl
{
   [[_configurateDictionary objectForKey:_environmentGroupKey] setObject:newUrl forKey:LEBaseUrlKey];
}
- (NSString *) descriptionOfApi : (NSString *) apiName {
    if ( apiName ) {
        NSDictionary * dict = [[_configurateDictionary objectForKey:LEApiServiceKey] objectForKey:apiName];
        if ( dict ) {
            return [dict objectForKey:LEAPIDescriptionKey];
        } else {
            DPrintf("ERROR>>LEConfigurate : your apiName can not found!\n");
        }
    } else {
        DPrintf("ERROR>>LEConfigurate : your apiName is nil !\n");
    }
    return nil;
}

- (NSString *) api : (NSString *) apiName {
    if ( apiName ) {
        NSDictionary * dict = [[_configurateDictionary objectForKey:LEApiServiceKey] objectForKey:apiName];
        if ( dict ) {
            return [dict objectForKey:LEAPINameKey];
        } else {
            DPrintf("ERROR>>LEConfigurate : your apiName can not found!\n");
        }
    } else {
        DPrintf("ERROR>>LEConfigurate : your apiName is nil !\n");
    }
    return nil;
}

@end
