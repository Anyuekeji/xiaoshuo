//
//  AYChargeSelectView.m
//  AYNovel
//
//  Created by liuyunpeng on 2018/11/13.
//  Copyright © 2018年 liuyunpeng. All rights reserved.
//

#import "AYChargeSelectView.h"
#import "AYChargeItemModel.h"
#import "IAPManager.h"
#import "UIButton+BottomLine.h" //底部横线
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AYChargeSelectView ()<UICollectionViewDelegate, UICollectionViewDataSource,IApRequestResultsDelegate>
@property (nonatomic, copy) void (^completeBlock)(void);
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray<AYChargeItemModel*> *chargeItemArray;
@property (assign, nonatomic) BOOL buying;

@property (strong, nonatomic) AYChargeItemModel *currentSelectChargeModel;

@end

@implementation AYChargeSelectView

-(instancetype)initWithFrame:(CGRect)frame compete:(void(^)(void)) completeBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        self.completeBlock = completeBlock;
        [self configureUI];
        [self configureData];
    }
    return self;
}
-(void)dealloc
{
    if (!self.buying) {
        [self removeHelpFriendChargeInfo];
    }
    self.buying =NO;
    [IAPManager shared].delegate = nil;
}
-(void)configureUI
{
    [self setBackgroundColor:[UIColor whiteColor]];
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
    [self createCollectionView];
    [self creatChargeGuideView];
    
}
-(void)configureData
{
    [IAPManager shared].delegate = self;
    self.chargeItemArray = [NSMutableArray new];
    [self loadChargeInfo];
    
}
#pragma mark - getter and setter -
//创建相册视频列表collectionView
- (void)createCollectionView {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    
    CGFloat itemWidth = 165/375.0f*ScreenWidth;
    CGFloat itemHeight = 110/165.0f*itemWidth;
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.frame = CGRectMake(0, 0, self.width, self.height-20);
    [self addSubview:self.collectionView];

    [self.collectionView registerClass:[AYChargeSelecCell class] forCellWithReuseIdentifier:@"AYChargeSelecCell"];
}

