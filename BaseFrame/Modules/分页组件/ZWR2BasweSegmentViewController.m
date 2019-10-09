//
//  ZWR2SegmentViewController.m
//  CallU
//
//  Created by Leaf on 2017/3/27.
//  Copyright © 2017年 2.1.6. All rights reserved.
//

#import "ZWR2BaseSegmentViewController.h"
#import "LESegment.h"
#import "LEHorizontalSlideView.h"
#import "UIView+subview.h"

@interface ZWR2SegmentView : UIView

@property (nonatomic, strong) ZWR2SegmentItem * segmentItem;
@property (nonatomic, weak) UIViewController * parentViewController;

@end

@implementation ZWR2SegmentView

- (void) setSegmentItem:(ZWR2SegmentItem *)segmentItem {
    if ( _segmentItem != segmentItem ) {
        //先把旧的界面控制器移除
        [self removeAllSubviews];
        //再把新的加入
        UIViewController * toViewController = segmentItem.viewController;
        if ( toViewController ) {
            if ( ![self.parentViewController.childViewControllers containsObject:toViewController] ) {
                [self.parentViewController addChildViewController:toViewController];
                toViewController.view.frame = self.bounds;
                [self addSubview:toViewController.view];
                [toViewController didMoveToParentViewController:self.parentViewController];
            } else {
                toViewController.view.frame = self.bounds;
                [self addSubview:toViewController.view];
            }
        } else {
            Debug(@">> ERROR : 严重错误:未能生成将要展现的控制器！");
        }
        //更新数据
        _segmentItem = segmentItem;
    }
}
@end


@interface ZWR2BaseSegmentViewController () <LEHorizontalSlideViewDataSource, LEHorizontalSlideViewDelegate> {
    NSMutableSet<ZWR2SegmentItem *> * _translateReleaseChilds;
    NSMutableSet<ZWR2SegmentItem *> * _translateLoadedChilds;
    NSMutableSet<ZWR2SegmentItem *> * _currentLoadedChilds;
    //首次加载viewWillAppear过滤器
    BOOL _inNeedToSend;
}

@property (nonatomic, strong, readonly) LEHorizontalSlideView * childContainerView;
/**右边的约束*/
@property (nonatomic, readonly, strong) NSLayoutConstraint * segmenControlRightContraint;


@end

@implementation ZWR2BaseSegmentViewController

- (void) dealloc {
    _delegate = nil;
    [self clean];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _translateLoadedChilds = [NSMutableSet setWithCapacity:3];
    _translateReleaseChilds = [NSMutableSet setWithCapacity:3];
    _currentLoadedChilds = [NSMutableSet setWithCapacity:3];
    //
    [self confirgueSegmentControllerUi];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //
    [self _sendSegmentViewWillAppearEvents];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //
    [self _sendSegmentViewWillDisappearEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //非当前显示控制器内容全部被释放
    [self.segments enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //已经存在控制器但是不在当前的显示范围内，就执行置空和移除动作
        if ( [obj isCreatedViewController] &&
            ![_currentLoadedChilds containsObject:obj] ) {
            if ( obj.viewController.parentViewController ) {
                [obj.viewController willMoveToParentViewController:nil];
                [obj.viewController removeFromParentViewController];
            }
            obj.viewController = nil;
            Debug(@">> 收到内存警告，释放了:%@", obj.segmentTitle);
        }
    }];
}

