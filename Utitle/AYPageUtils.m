//
//  AYPageUtils.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYPageUtils.h"
#import <CoreText/CoreText.h>

@implementation AYPageUtils
{
    NSMutableArray *array;
}

- (instancetype)init
{
    if (self = [super init]) {
        array = [NSMutableArray array];
    }
    return self;
}
- (void)paging
{
    if (!_contentText) {
        return;
    }
    [array removeAllObjects];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:_contentText];
    //    //设置字体间距
    //    long number = 0.4f;
    //    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
    //    [str addAttribute:(id)kCTKernAttributeName value:(id)CFBridgingRelease(num) range:NSMakeRange(0, [str length])];
    [str addAttributes:[self attributesWithFont:_contentFont] range:NSMakeRange(0, str.length)];
    
    CFAttributedStringRef cfAttStr = (__bridge CFAttributedStringRef)str;
    //直接桥接，引用计数不变
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(cfAttStr);
    int textPos = 0;
    NSInteger totalPage = 0;
    NSUInteger strLength = [str length];
    while (textPos < strLength)
    {
        CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, _textRenderSize.width, _textRenderSize.height), NULL);
        //设置路径
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        //生成frame
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        NSRange range = NSMakeRange(frameRange.location, frameRange.length);
        [array addObject:NSStringFromRange(range)];
        //获取范围并转换为NSRange，然后以NSString形式保存
        textPos += frameRange.length;
        //移动当前文本位置
        CFRelease(frame);
        CGPathRelease(path);
        totalPage++;        //释放路径和frame，页数加1
        
    }
    CFRelease(framesetter);
}
- (NSUInteger)pageCount {
    return array.count-1;
}
- (NSString *)stringOfPage:(NSUInteger)page {
    if (array.count>0) {
        if (page > array.count-1) {
            return @"";
        }
        NSRange range = NSRangeFromString(array[page]);
        return [_contentText substringWithRange:range];
    }
    return nil;
}
- (NSInteger)locationWithPage:(NSInteger)page {
    NSRange range = NSRangeFromString(array[page]);
    return range.location;
}
- (NSInteger)pageWithTextOffSet:(NSInteger)OffSet {
    for (NSInteger idx = 0; idx < array.count; idx++) {
        NSRange range = NSRangeFromString(array[idx]);
        if (range.location <= OffSet && range.location + range.length > OffSet) {
            return idx;
        }
    }
    return 0;
}
- (NSDictionary *)attributesWithFont:(NSInteger)fontsize
{
    UIFont *font = [UIFont systemFontOfSize:[AYUtitle getReadFontSize]];
    self.contentFont = font.pointSize;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // paragraphStyle.firstLineHeadIndent = 10;
    paragraphStyle.lineSpacing = font.pointSize / 4;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    //  paragraphStyle.firstLineHeadIndent = fontsize*2;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font, NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
}

@end