-(UIButton*)creatChargeGuideView
{
    UIButton *guideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnWidth = LETextWidth(AYLocalizedString(@"点击这里教你买金币"), [UIFont boldSystemFontOfSize:12]);
    guideBtn.frame = CGRectMake((self.width-btnWidth)/2.0f, self.height-24, btnWidth, 24);
    
    
    [guideBtn setTitle:AYLocalizedString(@"点击这里教你买金币") forState:UIControlStateNormal];
    [guideBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [guideBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateHighlighted];
    guideBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [guideBtn setBottomLineStyleWithColor:UIColorFromRGB(0x999999)];
    [guideBtn addAction:^(UIButton *btn) {
        NSString *url  = [NSString stringWithFormat:@"%@home/privacy/icharge",BASE_URL_HTTPS];
             [ZWREventsManager sendViewControllerEvent:kEventAYWebViewController parameters:url animate:YES];
    }];
    [self addSubview:guideBtn];
    return guideBtn;
}
#pragma mark - db -

#pragma mark - network -
-(void)loadChargeInfo
{
    //先读缓存
    NSArray* catcheArray =  [AYChargeItemModel r_allObjects];
    if (catcheArray && catcheArray.count>0) {
        [self.chargeItemArray removeAllObjects];
        [self.chargeItemArray safe_addObjectsFromArray:catcheArray];
        [self.collectionView reloadData];
    }
    else
    {
         [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    NSDictionary *para = [ZWNetwork createParamsWithConstruct:^(NSMutableDictionary *params) {
        
        id obj =[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFriendChargeId];
        if (obj)
        {
            [params addValue:obj forKey:@"agent_id"];

        }
    }];
    [ZWNetwork post:@"HTTP_Post_Charge_Item" parameters:para success:^(id record)
     {
         if (record && [record isKindOfClass:NSArray.class])
         {
             [MBProgressHUD hideHUDForView:self animated:YES];
             NSArray *itemArray = [AYChargeItemModel itemsWithArray:record];
             if (itemArray.count>0) {
                 [self.chargeItemArray removeAllObjects];
                 [self.chargeItemArray safe_addObjectsFromArray:itemArray];
                 [AYChargeItemModel r_deleteAll];
                 [AYChargeItemModel r_saveOrUpdates:self.chargeItemArray];
                 [self.collectionView reloadData];
                 if (self.buying) {
                     [MBProgressHUD showHUDAddedTo:self animated:YES];

                 }
             }
         }
         
     } failure:^(LEServiceError type, NSError *error) {
         occasionalHint([error localizedDescription]);
         [MBProgressHUD hideHUDForView:self animated:YES];
     }];
}
#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.chargeItemArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    AYChargeSelecCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AYChargeSelecCell" forIndexPath:indexPath];
    AYChargeItemModel *item = [self.chargeItemArray safe_objectAtIndex:indexPath.row];
    [cell filCellWithModel:item];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AYChargeItemModel *item = [self.chargeItemArray safe_objectAtIndex:indexPath.row];
    self.buying = YES;
    self.currentSelectChargeModel = item;
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    [[IAPManager shared] requestProductWithId:item.purProduceId];
}

#pragma mark - IApRequestResultsDelegate-
//支付失败
- (void)filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error {
    self.buying =NO;
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *errorString;
        switch (errorCode) {
            case IAP_FILEDCOED_APPLECODE:
                errorString = error;
                break;
            case IAP_FILEDCOED_NORIGHT:
                NSLog(@"用户禁止应用内付费购买");
                errorString = [NSString stringWithFormat:@"用户禁止应用内付费购买"];
                break;
            case IAP_FILEDCOED_EMPTYGOODS:
                NSLog(@"商品为空");
                errorString =@"商品为空";
                break;
            case IAP_FILEDCOED_CANNOTGETINFORMATION:
                NSLog(@"无法获取产品信息，请重试");
                errorString =@"无法获取产品信息，请重试";
                break;
            case IAP_FILEDCOED_BUYFILED:
                NSLog(@"购买失败，请重试");
                errorString =@"购买失败，请重试";
                break;
            case IAP_FILEDCOED_USERCANCEL:
                NSLog(@"用户取消交易");
               // errorString =@"用户取消交易";
                return ;
                break;
            case IAP_FILEDCOED_SERVERCHEKFAILD:
                NSLog(@"凭证验证失败");
                errorString =@"凭证验证失败";
                return ;
                break;
            default:
                break;
        }
        // 1.创建UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AYLocalizedString(@"支付错误")
                                                                                 message:AYLocalizedString(errorString)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:AYLocalizedString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"OK Action");
        }];
        
        [alertController addAction:okAction];
        [[self parentViewController] presentViewController:alertController animated:YES completion:nil];
    });
    
}
//支付成功
- (void)paySuccess:(NSString*)payId
{
    
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:self.currentSelectChargeModel.purProduceId,@"chargeId",[AYUserManager userId],@"userId",payId,@"payId", nil];
    [FBSDKAppEvents logPurchase:[self.currentSelectChargeModel.chargeMoney doubleValue]
                       currency:@"IDR"
                     parameters: para];
    self.buying =NO;
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    if (self.completeBlock) {
        self.completeBlock();
    }
}
#pragma mark - private -
-(UIViewController*)parentViewController
{
    UIResponder *nextRes = self.nextResponder;
    while (nextRes) {
        if([nextRes isKindOfClass:UIViewController.class])
        {
            return (UIViewController*)nextRes;
        }
        nextRes = nextRes.nextResponder;
    }
    return nil;
}
-(void)removeHelpFriendChargeInfo
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultFriendChargeId]) {
        //清除帮好友充值id 标记
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultFriendChargeId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end

@interface AYChargeSelecCell()
@property (nonatomic, strong) UILabel *coinNumLable; //书名
@property (nonatomic, strong) UILabel *moneyLable; //书架阅读状态
@property (nonatomic, strong) UILabel *flagLable; //超级实惠lable
@property (nonatomic, strong) UILabel *activeLable; //活动label

@end

@implementation AYChargeSelecCell

- (instancetype) initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self configureUI];
    }
    return self;
}
-(void)configureUI
{
    [self.contentView setBackgroundColor:[UIColor whiteColor]];

    UIImageView *coinImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-25)/2.0f, (self.height-60)/2.0f, 25, 25)];
    coinImageView.image = LEImage(@"wujiaoxin_select");
    [self.contentView addSubview:coinImageView];
    
    _coinNumLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:15] textColor:UIColorFromRGB(0x333333) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    _coinNumLable.textAlignment = NSTextAlignmentCenter;
    _coinNumLable.frame = CGRectMake(2, coinImageView.top+coinImageView.height+10, self.width-4, 11);
    [self.contentView addSubview:_coinNumLable];
    
    _moneyLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:13] textColor:RGB(153, 153, 153) textAlignment:NSTextAlignmentLeft numberOfLines:1];
    _moneyLable.textAlignment = NSTextAlignmentCenter;
    _moneyLable.frame = CGRectMake(2, _coinNumLable.top+_coinNumLable.height+3, self.width-4, 11);
    [self.contentView addSubview:_moneyLable];
    _moneyLable.text = @"₫20,000";
    _flagLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:13] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentRight numberOfLines:1];
    _flagLable.backgroundColor = RGB(69, 197, 20);
    _flagLable.text = AYLocalizedString(@"超级实惠");
    _flagLable.layer.cornerRadius = 3.0f;
    _flagLable.clipsToBounds = YES;
    CGFloat textWidth = LETextWidth(_flagLable.text, _flagLable.font);
    _flagLable.frame = CGRectMake(self.width-textWidth-4, 2, textWidth+2, 13);
    
    _activeLable = [UILabel lableWithTextFont:[UIFont systemFontOfSize:13] textColor:RGB(255, 255, 255) textAlignment:NSTextAlignmentCenter numberOfLines:1];
    _activeLable.frame = CGRectMake((self.width-100)/2.0f, _moneyLable.top+_moneyLable.height+5, 100, 14);
    [self.contentView addSubview:_activeLable];
    _activeLable.backgroundColor = RGB(255, 0, 0);
    _activeLable.layer.cornerRadius = 3.0f;
    _activeLable.clipsToBounds = YES;

}
-(void)setCoinNumValue:(NSString*)coinValue  give:(NSString*)giveValue
{
    NSString *coinAllValue = [NSString stringWithFormat:@"%@+%@",coinValue,giveValue];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:coinAllValue];
    
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, coinAllValue.length)];
    
    [attributed addAttribute:NSForegroundColorAttributeName value:RGB(250, 85, 108) range:NSMakeRange(coinValue.length+1, giveValue.length)];
    _coinNumLable.attributedText = attributed;
}
/**填充数据*/
-(void)filCellWithModel:(id)model
{
    if ([model isKindOfClass:AYChargeItemModel.class])
    {
        AYChargeItemModel *item = model;

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle =NSNumberFormatterDecimalStyle;
        NSString *chargeMoney = [formatter stringFromNumber:@([item.chargeMoney integerValue])];
        _moneyLable.text = [NSString stringWithFormat:@"%@%@",@"Rp",chargeMoney];
        if([item.invite boolValue])
        {
            self.contentView.backgroundColor = RGB(255, 232, 234);
            [self.contentView addSubview:_flagLable];
        }
        else
        {
            self.contentView.backgroundColor = RGB(255, 255, 255);

            if ([self.contentView.subviews containsObject:_flagLable]) {
                [_flagLable removeFromSuperview];
            }
        }
        if(![item.isfirst boolValue])
        {
            [self setCoinNumValue:[item.chargeCoin stringValue] give:[item.chargeGiveCoin stringValue]];
        }
        else
        {
            _coinNumLable.text =[item.chargeCoin stringValue];
        }
        if (item.intro && item.intro.length>0) {
            _activeLable.hidden =NO;
            _activeLable.text = item.intro;
        }
        else
        {
            _activeLable.hidden = YES;
        }

    }
}

