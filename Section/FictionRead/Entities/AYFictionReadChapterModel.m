//
//  AYFictionReadChapterModel.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/1.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYFictionReadChapterModel.h"
#import "NSData+CommonCrypto.h"
#import "LERSAEncyManage.h"
#import "NSString+LEAF.h"
#import "GTMBase64.h"

@implementation AYFictionReadChapterModel
+ (NSDictionary<NSString *,id> *)propertyToKeyPair {
    return @{@"fictionSectionContent" : @"sec_content",@"aesKey" : @"amd5",};
}

-(void)decodeFictionContent
{
    NSString *aesKey= [LERSAEncyManage decryptString:self.aesKey privateKey:RSA_PRIVATE_KEY];
    AYLog(@"the  origiin aesKey is %@ result key :%@",self.aesKey,aesKey);
    NSData *contentData = [GTMBase64 decodeString:_fictionSectionContent];
    NSData *result_contentData = [contentData AES128DecryptWithKey:aesKey iv:@"2019426anyuekeji"];
   NSString *contentString  =[[NSString alloc] initWithData:result_contentData encoding:NSUTF8StringEncoding];
    self.fictionSectionContent = contentString;
    AYLog(@"the decode sectioncontent is %@",contentString);
}
@end