- (void) configureSegmentControl {
    self.segmentControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    _segmenControlTopContraint =[NSLayoutConstraint constraintWithItem:self.segmentControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    [self.view addConstraint:_segmenControlTopContraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentControl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
    _segmenControlRightContraint = [NSLayoutConstraint constraintWithItem:self.segmentControl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    [self.view addConstraint:self.segmenControlRightContraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:SEGMENT_BAR_HEIGHT]];
}

- (void) confirgueSegmentControllerUi {
    
    if([self.view containSubview:self.segmentControl])
   {
       [self configureSegmentControl];
   }

    if (self.segmentControl) {
        __weak typeof(self) weakSelf = self;
        [self.segmentControl setSegmentDidChangeSelectedValue:^(NSUInteger index) {
            [weakSelf segmentedControlChangedValue:index];
        }];
    }
    
    _childContainerView = [[LEHorizontalSlideView alloc] init];
    self.childContainerView.dataSource = self;
    self.childContainerView.delegate = self;
    self.childContainerView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    [self.view addSubview:self.childContainerView];
    
    self.childContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.childContainerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.childContainerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.childContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:([self.view containSubview:self.segmentControl]?self.segmentControl:self.view) attribute:([self.view containSubview:self.segmentControl]?NSLayoutAttributeBottom:NSLayoutAttributeTop) multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.childContainerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    
}

- (void) segmentedControlChangedValue : (NSUInteger) toValue {
    [self.childContainerView setCurrentItemIndex:toValue];
}

#pragma mark - LEHorizontalSlideViewDataSource
- (NSUInteger) numberOfItemsInSlideView : (LEHorizontalSlideView *) horizontalSlideView {
    return self.segments.count;
}

- (UIView *) horizontalSlideView : (LEHorizontalSlideView *) horizontalSlideView viewForItemAtIndex : (NSUInteger) index reusingView : (ZWR2SegmentView *) view {
    if ( !view ) {
        view = [[ZWR2SegmentView alloc] init];
        view.parentViewController = self;
        view.backgroundColor = [UIColor clearColor];
    }
    //将要移除的数据
    [self pushItemWillRemoved:view.segmentItem];
    //
    view.segmentItem = self.segments[index];
    //将要添加的数据
    [self pushItemWillLoaded:view.segmentItem];
    //
    return view;
}

#pragma mark - LEHorizontalSlideViewDelegate
- (void) horizontalSlideViewCurrentItemIndexDidChange:(LEHorizontalSlideView *) horizontalSlideView {
    //重设段
    [self.segmentControl setSelectedIndex:horizontalSlideView.currentItemIndex];
    //发送代理事件
    [self sendSegmentEvent];
}

- (void) sendSegmentEvent {
    //上一个页面需要发送移走事件
    if ( self.segments.count > self.childContainerView.latestItemIndex ) {
        UIViewController<ZWR2SegmentViewControllerProtocol> * viewController = self.segments[self.childContainerView.latestItemIndex].viewController;
        if ( [viewController respondsToSelector:@selector(segmentViewWillDisappear)] ) {
            [viewController segmentViewWillDisappear];
        }
//        Debug(@">将要消失: %@", self.segments[self.childContainerView.latestItemIndex].segmentTitle);
    }
    //发送移除事件
    NSSet<ZWR2SegmentItem *> * items = [self popItemsWhichRemoved];
    [items enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, BOOL * _Nonnull stop) {
        UIViewController<ZWR2SegmentViewControllerProtocol> * viewController = obj.viewController;
        if ( [viewController respondsToSelector:@selector(segmentDidRemoveViewController)] ) {
            [viewController segmentDidRemoveViewController];
        }
        //发送代理
        if ( self.delegate && [self.delegate respondsToSelector:@selector(zwr2SegmentViewController:didRemoveSegmentItem:)] ) {
            [self.delegate zwr2SegmentViewController:self didRemoveSegmentItem:obj];
        }
//        Debug(@">移除 : %@", obj.segmentTitle);
    }];
    //将要加载的段
    items = [self popItemsWhichLoaded];
    [items enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, BOOL * _Nonnull stop) {
        UIViewController<ZWR2SegmentViewControllerProtocol> * viewController = obj.viewController;
        if ( [viewController respondsToSelector:@selector(segmentDidLoadViewController)] ) {
            [viewController segmentDidLoadViewController];
        }
        //发送代理
        if ( self.delegate && [self.delegate respondsToSelector:@selector(zwr2SegmentViewController:didLoadSegmentItem:)] ) {
            [self.delegate zwr2SegmentViewController:self didLoadSegmentItem:obj];
        }
//        Debug(@">加载 : %@", obj.segmentTitle);
    }];
    //重设缓冲池
    [self resetTranslateArrays];
    //当前显示的控制发送显示事件
    if ( self.segments.count > self.childContainerView.currentItemIndex ) {
        UIViewController<ZWR2SegmentViewControllerProtocol> * viewController = self.segments[self.childContainerView.currentItemIndex].viewController;
        if ( [viewController respondsToSelector:@selector(segmentViewWillAppear)] ) {
            [viewController segmentViewWillAppear];
        }
        //发送代理
        if ( self.delegate && [self.delegate respondsToSelector:@selector(zwr2SegmentViewController:switchToSegmentItem:)] ) {
            [self.delegate zwr2SegmentViewController:self switchToSegmentItem:self.segments[self.childContainerView.currentItemIndex]];
        }
//        Debug(@">将要显示: %@", self.segments[self.childContainerView.currentItemIndex].segmentTitle);
    }
}