@end


@implementation AYChargeSelectContainView
-(void)dealloc
{


}
-(instancetype)initWithFrame:(CGRect)frame compete:(void(^)(void)) completeBlock
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        AYChargeSelectView *chargeSelectView = [[AYChargeSelectView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height-73) compete:completeBlock];
        [self addSubview:chargeSelectView];
        
        UIImageView *deleteSignView = [[UIImageView alloc] initWithImage:LEImage(@"delete")];
        deleteSignView.frame = CGRectMake((self.frame.size.width-31)/2,chargeSelectView.frame.origin.y+chargeSelectView.bounds.size.height, 31, 73);
        [self addSubview:deleteSignView];
        [deleteSignView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
            UIView *maskView = [ges.view.superview.superview viewWithTag:78656];
            [UIView animateWithDuration:0.2f animations:^{
                ges.view.superview.alpha =0.1;
                maskView.alpha = 0.1f;
                ges.view.superview.transform = CGAffineTransformMakeScale(0, 0);
                ges.view.superview.center = CGPointMake(ScreenWidth, ges.view.superview.frame.origin.y+ges.view.superview.bounds.size.height);
            }
                             completion:^(BOOL finished)
             {
                 if (finished)
                 {
                     [AYUtitle enableReadViewPangestrue:YES];
                     [maskView removeFromSuperview];
                     [ges.view.superview removeFromSuperview];
                 }
             }];
        }];
    }
    return self;
}
+(void)showChargeSelectInView:(UIView*)parentView compete:(void(^)(void)) completeBlock
{
    UIView *maskView = [[UIView alloc] initWithFrame:parentView.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [parentView addSubview:maskView];
    maskView.tag = 78656;
    
    CGFloat itemWidth = 165/375.0f*ScreenWidth;
    CGFloat itemHeight = 110/165.0f*itemWidth;
    
    AYChargeSelectContainView *containView = [[AYChargeSelectContainView alloc] initWithFrame:CGRectMake((ScreenWidth-2*itemWidth)/2.0f, (ScreenHeight-3*itemHeight-73-44-26)/2.0f, 2*itemWidth, 3*itemHeight+73+26) compete:^{
        //只有在阅读小说的时候才响应，充值完可以让翻页
        [AYUtitle enableReadViewPangestrue:YES];

        [[parentView viewWithTag:13435] removeFromSuperview];
        [maskView removeFromSuperview];
        if (completeBlock) {
            completeBlock();
        }
    }];
    [parentView addSubview:containView];
    containView.alpha =0.3f;
    containView.tag = 13435;
    containView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView animateWithDuration:0.5f animations:^{
        containView.alpha =1;
        maskView.alpha = 0.5f;
        containView.transform = CGAffineTransformMakeScale(1, 1);
    }];
    LEWeakSelf(maskView)
    LEWeakSelf(containView)
    [maskView addTapGesutureRecognizer:^(UITapGestureRecognizer *ges) {
        LEStrongSelf(maskView)
        LEStrongSelf(containView)
        [UIView animateWithDuration:0.2f animations:^{

            containView.alpha =0.1;
            maskView.alpha = 0.1f;
            containView.transform = CGAffineTransformMakeScale(0, 0);
            containView.center = CGPointMake(ScreenWidth, containView.frame.origin.y+containView.bounds.size.height);
        }
        completion:^(BOOL finished)
        {
            if (finished)
            {
                //只有在阅读小说的时候才响应，充值完可以让翻页
                [AYUtitle enableReadViewPangestrue:YES];

                [ges.view removeFromSuperview];
                [containView removeFromSuperview];
            }
        }];
    }];
}
@end
