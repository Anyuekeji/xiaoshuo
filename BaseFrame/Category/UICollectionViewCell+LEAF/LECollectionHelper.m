//
//  LECollectionHelper.m
//  CallU
//
//  Created by liuyunpeng on 16/4/12.
//  Copyright © 2016年 liuyunpeng. All rights reserved.
//

#import "LECollectionHelper.h"
#import "NSArray+LEAF.h"

#import <objc/runtime.h>               


@interface LECollectionAssosiateItem : NSObject

@property (nonatomic, strong) UICollectionViewCell<LECollectionHelperProtocol> * cell;
@property (nonatomic, strong) NSMutableArray<NSString *> * assosiateSelectors;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSValue *> * cacheDictionary;

@end

@implementation LECollectionAssosiateItem

+ (LECollectionAssosiateItem *) itemWithCell : (UICollectionViewCell<LECollectionHelperProtocol> *) cell {
    LECollectionAssosiateItem * item = [[LECollectionAssosiateItem alloc] init];
    item.cell = cell;
    return item;
}

+ (LECollectionAssosiateItem *) item {
    return [[self alloc] init];
}

- (instancetype) init {
    if ( self = [super init] ) {
        self.assosiateSelectors = [NSMutableArray array];
        self.cacheDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (void) appendCacheValue : (CGSize) size forKey : (NSString *) key {
    if ( self.cacheDictionary.count == 10 ) {
        [self.cacheDictionary removeObjectForKey:[[self.cacheDictionary allKeys] firstObject]];
    }
    if ( key ) {
        NSValue * value = [NSValue valueWithCGSize:size];
        [self.cacheDictionary setObject:value forKey:key];
    }
}

- (void) addAssosiateSelectors : (NSArray<NSString *> *) selectors {
    NSArray * arrayToAdd = [selectors select:^BOOL(NSString * object) {
        return ![self.assosiateSelectors containsObject:object];
    }];
    [self.assosiateSelectors addObjectsFromArray:arrayToAdd];
}

- (CGSize) applySizeForThoseObjects : (NSArray *) objects {
    //开始新的植入
    __weak id target = self.cell;
    Class cellClass = [target class];
    if ( target == nil ) {
        Debug(@">>LEAF : Unset CELL ! You may lost register? or configuration! Now returned ZERO.");
        return CGSizeZero;
    } else if ( [cellClass respondsToSelector:@selector(cellSize)] ) {
        return [cellClass cellSize];
    }
    
    //制作key
    __block long tNumber = 0;
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        char * addressStr = (char *)[[NSString stringWithFormat:@"%p", obj] UTF8String];
        char * endPtr;
        long lnumber = strtol(addressStr, &endPtr, 16);
        tNumber += lnumber;
    }];
    NSString * objectKey = nil;
    if ( tNumber != 0 ) {
        objectKey = [NSString stringWithFormat:@"%lx", tNumber];
    }
    //查询缓存
    NSValue * cacheSizeValue = [self.cacheDictionary objectForKey:objectKey];
    if ( cacheSizeValue ) {
        return [cacheSizeValue CGSizeValue];
    }
    //第一步，参数个数校验和参数分组
    NSUInteger countOfObjects = [objects count];
    __block BOOL checkResult = YES;
    __block int beginIndex = 0;
    [self.assosiateSelectors enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector = NSSelectorFromString(obj);
        Method method = class_getInstanceMethod(cellClass, selector);
        int numberOfArguments = method_getNumberOfArguments(method) - 2;
        NSArray * argumentsArray = nil;
        if ( numberOfArguments > 0 ) {
            if ( beginIndex + numberOfArguments <= countOfObjects ) {
                argumentsArray = [objects subarrayWithRange:NSMakeRange(beginIndex, numberOfArguments)];
                beginIndex = beginIndex + numberOfArguments;
            } else {
                checkResult = NO;
                *stop = YES;
            }
        }
        //2.执行方法
        if ( checkResult && target && [target respondsToSelector:selector] ) {
            NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
            NSInvocation * myInvocation = [NSInvocation invocationWithMethodSignature:sig];
            [myInvocation setTarget:target];
            [myInvocation setSelector:selector];
            [argumentsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [myInvocation setArgument:&obj atIndex:idx + 2];
            }];
            [myInvocation invoke];
        }
    }];
    //校验参数失败
    if ( !checkResult ) {
        Debug(@">>LEAF : Arguments LOST ! Please check your input of function arguments <LEGetHeightForCellWithObject>.");
        return CGSizeZero;
    }
    //加入缓存
    CGSize cacheSize = [self.cell fittingSize];
    [self appendCacheValue:cacheSize forKey:objectKey];
    return cacheSize;
}

- (BOOL) isEqual : (id) object {
    if ( [object isMemberOfClass:[self class]] ) {
        return [[object cell] isMemberOfClass:[self.cell class]];
    }
    return NO;
}

@end

@interface LECollectionHelper : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> * collectionCaches;
@property (nonatomic, strong) NSMutableDictionary<NSString *, LECollectionAssosiateItem *> * cellCaches;

+ (instancetype) sharedInstance;

@end

@implementation LECollectionHelper

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    __strong static id _sharedObject = nil;
    dispatch_once( &onceToken, ^{
        _sharedObject = [[LECollectionHelper alloc] init];
    });
    return _sharedObject;
}

- (instancetype) init {
    if ( self = [super init] ) {
        [self setUp];
    }
    return self;
}

