//
//  AYCartoonDetailSegmengViewController.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/14.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYCartoonDetailSegmengViewController.h"
#import "AYCartoonDetailViewController.h" //漫画详情页
#import "AYCartoonSelectViewController.h"//漫画章节页
#import "LESegment.h"
#import <NSString+YYAdd.h>
#import "AYCartoonModel.h"

@interface AYChannelItem : NSObject
/**
 频道ID
 */
@property (nonatomic, strong) NSNumber * channelId;
/**
 频道名称
 */
@property (nonatomic, strong) NSString * channelName;

/**
 频道icon
 */
@property (nonatomic, strong) NSString * channelIcon;
@end

@implementation AYChannelItem

@end

@interface AYCartoonDetailSegmengViewController ()
@property (nonatomic,strong)NSMutableArray<AYChannelItem*> *channellist;
@property (nonatomic, strong) AYCartoonModel * cartoonModel; //数据源

@end

@implementation AYCartoonDetailSegmengViewController
-(instancetype)initWithPara:(id)para
{
    self = [super init];
    if (self) {
        self.cartoonModel = para;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUi];
    [self configurateData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)configureUi
{
    self.segmentControl.bottomLineColor = RGB(250, 85, 108);
    CGFloat detailfontWidth =  LETextWidth(AYLocalizedString(@"详情"), [UIFont systemFontOfSize:14]);
    CGFloat selectfontWidth =  LETextWidth(AYLocalizedString(@"选集"), [UIFont systemFontOfSize:14]);
    
    CGFloat originx = (ScreenWidth - detailfontWidth - selectfontWidth)/4.0f;
    self.segmentControl.itemOrginX = originx;
    self.segmentControl.horizontalGap =originx;
    self.segmentControl.selectedColor = RGB(51, 51, 51);
    self.segmentControl.normalColor = RGB(102, 102, 102);
}
- (void) configurateData
{
    _channellist = [NSMutableArray new];
    NSArray<NSString*> *titieArray  = [NSArray arrayWithObjects:AYLocalizedString(@"详情"),AYLocalizedString(@"选集"), nil];
    NSInteger sum = titieArray.count;
    for (int i=0 ;i < sum;i++ ) {
        AYChannelItem *item = [[AYChannelItem alloc] init];
        item.channelId = @(i);
        item.channelName = titieArray[i];
        [_channellist addObject:item];
    }
    [self analysisRecord:_channellist];

}

- (void) analysisRecord : (NSArray *) record {
    
    if (record.count>0)
    {
        NSMutableArray<ZWR2SegmentItem *> * segs = [NSMutableArray array];
        //添加其他频道页面
        [record enumerateObjectsUsingBlock:^(AYChannelItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx ==0) {
                [segs addObject:[ZWR2SegmentItem segmentItemWithIdentifier:obj.channelId
                                                                     title:obj.channelName
                                                    forViewControllerClass:AYCartoonDetailViewController.class
                                                              registerItem:self.cartoonModel]];
            }
            else if (idx ==1)
            {
                [segs addObject:[ZWR2SegmentItem segmentItemWithIdentifier:obj.channelId
                                                                     title:obj.channelName
                                                    forViewControllerClass:AYCartoonSelectViewController.class
                                                              registerItem:self.cartoonModel]];
            }
           
        }];
        //实施页面内容
        [self setSegments:segs];
        //
    }
}

#pragma mark - ZWRChainReactionProtocol
/**
 *  当前选中状态又重新选择了这个tabbar，会向当前所在控制器发送本请求事件
 */
- (void) zwrChainReactionEventTabBarDidReClickAfterAppear {
    UIViewController * viewController = self.currentSelectedViewController;
    if ( viewController && [viewController conformsToProtocol:@protocol(ZWRChainReactionProtocol)] ) {
        UIViewController<ZWRChainReactionProtocol> * zwrcrpViewController = (UIViewController<ZWRChainReactionProtocol> *)viewController;
        if ( [zwrcrpViewController respondsToSelector:@selector(zwrChainReactionEventTabBarDidReClickAfterAppear)] ) {
            [zwrcrpViewController zwrChainReactionEventTabBarDidReClickAfterAppear];
        }
    }
}

@end