#pragma mark - Getter & Setter
- (void) setCurrentIndex:(NSUInteger)currentIndex {
    if ( self.segmentControl.selectedIndex != currentIndex ) {
        self.segmentControl.selectedIndex = currentIndex;
        self.childContainerView.currentItemIndex = currentIndex;
    }
}

- (NSUInteger) currentIndex {
    return self.segmentControl.selectedIndex;
}

- (void) clean {
    //1.1.移除所有当前有的子控制器
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj willMoveToParentViewController:nil];
        [obj removeFromParentViewController];
    }];
    //1.2.移除所有KVO
    [_segments enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeObserver:self forKeyPath:@"segmentTitle"];
    }];
}

- (void) setSegments:(NSArray<ZWR2SegmentItem *> *)segments {
    if ( _segments ) {
        //1.清空关系
        [self clean];
        //2.替换已经存在数据
        NSMutableArray<ZWR2SegmentItem *> * replaceArray = [NSMutableArray arrayWithCapacity:segments.count];
        for ( NSUInteger idx = 0 ; idx < segments.count ; idx ++ ) {
            ZWR2SegmentItem * toItem = segments[idx];
            if ( [_segments containsObject:toItem] ) {
                NSUInteger replaceItemIndex = [_segments indexOfObject:toItem];
                [replaceArray addObject:_segments[replaceItemIndex]];
            } else {
                [replaceArray addObject:toItem];
            }
        }
        segments = replaceArray;
    }
    _segments = segments;
    //3.重新添加KVO
    [_segments enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addObserver:self forKeyPath:@"segmentTitle" options:NSKeyValueObservingOptionNew context:nil];
    }];
    //4.发送代理更新：这里涉及到slide控制器，必须在界面刷新之前执行
    if ( self.delegate && [self.delegate respondsToSelector:@selector(zwr2SegmentViewControllerDidResetContent:)] ) {
        [self.delegate zwr2SegmentViewControllerDidResetContent:self];
    }
    //5.更新UI
    [self _segementUIUpdate];
    
    if (![self.view containSubview:_segmentControl]) {
        CGSize segmentSize = [_segmentControl getSegmentContentSize];
        if (segmentSize.width >ScreenWidth-60) {
            CGRect rect = _segmentControl.frame;
            rect.size = CGSizeMake(ScreenWidth, segmentSize.height);
            _segmentControl.frame = rect;
        }
        else
        {
            CGRect rect = _segmentControl.frame;
            rect.size = segmentSize;
            _segmentControl.frame = rect;
        }
    }
    
    
}

- (ZWR2SegmentItem *) currentSelectedSegmentItem {
    if ( self.segments.count > self.childContainerView.currentItemIndex ) {
        return self.segments[self.childContainerView.currentItemIndex];
    }
    return nil;
}

- (UIViewController<ZWR2SegmentViewControllerProtocol> *) currentSelectedViewController {
    return [[self currentSelectedSegmentItem] viewController];
}

#pragma mark - KVO
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"segmentTitle"] ) {
        NSUInteger curSelectedIndex = self.segmentControl.selectedIndex;
        [self _updateSegmentControlTitles];
        self.segmentControl.selectedIndex = curSelectedIndex;
    }
}

#pragma mark - UI Private
- (void) _segementUIUpdate {
    [self _updateSegmentControlTitles];
    [self _updateContainers];
}

- (void) _updateSegmentControlTitles {
    NSMutableArray<NSString *> * titles = [NSMutableArray arrayWithCapacity:self.segments.count];
    [self.segments enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj.segmentTitle ) {
            [titles addObject:obj.segmentTitle];
        } else {
            [titles addObject:@"未添加"];
        }
    }];
    [self.segmentControl setItems:titles];
}

- (void) _updateContainers {
    [self.childContainerView reloadData];
}

