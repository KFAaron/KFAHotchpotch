//
//  KFAPageViewController.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFASegmentControl.h"

@class KFAPageViewControllerItem;

@interface KFAPageViewController : UIViewController

@property (nonatomic, strong) UIScrollView *containerView;

@property (nonatomic, copy) NSArray<KFAPageViewControllerItem *> *controllerItems;
@property (nonatomic, readonly) KFASegmentControl *segmentedControl;
@property (nonatomic, assign) NSUInteger selectedIndex;
/**
 是否可以左右滑动 默认可以
 */
@property (nonatomic, assign) BOOL scrollEnable;

/**
 分隔条的高度 默认44 子类中通过重写getter方法赋值
 */
@property (nonatomic, assign) CGFloat segmentControlHeight;

/**
 插入一个VC元素
 
 @param viewControllerItem VC元素模型
 @param index 插入的位置
 */
- (void)insertViewControllerItem:(KFAPageViewControllerItem *)viewControllerItem atIndex:(NSUInteger)index;

/**
 删除一个VC元素
 
 @param viewController 删除的VC
 */
- (void)removeViewController:(UIViewController *)viewController;

/**
 移动到某个VC
 
 @param viewController  要移动到的VC
 */
- (void)moveToViewController:(UIViewController *)viewController;

/**
 查询某个VC的index
 
 @param viewController 要查询的VC
 */
- (NSUInteger)indexOfViewController:(UIViewController *)viewController;

/**
 移动到某个VC
 
 @param viewController 移动到的VC
 */
- (void)didGoToViewController:(UIViewController *)viewController;

/**
 当前展示（选择）的视图的脚标
 
 @return 视图的脚标
 */
- (NSUInteger)selectedViewIndex;

/**
 埋点用
 
 @param title 在子类里重写
 */
- (void)statisticsTitle:(NSString *)title;

@end


