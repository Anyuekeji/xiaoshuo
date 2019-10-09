//
//  AYGuideManager.m
//  AYNovel
//
//  Created by liuyunpeng on 2019/3/28.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "AYGuideManager.h"

@interface AYGuideManager()
@property(nonatomic,strong)CAShapeLayer *fillLayer;
@property(nonatomic,strong)NSMutableArray *viewSubGuideArray; //某个界面所有的引导类型
@property(nonatomic,strong)UIImageView *guideImageView;
@property(nonatomic,assign)NSInteger guideIndex;
@property(nonatomic,strong)UIImageView *knowImageView;

@end

@implementation AYGuideManager
-(instancetype)init
{
    self = [super init];
    if (self) {
        [self configureLayer];
    }
    return self;
}

-(void)configureLayer
{
    _guideIndex =0;
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.7;
    [[AYUtitle getAppDelegate].window.layer addSublayer:fillLayer];
    _fillLayer = fillLayer;
}

-(void)createGuideViewWithType:(AYGuideType)guideType
{
    if (_guideImageView) {
        [UIView animateWithDuration:0.1f animations:^{
            self.guideImageView.alpha=0;
        } completion:^(BOOL finished) {
            [self.guideImageView removeFromSuperview];
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_guideImageView?0.3f:0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[UIScreen mainScreen].bounds cornerRadius:0];
        switch (guideType) {
            case AYGuideTypeClassificationZone:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-20, Height_TopBar-10, ScreenWidth+40, 60)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_fenlei");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-zoneImage.size.width)/2+20, Height_TopBar+63, zoneImage.size.width, zoneImage.size.height)];
                self.guideImageView.image = zoneImage;
                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
            }
                break;
            case AYGuideTypeFreeZone:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((ScreenWidth-90)/2.0f-2, Height_TopBar-4, 90, 45)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_free");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*39.0f/374.0f, Height_TopBar+60, zoneImage.size.width, zoneImage.size.height)];
                self.guideImageView.image = zoneImage;
                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
            }
                break;
            case AYGuideTypeRecommendFiction:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, Height_TopBar+70, ScreenWidth, CELL_HORZON_BOOK_IMAGE_HEIGHT+30)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_fiction_rec");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*37.0f/374.0f, Height_TopBar+CELL_HORZON_BOOK_IMAGE_HEIGHT+70+30, zoneImage.size.width, zoneImage.size.height)];
                self.guideImageView.image = zoneImage;
                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
            }
                break;
            case AYGuideTypeTask:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(ScreenWidth*2/4+(ScreenWidth/4-100)/2.0f, ScreenHeight-Height_TapBar, 100,50)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_bottom_task");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-zoneImage.size.width)/2.0f-40, ScreenHeight-Height_TapBar-20-zoneImage.size.height, zoneImage.size.width, zoneImage.size.height)];
                self.guideImageView.image = zoneImage;

                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
                
                UIImage *knowImage =LEImage(@"guide_know");
                
                UIImageView *knowImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-knowImage.size.width)/2.0f, self.guideImageView.top -knowImage.size.height-50, knowImage.size.width, knowImage.size.height)];
                knowImageView.image = knowImage;
                self.knowImageView = knowImageView;
                [[AYUtitle getAppDelegate].window addSubview:knowImageView];
                
            }
                break;
            case AYGuideTypeSign:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((ScreenWidth-90)/2.0f, Height_TopBar+1, 90,90)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_sign");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-zoneImage.size.width)/2.0f-40, Height_TopBar+90+20, zoneImage.size.width, zoneImage.size.height)];
                self.guideImageView.image = zoneImage;

                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
            }
                break;
            case AYGuideTypeDoTask:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(ScreenWidth-20-82-4, Height_TopBar+244+23+(85.0f/375.0f)*ScreenWidth, 90,45)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_dotask");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*68/375.0f,  Height_TopBar+244+40+(85.0f/375.0f)*ScreenWidth+30, zoneImage.size.width, zoneImage.size.height)];
                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
                self.guideImageView.image = zoneImage;

            }
                break;
            case AYGuideTypeChargeGuide:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-20, Height_TopBar+CELL_BOOK_IMAGE_HEIGHT+30+100+80+20.0f+60, ScreenWidth+40,40)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_charge");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-zoneImage.size.width)/2.0f-30, Height_TopBar+CELL_BOOK_IMAGE_HEIGHT+30+100+80-zoneImage.size.height+50, zoneImage.size.width, zoneImage.size.height)];
                self.guideImageView.image = zoneImage;
                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
            }
                break;
            case AYGuideTypeShare:
            {
                //镂空
                UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(ScreenWidth-15-35, STATUS_BAR_HEIGHT+(44-40)/2.0f,40,40)];
                [path appendPath:circlePath];
                UIImage *zoneImage = LEImage(@"guide_share");
                self.guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*135/375.0f, Height_TopBar-5, zoneImage.size.width, zoneImage.size.height)];
                [[AYUtitle getAppDelegate].window addSubview:self.guideImageView];
                self.guideImageView.image = zoneImage;
            }
                break;
            default:
                break;
        }
        self.fillLayer.path = path.CGPath;
    });
}
-(void)showGuideWithViewType:(AYGuideViewType) viewType
{
    switch (viewType)
    {
        case AYGuideViewTypeFiction:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFictionGuideFinished]) {
                return;
            }
            _viewSubGuideArray  = [NSMutableArray arrayWithObjects:@(AYGuideTypeClassificationZone),@(AYGuideTypeFreeZone),@(AYGuideTypeRecommendFiction),@(AYGuideTypeTask), nil];
        }
            break;
        case AYGuideViewTypeTask:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultTaskGuideFinished]) {
                return;
            }
            _viewSubGuideArray  = [NSMutableArray arrayWithObjects:@(AYGuideTypeSign),@(AYGuideTypeDoTask), nil];
        }
            break;
        case AYGuideViewTypeFictionDetail:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFictionDetailGuideFinished]) {
                return;
            }
            _viewSubGuideArray  = [NSMutableArray arrayWithObjects:@(AYGuideTypeChargeGuide),@(AYGuideTypeShare), nil];
        }
            break;
        default:
            break;
    }
    [self createGuideViewWithType:[self.viewSubGuideArray[0] integerValue]];
    LEWeakSelf(self)
    [[AYUtitle getAppDelegate].window addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(self)
        self.guideIndex+=1;
        if (self.guideIndex>=self.viewSubGuideArray.count) {
            [self finishGuide:viewType];
            return ;
        }
        [self createGuideViewWithType:[self.viewSubGuideArray[self.guideIndex] integerValue]];

    }];
}