#pragma mark - UI Public
- (void) setSegmentBackgroundColor : (UIColor *) backgroundColor {
    self.segmentControl.backgroundColor = backgroundColor;
}

- (UIColor *) segmentBackgroundColor {
    return self.segmentControl.backgroundColor;
}

- (void) addViewToSegmentControlRight : (UIView *) view {
    if ([self.view containSubview:self.segmentControl]) {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.segmentControl attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.segmentControl attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
        if ( view.width > 0.0f ) {
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:view.width]];
        }
        [self.view removeConstraint:self.segmenControlRightContraint];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentControl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
    }

}

- (void) setSegmentTypeToFixedWidth : (CGFloat) width {
    self.segmentControl.type = LESegmentTypeFixedWidth;
    self.segmentControl.itemFixedWidth = width;
}

- (void) addRedPointAtIndex : (NSUInteger) index {
    if ( index != self.segmentControl.selectedIndex ) {
        [self.segmentControl addRedPointAtIndex:index];
    }
}

- (void) addRedPointAtSegmentItem : (ZWR2SegmentItem *) segmentItem {
    if ( segmentItem && [self.segments containsObject:segmentItem] ) {
        NSUInteger index = [self.segments indexOfObject:segmentItem];
        [self addRedPointAtIndex:index];
    }
}

- (void) removeRedPointAtIndex : (NSUInteger) index {
    [self.segmentControl removeRedPointAtIndex:index];
}

- (void) removeRedPointAtSegmentItem : (ZWR2SegmentItem *) segmentItem {
    if ( segmentItem && [self.segments containsObject:segmentItem] ) {
        NSUInteger index = [self.segments indexOfObject:segmentItem];
        [self removeRedPointAtIndex:index];
    }
}

#pragma mark - Private
- (void) _sendSegmentViewWillAppearEvents {
    if ( _inNeedToSend && self.segments.count > self.currentIndex && self.currentIndex > 0 ) {
        UIViewController<ZWR2SegmentViewControllerProtocol> * viewController = self.currentSelectedViewController;
        if ( [viewController respondsToSelector:@selector(segmentViewWillAppear)] ) {
            [viewController segmentViewWillAppear];
        }
//        Debug(@">将要显示: %@", self.currentSelectedSegmentItem.segmentTitle);
    } else {
        _inNeedToSend = YES;
    }
}

- (void) _sendSegmentViewWillDisappearEvents {
    if ( self.segments.count > self.currentIndex && self.currentIndex > 0 ) {        
        UIViewController<ZWR2SegmentViewControllerProtocol> * viewController = self.currentSelectedViewController;
        if ( [viewController respondsToSelector:@selector(segmentViewWillDisappear)] ) {
            [viewController segmentViewWillDisappear];
        }
//        Debug(@">将要消失: %@", self.currentSelectedSegmentItem.segmentTitle);
    }
}

#pragma mark - Helpers
- (void) pushItemWillRemoved : (ZWR2SegmentItem *) item {
    if ( item && ![_translateReleaseChilds containsObject:item] ) {
        [_translateReleaseChilds addObject:item];
    }
}

- (void) pushItemWillLoaded : (ZWR2SegmentItem *) item {
    if ( item && ![_translateLoadedChilds containsObject:item] ) {
        [_translateLoadedChilds addObject:item];
    }
}

- (NSSet<ZWR2SegmentItem *> *) popItemsWhichRemoved {
    NSMutableSet * set = [NSMutableSet setWithSet:_translateReleaseChilds];
    [_translateLoadedChilds enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, BOOL * _Nonnull stop) {
        [set removeObject:obj];
    }];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [_currentLoadedChilds removeObject:obj];
    }];
    return set;
}

- (NSSet<ZWR2SegmentItem *> *) popItemsWhichLoaded {
    NSMutableSet * set = [NSMutableSet setWithSet:_translateLoadedChilds];
    [_currentLoadedChilds enumerateObjectsUsingBlock:^(ZWR2SegmentItem * _Nonnull obj, BOOL * _Nonnull stop) {
        [set removeObject:obj];
    }];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [_currentLoadedChilds addObject:obj];
    }];
    return set;
}

- (void) resetTranslateArrays {
    [_translateReleaseChilds removeAllObjects];
    [_translateLoadedChilds removeAllObjects];
}

@end
