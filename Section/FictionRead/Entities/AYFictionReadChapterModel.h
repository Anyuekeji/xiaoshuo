//
//  AYFictionReadChapterModel.h
//  AYNovel
//
//  Created by liuyunpeng on 2018/12/1.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "CYFictionChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYFictionReadChapterModel : CYFictionChapterModel
@property(nonatomic,strong) NSString *fictionSectionContent;//经过aes加密过小说章节内容
@property(nonatomic,strong) NSString *aesKey;//rsa加密过的aeskey

//解密章节内容
-(void)decodeFictionContent;
@end

NS_ASSUME_NONNULL_END