-(void)setGuideFinishWith:(AYGuideViewType)viewType
{
    if (viewType ==AYGuideViewTypeFiction) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultFictionGuideFinished];
    }
    else if (viewType ==AYGuideViewTypeTask) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultTaskGuideFinished];
    }
    else if (viewType ==AYGuideViewTypeFictionDetail) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultFictionDetailGuideFinished];
    }
}
-(void)finishGuide:(AYGuideViewType)viewType
{
    if (_guideFinish) {
        self.guideFinish();
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.fillLayer removeFromSuperlayer];
        if (self.knowImageView) {
            [self.knowImageView removeFromSuperview];
        }
        self.guideImageView.alpha =0;
        self.guideIndex =0;
        [self setGuideFinishWith:viewType];
        [[AYUtitle getAppDelegate].window.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UITapGestureRecognizer.class]) {
                [[AYUtitle getAppDelegate].window removeGestureRecognizer:obj];
            }
        }];
    } completion:^(BOOL finished) {
        [self.guideImageView removeFromSuperview];
    }];
}
+(BOOL)guideFinishWithViewType:(AYGuideViewType)viewType
{
    if (viewType ==AYGuideViewTypeFiction) {
        return  [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFictionGuideFinished];
    }
    else if (viewType ==AYGuideViewTypeTask) {
        return  [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultTaskGuideFinished];
    }
    else if (viewType ==AYGuideViewTypeFictionDetail) {
        return  [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultFictionDetailGuideFinished];
    }
    return NO;
}
@end
