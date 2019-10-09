#import "NSArray+NHZW.h"
#import <objc/runtime.h>

@implementation NSMutableArray (NHZW)

- (void)safe_addObject:(id)anObject {
    if (anObject) { [self addObject:anObject]; }
}

- (void)safe_addObjectsFromArray:(NSArray *)otherArray {
    if (otherArray && [otherArray count]) {
        [self addObjectsFromArray:otherArray];
    }
}

- (void)safe_removeObject:(id)anObject {
    if (anObject) { [self removeObject:anObject]; }
}

- (void)safe_removeObjectsInArray:(NSArray *)otherArray {
    if (otherArray && otherArray.count>0) {
        [self removeObjectsInArray:otherArray];
    }
}

- (id)safe_objectAtIndex:(NSUInteger)index {
    if (self && [self count] > index) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end

@implementation NSArray (ClassSupport)

+ (NSArray *)propertiesInClass:(Class)cls {
    if (!cls) return nil;
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    // 遍历
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [tempArr addObject:name];
    }
    return tempArr.copy;
}
@end
