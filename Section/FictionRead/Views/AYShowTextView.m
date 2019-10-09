//
//  AYShowTextView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/12.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYShowTextView.h"
#import <CoreText/CoreText.h>

@implementation AYShowTextView
- (void)drawRect:(CGRect)rect
{
    if (!self.string) {
        return;
    }
    [super drawRect:rect];
    // 步骤 1 得到当前绘制画布的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 步骤 2 将坐标系翻转，因为底层的绘制引擎屏幕的（0.0）坐标是左下角，UIkit是左上角
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 步骤 3
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // 步骤 4
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self.string];
    [attString addAttributes:[self coreTextAttributes] range:NSMakeRange(0, attString.length)];
    
    [attString addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, [attString length])];

    //得到富文本
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    //生成CTFrameRef 实例
    CTFrameRef frame =
    CTFramesetterCreateFrame(framesetter,
                             CFRangeMake(0, [self.string length]), path, NULL);
    // 步骤 5 绘制
    CTFrameDraw(frame, context);
    // 步骤 6
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

- (NSDictionary *)coreTextAttributes {
    UIFont *font_ = [UIFont systemFontOfSize:self.font];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = font_.pointSize / 4;
  //  paragraphStyle.firstLineHeadIndent = font_.pointSize*2;
    //paragraphStyle.paragraphSpacing = font_.pointSize;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    NSDictionary *dic = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font_,NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
    return dic;
}


@end
