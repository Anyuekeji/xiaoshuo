//
//  LETableHelper.m
//  BingoDu
//
//  Created by 刘云鹏 on 16/3/16.
//  Copyright © 2016年 2.0.2. All rights reserved.
//

#import "LETableHelper.h"
#import "NSArray+LEAF.h"
#import <objc/runtime.h>

#define LEHelperCacheCapacity   20

@interface LECellAssosiateItem : NSObject {
    NSUInteger _linkCount;
}

@property (nonatomic, strong) UITableViewCell<LETableHelperProtocol> * cell;
@property (nonatomic, strong) NSMutableArray<NSString *> * assosiateSelectors;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> * cacheDictionary;

/**
 *  添加表格引用次数
 */
- (NSUInteger) increaseLink;
/**
 *  减去表格引用次数
 */
- (NSUInteger) reduceLink;
/**
 *  是否已经没有引用了
 */
- (BOOL) isFreeLink;

@end

@implementation LECellAssosiateItem

+ (LECellAssosiateItem *) itemWithCell : (UITableViewCell<LETableHelperProtocol> *) cell {
    LECellAssosiateItem * item = [[LECellAssosiateItem alloc] init];
    item.cell = cell;
    return item;
}

+ (LECellAssosiateItem *) item {
    return [[self alloc] init];
}

- (instancetype) init {
    if ( self = [super init] ) {
        self.assosiateSelectors = [NSMutableArray array];
        self.cacheDictionary = [NSMutableDictionary dictionaryWithCapacity:LEHelperCacheCapacity];
        _linkCount = 1;
    }
    return self;
}

- (void) appendCacheValue : (CGFloat) height forKey : (NSString *) key {
    if ( self.cacheDictionary.count == LEHelperCacheCapacity ) {
        [self.cacheDictionary removeObjectForKey:[[self.cacheDictionary allKeys] firstObject]];
    }
    if ( key ) {
        [self.cacheDictionary setObject:@(height) forKey:key];
    }
}

- (void) addAssosiateSelectors : (NSArray<NSString *> *) selectors {
    NSArray * arrayToAdd = [selectors select:^BOOL(NSString * object) {
        return ![self.assosiateSelectors containsObject:object];
    }];
    [self.assosiateSelectors addObjectsFromArray:arrayToAdd];
}

- (CGFloat) applyHeightForThoseObjects : (NSArray *) objects {
    //开始新的植入
    __weak id target = self.cell;
    Class cellClass = [target class];
    if ( target == nil ) {
        Debug(@">>LEAF : Unset CELL ! You may lost register? or configuration! Now returned ZERO.");
        return 0.0f;
    } else if ( [cellClass respondsToSelector:@selector(cellHeight)] ) {
        return [cellClass cellHeight];
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
    NSNumber * cacheHeightNumber = [self.cacheDictionary objectForKey:objectKey];
    if ( cacheHeightNumber && cacheHeightNumber.floatValue > 1.0f ) { //如果高度计算小于1需要重新计算高度

        return [cacheHeightNumber floatValue];
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
            [argumentsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                [myInvocation setArgument:&obj2 atIndex:idx + 2];
            }];
            [myInvocation invoke];
        }
    }];
    //校验参数失败
    if ( !checkResult ) {
        Debug(@">>LEAF : Arguments LOST ! Please check your input of function arguments <LEGetHeightForCellWithObject>.");
        return 0.0f;
    }
    //加入缓存9
    CGFloat chacheFloat = [self.cell fittingSizeHeight];
    [self appendCacheValue:chacheFloat forKey:objectKey];
   // ZWLog(@"the objects is %@ height is %@",objects,chacheFloat);
    return chacheFloat;
}

- (BOOL) isEqual : (id) object {
    if ( [object isMemberOfClass:[self class]] ) {
        return [[object cell] isMemberOfClass:[self.cell class]];
    }
    return NO;
}

- (NSUInteger) increaseLink {
    return ++ _linkCount;
}

- (NSUInteger) reduceLink {
    return -- _linkCount;
}

- (BOOL) isFreeLink {
    return _linkCount == 0;
}

@end

@interface LETableHelper : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> * tableCaches;
@property (nonatomic, strong) NSMutableDictionary<NSString *, LECellAssosiateItem *> * cellCaches;

+ (instancetype) sharedInstance;

@end