- (void) setUp {
    self.collectionCaches = [NSMutableDictionary dictionary];
    self.cellCaches = [NSMutableDictionary dictionary];
}

- (BOOL) addCell : (Class<LECollectionHelperProtocol>) cellClass collectionView : (UICollectionView *) collectionView {
    //指针指向对象地址
    NSString * locationKey = [NSString stringWithFormat:@"%p", collectionView];
    NSString * cellIdentifier = [cellClass identifier];
    //尝试获取对象
    NSMutableSet<NSString *> * set = [self.collectionCaches objectForKey:locationKey];
    //对象是否已经存在
    if ( set ) {
        if ( ![set containsObject:cellIdentifier] ) {   //如果没有本对象的管理，需要在此时添加进去
            UICollectionViewCell<LECollectionHelperProtocol> * cell = [cellClass collectionCellItem];
            [self.cellCaches setObject:[LECollectionAssosiateItem itemWithCell:cell] forKey:cellIdentifier];
            [set addObject:cellIdentifier];
        }
        return YES;
    } else {
        //添加索引关系
        [self.collectionCaches setObject:[NSMutableSet setWithObject:cellIdentifier] forKey:locationKey];
        //添加对象实体
        UICollectionViewCell<LECollectionHelperProtocol> * cell = [cellClass collectionCellItem];
        [self.cellCaches setObject:[LECollectionAssosiateItem itemWithCell:cell] forKey:cellIdentifier];
        return YES;
    }
    return NO;
}

- (void) removeCollectionView : (UICollectionView *) collectionView {
    //指针指向对象地址
    NSString * locationKey = [NSString stringWithFormat:@"%p", collectionView];
    NSMutableSet<NSString *> * set = [self.collectionCaches objectForKey:locationKey];
    if ( set ) {
        [set enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [self.cellCaches removeObjectForKey:obj];
        }];
    }
    [self.collectionCaches removeObjectForKey:locationKey];
}

- (BOOL) configurateCellSelectors : (Class<LECollectionHelperProtocol>) cellClass selectors : (NSArray<NSString *> *) selector {
    NSString * cellIdentifier = [cellClass identifier];
    LECollectionAssosiateItem * item = [self.cellCaches objectForKey:cellIdentifier];
    if ( item ) {
        [item addAssosiateSelectors:selector];
        return YES;
    }
    Debug(@">> ERROR : 未找到已经配置的类：%@",cellIdentifier);
    return NO;
}

- (CGSize) getSizeForCellClass : (Class<LECollectionHelperProtocol>) cellClass objects : (NSArray *) objects {
    NSString * cellIdentifier = [cellClass identifier];
    LECollectionAssosiateItem * item = [self.cellCaches objectForKey:cellIdentifier];
    if ( item ) {
        return [item applySizeForThoseObjects:objects];
    }
    Debug(@">> ERROR : 未找到已经配置的实体: %@", cellIdentifier);
    return CGSizeZero;
}

@end

BOOL LERegisterXibForCollection(NSString * xibName, UICollectionView * collectionView) {
    if ( xibName ) {
        UINib * nib = [UINib nibWithNibName:xibName bundle:nil];
        if ( nib ) {
            Class<LECollectionHelperProtocol> cellClass = NSClassFromString(xibName);
            if ( cellClass ) {
                [collectionView registerNib:nib forCellWithReuseIdentifier:[cellClass identifier]];
                [[LECollectionHelper sharedInstance] addCell:cellClass collectionView:collectionView];
                return YES;
            }
        }
    }
    Debug(@">> ERROR : 此方法只能用于xib文件!");
    return NO;
}

BOOL LERegisterCellForCollection(Class<LECollectionHelperProtocol> cellClass, UICollectionView * collectionView) {
    [collectionView registerClass:cellClass forCellWithReuseIdentifier:[cellClass identifier]];
    [[LECollectionHelper sharedInstance] addCell:cellClass collectionView:collectionView];
    return YES;
}

id LEGetCellForCollection(Class<LECollectionHelperProtocol> cellClass, UICollectionView * collectionView, NSIndexPath * indexPath) {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[cellClass identifier] forIndexPath:indexPath];
}

CGSize LEGetSizeForCellWithObject(Class<LECollectionHelperProtocol> cellClass, id obj, ...) {
    NSMutableArray * objects = [NSMutableArray array];
    va_list arguments;
    id eachObject;
    if ( obj ) {
        [objects addObject:obj];
        va_start(arguments, obj);
        while ( (eachObject = va_arg(arguments, id)) ) {
            [objects addObject:eachObject];
        }
        va_end(arguments);
    }
    return [[LECollectionHelper sharedInstance] getSizeForCellClass:cellClass objects:objects];
}

BOOL LEConfigurateCollectionCellBehaviorsFunctions(Class<LECollectionHelperProtocol> cellClass, SEL selector, ...) {
    //数据提取
    NSMutableArray<NSString *> * selectors = [NSMutableArray array];
    va_list arguments;
    SEL eachObject;
    if ( selector ) {
        [selectors addObject:NSStringFromSelector(selector)];
        va_start(arguments, selector);
        while ( (eachObject = va_arg(arguments, SEL)) ) {
            [selectors addObject:NSStringFromSelector(eachObject)];
        }
        va_end(arguments);
    }
    //执行
    return [[LECollectionHelper sharedInstance] configurateCellSelectors:cellClass selectors:selectors];
}

void LEReleaseCellForCollection(UICollectionView * collectionView) {
    [[LECollectionHelper sharedInstance] removeCollectionView:collectionView];
}
