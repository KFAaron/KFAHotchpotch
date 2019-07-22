//
//  KFASegmentControl.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 指示器宽度风格
typedef NS_ENUM(NSUInteger, KFASegmentedControlIndicatorWidthStyle) {
    KFASegmentedControlIndicatorWidthStyleText, //和文字长度相同
    KFASegmentedControlIndicatorWidthStyleShort, //自定义长度
    KFASegmentedControlIndicatorWidthStyleBackground //背景
};

typedef NS_ENUM(NSInteger, KFASegmentedControlWidthStyle) {
    KFASegmentedControlWidthStyleFixed,    // 平均分割
    KFASegmentedControlWidthStyleDynamic,  // 同字体宽度
};

typedef NS_ENUM(NSInteger, KFASegmentedControlTextPosition) {
    KFASegmentedControlTextPositionMiddle,    // 垂直居中
    KFASegmentedControlTextPositionBottom,     // 底部对齐
};

@class KFASegmentControl;

@protocol KFASegmentControlDelegate <NSObject>

@optional

- (void)segmentControlDidEndScroll:(KFASegmentControl *)segmentControl isDragging:(BOOL)isDragging;

- (void)segmentControlViewWillBeginDragging:(UIScrollView *)scrollView;

@end

@protocol KFASegmentControlDatasource <NSObject>

@optional
/** 为指定的item添加角标 */
- (UIView *)segmentControl:(KFASegmentControl *)segmentControl bageViewAtIndex:(NSInteger)index;

/** 每个角标的偏移量，默认(0,10,5,0) */
- (UIEdgeInsets)segmentControl:(KFASegmentControl *)segmentControl edgeInsetsAtIndex:(NSInteger)index;

/** 每个角标相对于文字的位置,默认为(1,0) 即bageView的左下角对应文字右上角，范围0~1*/
- (CGPoint)segmentControl:(KFASegmentControl *)segmentControl bagePointAtIndex:(NSInteger)index;

@end

@interface KFASegmentControl : UIControl

- (instancetype)initWithTitles:(NSArray <NSString *> *)titles;
- (instancetype)initWithTitles:(NSArray <NSString *> *)titles dataSource:(id<KFASegmentControlDatasource>)dataSource;

@property(nonatomic, weak) id<KFASegmentControlDelegate> delegate;
/** 标题数组 */
@property(nonatomic, strong)NSArray *titles;
/** 当前选中index */
@property (nonatomic, assign) NSUInteger selectedSegmentIndex;
/** 宽度类型 */
@property (nonatomic, assign) KFASegmentedControlWidthStyle widthStyle;
/** 文字位置，默认：KFASegmentedControlTextPositionMiddle */
@property(nonatomic, assign)KFASegmentedControlTextPosition textPosition;
/** 当前segment的整体宽度 */
@property(nonatomic, assign,readonly)CGFloat segmentTotalWidth;
/** 是否展示底部阴影 默认为NO */
@property(nonatomic, assign,getter=isShowBottomShadow)BOOL showBottomShadow;
/** 是否显示动画 默认为NO*/
@property (nonatomic) BOOL textAnimate;
/** 水平间距 默认24 */
@property (nonatomic, assign) CGFloat horizontalPadding;
/** 刷新数据 */
- (void)reloadData;
/**
 * 上下左右内边距
 *
 * Default is UIEdgeInsetsMake(0, 10, 5, 10)
 */
@property (nonatomic, readwrite) UIEdgeInsets segmentEdgeInset;
/** 设置字体颜色*/
- (void)setTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;
/** 设置当前index */
- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex ignoreAction:(BOOL)ignoreAction;
/** 设置当前index */
- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animation:(BOOL)animation;

- (void)insertTitle:(NSString *)title atIndex:(NSUInteger)index;

- (void)removeTitleAtIndex:(NSUInteger)index;

- (void)replaceTitle:(NSString *)title atIndex:(NSUInteger)index;
#pragma mark - 设置代理方法
- (void)segmentControlDidScroll:(UIScrollView *)scrollView;

- (void)segmentControlDidEndDecelerating:(UIScrollView *)scrollView;

- (void)segmentControlDidEndScrollingAnimation:(UIScrollView *)scrollView;
/** 设置整体的背景色(如果有Indicator，则也会修改Indicator的颜色) */
- (void)segmentControlChangeBackgroundWithTargetColor:(UIColor *)targetColor;

#pragma mark - Indicator
/** 是否显示底部Indicator */
@property (nonatomic, assign, getter=isShowsIndicator) BOOL showsIndicator;
/** Indicator样式 */
@property (nonatomic, assign) KFASegmentedControlIndicatorWidthStyle indicatorWidthStyle;
/** Indicator高度 默认6，
 indicatorWidthStyle=BPRSegmentedControlWidthStyleBackground时无效
 */
@property (nonatomic, assign) CGFloat indicatorHeight;
/**
 Indicator默认为文字宽高，设置此属性，表示上下左右向外扩展的大小
 indicatorWidthStyle=BPRSegmentedControlWidthStyleBackground时生效
 默认为 UIEdgeInsetsMake(5, 12, 5, 12)
 */
@property (nonatomic, readwrite) UIEdgeInsets indicatorContentOffset;
/** Indicator执行动画的最大宽度 默认 50 */
@property (nonatomic, assign) CGFloat indicatorMaxWidth;
/** Indicator默认展示宽度 默认 24 */
@property (nonatomic, assign) CGFloat indicatorMinWidth;
/** Indicator背景色 默认 Black */
@property (nonatomic, strong) UIColor *indicatorBackgroundColor;
/** Indicator距离segment的距离 默认距离顶部是5 */
@property(nonatomic, assign)CGFloat indicatorMarginTop;
/** 是否显示indicator动画 */
@property(nonatomic, assign)BOOL indicatorAnimation;

@end