@implementation LETableHelper

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    __strong static id _sharedObject = nil;
    dispatch_once( &onceToken, ^{
        _sharedObject = [[LETableHelper alloc] init];
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
    self.tableCaches = [NSMutableDictionary dictionary];
    self.cellCaches = [NSMutableDictionary dictionary];
}

- (BOOL) addCell : (Class<LETableHelperProtocol>) cellClass tableView : (UITableView *) tableView {
    //指针指向对象地址
    NSString * locationKey = [NSString stringWithFormat:@"%p", tableView];
    NSString * cellIdentifier = [cellClass identifier];
    //尝试获取对象
    NSMutableSet<NSString *> * set = [self.tableCaches objectForKey:locationKey];
    //对象是否已经存在
    if ( set ) {
        if ( ![set containsObject:cellIdentifier] ) {   //如果没有本对象的管理，需要在此时添加进去
            if ( [self.cellCaches objectForKey:cellIdentifier] )  {
                LECellAssosiateItem * assosiateItem = [self.cellCaches objectForKey:cellIdentifier];
                [assosiateItem increaseLink];           //如果已经存在只要增量引用次数
            } else {
                UITableViewCell<LETableHelperProtocol> * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                [self.cellCaches setObject:[LECellAssosiateItem itemWithCell:cell] forKey:cellIdentifier];
                [set addObject:cellIdentifier];
            }
        }
        return YES;
    } else {
        //添加索引关系
        [self.tableCaches setObject:[NSMutableSet setWithObject:cellIdentifier] forKey:locationKey];
        //添加对象实体
        if ( [self.cellCaches objectForKey:cellIdentifier] )  {
            LECellAssosiateItem * assosiateItem = [self.cellCaches objectForKey:cellIdentifier];
            [assosiateItem increaseLink];             //如果已经存在只要增量引用次数
        } else {
            UITableViewCell<LETableHelperProtocol> * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            [self.cellCaches setObject:[LECellAssosiateItem itemWithCell:cell] forKey:cellIdentifier];
            [set addObject:cellIdentifier];
        }
        return YES;
    }
    return NO;
}

- (void) removeTable : (UITableView *) tableView {
    //指针指向对象地址
    NSString * locationKey = [NSString stringWithFormat:@"%p", tableView];
    NSMutableSet<NSString *> * set = [self.tableCaches objectForKey:locationKey];
    if ( set ) {
        [set enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            LECellAssosiateItem * assosiateItem = [self.cellCaches objectForKey:obj];
            [assosiateItem reduceLink];
            if ( [assosiateItem isFreeLink] ) {
                [self.cellCaches removeObjectForKey:obj];
            }
        }];
    }
    [self.tableCaches removeObjectForKey:locationKey];
}

- (BOOL) configurateCellSelectors : (Class<LETableHelperProtocol>) cellClass selectors : (NSArray<NSString *> *) selector {
    NSString * cellIdentifier = [cellClass identifier];
    LECellAssosiateItem * item = [self.cellCaches objectForKey:cellIdentifier];
    if ( item ) {
        [item addAssosiateSelectors:selector];
        return YES;
    }
    Debug(@">> ERROR : 未找到已经配置的类：%@",cellIdentifier);
    return NO;
}

- (CGFloat) getHeightForCellClass : (Class<LETableHelperProtocol>) cellClass objects : (NSArray *) objects {
    NSString * cellIdentifier = [cellClass identifier];
    LECellAssosiateItem * item = [self.cellCaches objectForKey:cellIdentifier];
    if ( item ) {
        return [item applyHeightForThoseObjects:objects];
    }
    Debug(@">> ERROR : 未找到已经配置的实体: %@", cellIdentifier);
    return 0.0f;
}

@end

UIKIT_EXTERN BOOL LERegisterXibForTable(NSString * xibName, UITableView * tableView) {
    if ( xibName ) {
        UINib * nib = [UINib nibWithNibName:xibName bundle:nil];
        if ( nib ) {
            Class<LETableHelperProtocol> cellClass = NSClassFromString(xibName);
            if ( cellClass ) {
                [tableView registerNib:nib forCellReuseIdentifier:[cellClass identifier]];
                [[LETableHelper sharedInstance] addCell:cellClass tableView:tableView];
                return YES;
            }
        }
    }
    Debug(@">> ERROR : 此方法只能用于xib文件!");
    return NO;
}

UIKIT_EXTERN BOOL LERegisterCellForTable(Class<LETableHelperProtocol> cellClass, UITableView * tableView) {
    [tableView registerClass:cellClass forCellReuseIdentifier:[cellClass identifier]];
    [[LETableHelper sharedInstance] addCell:cellClass tableView:tableView];
    return YES;
}

UIKIT_EXTERN UITableViewCell * LEGetCellForTable(Class<LETableHelperProtocol> cellClass, UITableView * tableView, NSIndexPath * indexPath) {
    return [tableView dequeueReusableCellWithIdentifier:[cellClass identifier] forIndexPath:indexPath];
}

UIKIT_EXTERN CGFloat LEGetHeightForCellWithObject(Class<LETableHelperProtocol> cellClass, id obj, ...) {
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
    return [[LETableHelper sharedInstance] getHeightForCellClass:cellClass objects:objects];
}

UIKIT_EXTERN BOOL LEConfigurateCellBehaviorsFunctions(Class<LETableHelperProtocol> cellClass, SEL selector, ...) {
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
    return [[LETableHelper sharedInstance] configurateCellSelectors:cellClass selectors:selectors];
}

UIKIT_EXTERN void LEReleaseCellForTable(UITableView * tableView) {
    [[LETableHelper sharedInstance] removeTable:tableView];
}


