//
//  KFASegmentControl.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFASegmentControl.h"
#import "KFASegmentScrollView.h"
#import "KFASegmentControlItem.h"
#import "KFASegmentFactory.h"
#import "UIView+KFASement.h"

typedef KFASegmentControlItem Item;

typedef void(^AnimationBlock)(NSTimeInterval timeout);
typedef void(^AnimationCompleteBlock)(BOOL finish);

static const CGFloat KFASegmentWidthMinmum = 48.0;

static const CGFloat KFASegmentBageViewBaseTag = 100;
static const CGFloat KFASegmentBageViewBottomOffset = 5;
static const CGFloat KFASegmentBageViewLeftOffset = 10;

/** Indicator */
static const CGFloat KFAIndicatorShadowOpacity = 0.3;
static const CGFloat KFAIndicatorShadowRadius = 2;
static const CGFloat KFAIndicatorShadowPathWidth = 4;

/** KFASegment */
static const CGFloat KFASegmentShadowOpacity = 0.04;
static const CGFloat KFASegmentShadowRadius = 4;
static const CGFloat KFASegmentShadowPathWidth = 8;

@interface KFASegmentControl () <UIScrollViewDelegate>

@property(nonatomic, strong) KFASegmentScrollView *container;
@property (nonatomic, strong, readwrite) UIView *indicator;
@property(nonatomic, strong)NSArray *curTitles;
@property(nonatomic, assign)CGFloat minFontSize;
@property(nonatomic, assign)CGFloat maxFontSize;
/** 存放所有Label及其父视图的数组 */
@property(nonatomic, strong)NSMutableArray<Item *> *items;
/** 用来标志是否是点击切换 */
@property(nonatomic, assign)BOOL isChangeByClick;
/** Normal */
@property (nonatomic, copy) NSDictionary *attributesNormal;
/** Select */
@property (nonatomic, copy) NSDictionary *attributesSelected;
/** 初始选中的rect */
@property(nonatomic, assign)CGRect selectOriginRect;
/** 动态改变背景色所需要的临时变量 */
@property(nonatomic, strong)UIColor *targetColor;
/** 数据源方法 */
@property(nonatomic, weak)id<KFASegmentControlDatasource> dataSource;
/** 标题到底部的距离 */
@property(nonatomic, assign)CGFloat titleBottomMargin;
/** 当前Segment是否正在执行动画 */
@property(nonatomic, assign)BOOL isAnimation;
/** 动画剩余时间 */
@property(nonatomic, assign)NSTimeInterval animationTimeout;

@property(nonatomic, assign)BOOL selectIndexAnimation;

#pragma mark - 动画需要使用的属性
@property(nonatomic, strong)CADisplayLink *displayLink;
@property(nonatomic, assign)NSUInteger fromIndex;
@property(nonatomic, assign)NSUInteger toIndex;
@property(nonatomic, assign)NSTimeInterval timeout;

@end

@implementation KFASegmentControl

- (instancetype)initWithTitles:(NSArray <NSString *> *)titles{
    if (self = [super init]) {
        _curTitles = titles;
        _attributesNormal = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                              NSForegroundColorAttributeName: [UIColor lightGrayColor]};
        _attributesSelected = [_attributesNormal copy];
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles dataSource:(id<KFASegmentControlDatasource>)dataSource{
    _dataSource = dataSource;
    return [self initWithTitles:titles];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.container.frame = self.bounds;
    
    [self updateFrame];
    [self updateBageFrame];
    [self updateIndicatorFrame];
    [self updateShadow];
    [self updateSelectIndexAttribute];
}

- (void)dealloc{
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

#pragma mark - Public
- (void)setTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    UIFont *font = attributes[NSFontAttributeName];
    if (state == UIControlStateNormal) {
        self.attributesNormal = attributes;
        _minFontSize = font.pointSize;
    } else {
        self.attributesSelected = attributes;
        _maxFontSize = font.pointSize;
    }
    [self setNeedsLayout];
}

- (void)segmentControlDidScroll:(UIScrollView *)scrollView{
    if(!self) return;
    if (_isChangeByClick) return;
    if (_textAnimate){
        //更新Rect
        if (_widthStyle == KFASegmentedControlWidthStyleDynamic) {
            [self updateRectsWithScrollView:scrollView];
        }
    }
    
}

- (void)segmentControlDidEndDecelerating:(UIScrollView *)scrollView{
    if(!self) return;
    _isChangeByClick = NO;
    int page = (int)scrollView.contentOffset.x/scrollView.frame.size.width;
    [self segmentDidSelectAtIndex:page didDeselectAtIndex:_selectedSegmentIndex ignoreAction:YES animation:NO];
}

- (void)segmentControlDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if(!self) return;
    _isChangeByClick = NO;
    int page = (int)scrollView.contentOffset.x/scrollView.frame.size.width;
    [self segmentDidSelectAtIndex:page
               didDeselectAtIndex:_selectedSegmentIndex
                     ignoreAction:YES
                        animation:NO];
}

- (void)adjustItems{
    for (int i = 0; i < _items.count; i++) {
        Item *item = _items[i];
        if (i == _selectedSegmentIndex) {
            NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[i]  attributes:self.attributesSelected];
            item.label.attributedText = mutableAttributed;
        }else{
            NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[i]  attributes:self.attributesNormal];
            item.label.attributedText = mutableAttributed;
        }
    }
}

- (void)segmentControlChangeBackgroundWithTargetColor:(UIColor *)targetColor{
    _targetColor = targetColor;
    for (Item *item in _items) {
        item.label.textColor = targetColor;
    }
    _indicator.backgroundColor = targetColor;
    //更新当前attr的颜色
    self.attributesSelected = [KFASegmentFactory changeAttributedColorWithAtt:self.attributesSelected color:targetColor];
    self.attributesNormal = [KFASegmentFactory changeAttributedColorWithAtt:self.attributesNormal color:targetColor];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex ignoreAction:(BOOL)ignoreAction{
    if (selectedSegmentIndex >= self.curTitles.count) {
        return;
    }
    [self segmentDidSelectAtIndex:selectedSegmentIndex didDeselectAtIndex:_selectedSegmentIndex ignoreAction:ignoreAction animation:YES];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animation:(BOOL)animation{
    _isChangeByClick = YES;
    if (selectedSegmentIndex >= self.curTitles.count) {
        return;
    }
    [self segmentDidSelectAtIndex:selectedSegmentIndex didDeselectAtIndex:_selectedSegmentIndex ignoreAction:YES animation:animation];
}

#pragma mark 动态添加
- (void)insertTitle:(NSString *)title atIndex:(NSUInteger)index {
    if (index > _curTitles.count) {
        return;
    }
    if (!title) {
        return;
    }
    NSMutableArray *curTitles = self.curTitles.mutableCopy;
    [curTitles insertObject:title atIndex:index];
    self.curTitles = curTitles.copy;
    //判断添加的位置和当前选中的位置
    if (index <= self.selectedSegmentIndex) {
        self.selectedSegmentIndex++;
    }
    [self reloadData];
}

- (void)replaceTitle:(NSString *)title atIndex:(NSUInteger)index{
    if (index > _curTitles.count) {
        return;
    }
    if (!title) {
        return;
    }
    NSMutableArray *curTitles = self.curTitles.mutableCopy;
    [curTitles replaceObjectAtIndex:index withObject:title];
    self.curTitles = curTitles.copy;
    [self reloadData];
}

- (void)removeTitleAtIndex:(NSUInteger)index {
    if (index >= _curTitles.count) {
        return;
    }
    
    NSMutableArray *curTitles = self.curTitles.mutableCopy;
    [curTitles removeObjectAtIndex:index];
    self.curTitles = curTitles.copy;
    [self reloadData];
}

#pragma mark 刷新数据
- (void)reloadData{
    //延迟调用，为了解决segment错乱问题
    self.userInteractionEnabled = NO;
    !self.isAnimation?:[_displayLink invalidate];
    !self.isAnimation? [self delayReloadData] : [self performSelector:@selector(delayReloadData) withObject:nil afterDelay:self.animationTimeout];
}

- (void)delayReloadData{
    [_container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_container removeFromSuperview];
    _container = nil;
    [_items removeAllObjects];
    [self setupViews];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.userInteractionEnabled = YES;
}

#pragma mark - Private
- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    _minFontSize = 16;
    _maxFontSize = 24;
    _selectedSegmentIndex = 0;
    _segmentEdgeInset = UIEdgeInsetsMake(0, 10, 5, 10);
    _indicatorContentOffset = UIEdgeInsetsMake(5, 12, 5, 12);
    _horizontalPadding = 24;
    _textAnimate = NO;
    _indicatorWidthStyle = KFASegmentedControlIndicatorWidthStyleText;
    _widthStyle = KFASegmentedControlWidthStyleDynamic;
    _showsIndicator = NO;
    _indicatorHeight = 6.0;
    _indicatorMinWidth = 24;
    _indicatorMaxWidth = 50;
    _indicatorMarginTop = 5;
    _showBottomShadow = NO;
    _textPosition = KFASegmentedControlTextPositionMiddle;
    _indicatorAnimation = YES;
    [self setupViews];
}

- (void)setupViews{
    [self addSubview:self.container];
    for (int i = 0; i < self.curTitles.count; i++) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
        
        KFASegmentControlItem *item = [[KFASegmentControlItem alloc] initWithView:label];
        //判断是否存在角标视图
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentControl:bageViewAtIndex:)]) {
            UIView *bageView = [self.dataSource segmentControl:self bageViewAtIndex:i];
            if (bageView) {
                bageView.tag = KFASegmentBageViewBaseTag + i;
                [item addSubview:bageView];
            }
        }
        [self.items addObject:item];
        [self.container addSubview:item];
    }
}

#pragma mark 计算title的Size
- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    if (index >= self.curTitles.count) {
        return CGSizeZero;
    }
    NSString *title = self.curTitles[index];
    BOOL selected = index == self.selectedSegmentIndex;
    NSDictionary *titleAttributes = selected ? self.attributesSelected : self.attributesNormal;
    return [KFASegmentFactory measureSizeWithTitle:title attributes:titleAttributes];
}

#pragma mark 更新整个scrollView的Rect
- (void)updateRectsWithScrollView:(UIScrollView *)scrollView{
    //获取当前的view和目标View
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollWidth = scrollView.frame.size.width;
    if (offsetX < 0) return;
    //获取当前index，和目标index
    int tempIndex = (offsetX / scrollWidth);
    if (fmod((double)offsetX,scrollWidth) == 0) return;
    if (tempIndex > _curTitles.count - 2) return;
    if (_items.count == 0 || tempIndex >= _items.count || tempIndex + 1 >= _items.count) return;
    UILabel *leftView = _items[tempIndex].label;
    UILabel *rightView = _items[tempIndex + 1].label;
    
    //获取左右Font的变化值
    float leftScaleValue = _maxFontSize - fmod((double)offsetX,scrollWidth) / scrollWidth * (_maxFontSize - _minFontSize);
    float rightScaleValue = _minFontSize + fmod((double)offsetX,scrollWidth) / scrollWidth * (_maxFontSize - _minFontSize);
    //获取scale和color渐变的具体值0~1
    float leftColorValue = fmod((double)offsetX,scrollWidth) / scrollWidth;
    //执行动画
    [self updateFontAndColorWithLeftLabel:leftView leftFontScale:leftScaleValue rightLabel:rightView rightFontScale:rightScaleValue colorScale:leftColorValue toIndex:tempIndex scrollToLeft:_selectedSegmentIndex <= tempIndex];
}
#pragma mark 更新当前的label
- (void)updateFontAndColorWithLeftLabel:(UILabel *)leftLabel
                          leftFontScale:(float)leftFontScale
                             rightLabel:(UILabel *)rightLabel
                         rightFontScale:(float)rightFontScale
                             colorScale:(float)colorScale
                                toIndex:(int)toIndex
                           scrollToLeft:(BOOL)scrollToLeft{
    //判断是否存在TargetColor
    UIColor *leftColor,*rightColor;
    if (!_targetColor) {
        //获取颜色的变化值
        UIColor *normalColor = [self.attributesNormal objectForKey:NSForegroundColorAttributeName];
        UIColor *selectColor = [self.attributesSelected objectForKey:NSForegroundColorAttributeName];
        CGFloat normalColorComponents[3];
        CGFloat selectColorComponents[3];
        [KFASegmentFactory getRGBComponents:normalColorComponents forColor:normalColor];
        [KFASegmentFactory getRGBComponents:selectColorComponents forColor:selectColor];
        
        //取出变化范围
        CGFloat rDis = selectColorComponents[0] - normalColorComponents[0];
        CGFloat gDis = selectColorComponents[1] - normalColorComponents[1];
        CGFloat bDis = selectColorComponents[2] - normalColorComponents[2];
        
        leftColor = [UIColor colorWithRed:selectColorComponents[0] - rDis * colorScale  green:selectColorComponents[1] - gDis * colorScale blue:selectColorComponents[2] - bDis * colorScale alpha:1];
        rightColor = [UIColor colorWithRed:normalColorComponents[0] + rDis * colorScale  green:normalColorComponents[1] + gDis * colorScale blue:normalColorComponents[2] + bDis * colorScale alpha:1];
    }else{
        leftColor = _targetColor;
        rightColor = _targetColor;
    }
    
    //判断当前label是否存在，并且是否有值
    if (leftLabel.text.length > 0 && rightLabel.text.length > 0) {
        //动态设置font和Color
        if (!scrollToLeft) {
            //从左向右滑动
            if (colorScale <= 0.6) {
                leftLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesSelected fontSize:leftFontScale color:leftColor text:leftLabel.text];
                rightLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesNormal fontSize:rightFontScale color:rightColor text:rightLabel.text];
            }else{
                leftLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesNormal fontSize:leftFontScale color:leftColor text:leftLabel.text];
                rightLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesSelected fontSize:rightFontScale color:rightColor text:rightLabel.text];
            }
        }else{
            //从右向左滑动
            if (colorScale > 0.4) {
                rightLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesSelected fontSize:rightFontScale color:rightColor text:rightLabel.text];
                leftLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesNormal fontSize:leftFontScale color:leftColor text:leftLabel.text];
            }else{
                rightLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesNormal fontSize:rightFontScale color:rightColor text:rightLabel.text];
                leftLabel.attributedText = [KFASegmentFactory changeFontSizeWithAttributes:self.attributesSelected fontSize:leftFontScale color:leftColor text:leftLabel.text];
            }
        }
        [leftLabel sizeToFit];
        [rightLabel sizeToFit];
        
        //调整坐标
        leftLabel.height = leftFontScale;
        leftLabel.superview.width = CGRectGetWidth(leftLabel.frame);
        leftLabel.bottom = leftLabel.superview.bottom - _titleBottomMargin;
        [self updateBageFrameAtIndex:toIndex];
        
        rightLabel.height = rightFontScale;
        rightLabel.superview.width = CGRectGetWidth(rightLabel.frame);
        rightLabel.bottom = rightLabel.superview.bottom - _titleBottomMargin;
        //调整所有View的x轴坐标
        UIView *tempView = leftLabel.superview;
        CGFloat totalW = 0;
        for (int i = toIndex + 1; i < _items.count; i++) {
            Item *item = _items[i];
            item.x = CGRectGetMaxX(tempView.frame) + _horizontalPadding;
            item.label.x = 0;
            item.label.bottom = item.bottom - _titleBottomMargin;
            tempView = item;
            if (i == _items.count - 1) {
                totalW = item.right + _segmentEdgeInset.right;
            }
            [self updateBageFrameAtIndex:i];
        }
        self.container.contentSize = CGSizeMake(totalW, CGRectGetHeight(self.bounds));
        //更新Indicator位置
        [self updateIndicatorWithLeftLabel:leftLabel rightLabel:rightLabel percent:colorScale scrollToLeft:scrollToLeft];
    }
}

#pragma mark 调整Indicator的位置
- (void)updateIndicatorWithLeftLabel:(UILabel *)leftLabel
                          rightLabel:(UILabel *)rightLabel
                             percent:(float)percent
                        scrollToLeft:(BOOL)scrollToLeft{
    //调整indicator的位置,前50%移动X，增加宽度。后50%，移动X，减小宽度
    CGFloat targetX = 0;
    CGFloat targetW = self.indicatorMinWidth;
    
    CGFloat leftX;
    CGFloat rightX;
    if (_indicatorWidthStyle == KFASegmentedControlIndicatorWidthStyleText) {
        CGFloat leftMaxW = [KFASegmentFactory measureSizeWithTitle:leftLabel.text attributes:self.attributesSelected].width;
        leftX = leftLabel.superview.x;
        CGFloat rightMaxW = [KFASegmentFactory measureSizeWithTitle:rightLabel.text attributes:self.attributesSelected].width;
        rightX = rightLabel.superview.right - rightMaxW;
        targetX = [KFASegmentFactory interpolationFrom:leftX to:rightX percent:percent];
        targetW = [KFASegmentFactory interpolationFrom:leftMaxW to:rightMaxW percent:percent];
    }else if(_indicatorWidthStyle == KFASegmentedControlIndicatorWidthStyleBackground){
        CGFloat leftMaxW = [KFASegmentFactory measureSizeWithTitle:leftLabel.text attributes:self.attributesSelected].width;
        CGRect leftTargetRect = [leftLabel.superview convertRect:leftLabel.frame toView:leftLabel.superview.superview];
        leftX = leftTargetRect.origin.x - _indicatorContentOffset.left;
        CGFloat rightMaxW = [KFASegmentFactory measureSizeWithTitle:rightLabel.text attributes:self.attributesSelected].width;
        CGRect rightTargetRect = [rightLabel.superview convertRect:rightLabel.frame toView:rightLabel.superview.superview];
        rightX = rightTargetRect.origin.x - _indicatorContentOffset.left;
        targetX = [KFASegmentFactory interpolationFrom:leftX to:rightX percent:percent];
        targetW = [KFASegmentFactory interpolationFrom:leftMaxW + _indicatorContentOffset.left + _indicatorContentOffset.right to:rightMaxW + _indicatorContentOffset.left + _indicatorContentOffset.right percent:percent];
    }else{
        CGFloat leftMaxW = [KFASegmentFactory measureSizeWithTitle:leftLabel.text attributes:self.attributesSelected].width;
        leftX = leftLabel.superview.x + (leftMaxW - self.indicatorMinWidth) / 2;
        CGFloat rightMaxW = [KFASegmentFactory measureSizeWithTitle:rightLabel.text attributes:self.attributesSelected].width;
        rightX = (rightLabel.superview.right - rightMaxW) + (rightMaxW - self.indicatorMinWidth) / 2;
        if (percent != 0) {
            CGFloat centerX = leftX + (rightX - leftX - self.indicatorMaxWidth) / 2;
            if (percent <= 0.5) {
                targetX = [KFASegmentFactory interpolationFrom:leftX to:centerX percent:percent * 2];
                targetW = [KFASegmentFactory interpolationFrom:self.indicatorMinWidth to:self.indicatorMaxWidth percent:percent * 2];
            }else{
                targetX = [KFASegmentFactory interpolationFrom:centerX to:rightX percent:(percent - 0.5) * 2];
                targetW = [KFASegmentFactory interpolationFrom:self.indicatorMaxWidth to:self.indicatorMinWidth percent:(percent - 0.5) * 2];
            }
        }
    }
    if (self.container.scrollEnabled || (!self.container.scrollEnabled && percent == 0)) {
        CGRect frame = self.indicator.frame;
        frame.origin.x = targetX;
        frame.size.width = targetW;
        self.indicator.frame = frame;
        if (_indicatorWidthStyle != KFASegmentedControlIndicatorWidthStyleBackground) {
            [_indicator kfa_setShadowPathWith:_indicator.backgroundColor shadowOpacity:KFAIndicatorShadowOpacity shadowRadius:KFAIndicatorShadowRadius shadowSide:KFAShadowPathBottom shadowPathWidth:KFAIndicatorShadowPathWidth];
        }
    }
}

- (void)scrollToSelectedSegmentIndex {
    CGRect rectForSelectedIndex = CGRectZero;
    CGFloat selectedSegmentOffset = 0;
    
    Item *selectItem = _items[_selectedSegmentIndex];
    rectForSelectedIndex = selectItem.frame;
    selectedSegmentOffset = CGRectGetWidth(self.frame) / 2 - selectItem.width / 2;
    
    CGRect rectToScrollTo = rectForSelectedIndex;
    rectToScrollTo.origin.x -= selectedSegmentOffset;
    rectToScrollTo.size.width += selectedSegmentOffset * 2;
    [self.container scrollRectToVisible:rectToScrollTo animated:YES];
}

- (void)segmentDidSelectAtIndex:(NSUInteger)newIndex didDeselectAtIndex:(NSUInteger)oldIndex ignoreAction:(BOOL)ignoreAction animation:(BOOL)animation{
    _selectIndexAnimation = animation;
    if(!self) return;
    if (newIndex >= _items.count) return;
    if (oldIndex >= _items.count) return;
    _selectedSegmentIndex = newIndex;
    if (!ignoreAction) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    if (newIndex == oldIndex) {
        return;
    }
    // update UI
    if (!_textAnimate) {
        //更新frame
        [self updateFrame];
    }else{
        if (!animation) {
            [self updateFrame];
        }
    }
    if (self.textAnimate && animation) {
        if (_widthStyle == KFASegmentedControlWidthStyleDynamic) {
            [self textAnimationFromIndex:oldIndex toIndex:newIndex];
        }else{
            if (!_targetColor) {
                UILabel *selectedLabel = _items[newIndex].label;
                NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[newIndex]  attributes:_attributesSelected];
                selectedLabel.attributedText = mutableAttributed;
                
                UILabel *deselectedLabel = _items[oldIndex].label;
                NSMutableAttributedString *deselectedMutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[oldIndex]  attributes:_attributesNormal];
                deselectedLabel.attributedText = deselectedMutableAttributed;
            }
            [self moveIndicatorFromIndex:oldIndex toIndex:newIndex];
        }
    }else{
        if (!_targetColor) {
            UILabel *selectedLabel = _items[newIndex].label;
            NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[newIndex]  attributes:_attributesSelected];
            selectedLabel.attributedText = mutableAttributed;
            
            UILabel *deselectedLabel = _items[oldIndex].label;
            NSMutableAttributedString *deselectedMutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[oldIndex]  attributes:_attributesNormal];
            deselectedLabel.attributedText = deselectedMutableAttributed;
        }
        
        [self moveIndicatorFromIndex:oldIndex toIndex:newIndex];
        
        [self scrollToSelectedSegmentIndex];
    }
    
}

- (void)updateFrame{
    //获取普通状态下文字高度
    UIFont *font = self.attributesNormal[NSFontAttributeName];
    _titleBottomMargin = _textPosition == KFASegmentedControlTextPositionMiddle ? (self.height - font.pointSize) / 2 : _segmentEdgeInset.bottom;
    __block CGFloat xoffset = _segmentEdgeInset.left;
    __block CGFloat totalW = 0;
    __block CGRect targetRect = CGRectZero;
    [self.curTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGSize textSize = [self measureTitleAtIndex:idx];
        CGFloat width = textSize.width;
        CGFloat height = textSize.height;
        
        //获取宽度
        Item *item = [self.items objectAtIndex:idx];
        item.label.layer.anchorPoint = CGPointMake(0, 1);
        CGFloat labelY = self.height - height - self->_titleBottomMargin;
        if (idx == 0) {
            if (self.widthStyle == KFASegmentedControlWidthStyleDynamic) {
                item.frame = CGRectMake(xoffset, 0, width, self.height);
                item.label.frame = CGRectMake(0, labelY, width, height);
            }else{
                CGFloat itemW = MAX(CGRectGetWidth(self.bounds) / self.curTitles.count, KFASegmentWidthMinmum);
                item.frame = CGRectMake(0, 0, itemW, self.height);
                item.label.textAlignment = NSTextAlignmentCenter;
                item.label.frame = CGRectMake((item.width - width) / 2,labelY , width, height);
            }
            self.selectOriginRect = item.label.frame;
            targetRect = item.frame;
        }else{
            if (self.widthStyle == KFASegmentedControlWidthStyleDynamic) {
                item.frame = CGRectMake(CGRectGetMaxX(targetRect) + self.horizontalPadding, 0, width, self.height);
                item.label.frame = CGRectMake(0, labelY, width, height);
            }else{
                CGFloat itemW = MAX(CGRectGetWidth(self.bounds) / self.curTitles.count, KFASegmentWidthMinmum);
                item.frame = CGRectMake(CGRectGetMaxX(targetRect), 0, itemW, self.height);
                item.label.textAlignment = NSTextAlignmentCenter;
                item.label.frame = CGRectMake((item.width - width) / 2,labelY, width, height);
            }
            targetRect = item.frame;
        }
        totalW = CGRectGetMaxX(targetRect);
    }];
    CGFloat contentSizeW = _widthStyle == KFASegmentedControlWidthStyleDynamic ? totalW + _segmentEdgeInset.right : self.width;
    self.container.contentSize = CGSizeMake(contentSizeW, self.height);
}

/** 更新角标的frame */
- (void)updateBageFrame{
    for (int i = 0; i < self.curTitles.count; i++) {
        [self updateBageFrameAtIndex:i];
    }
}

- (void)updateBageFrameAtIndex:(NSInteger)index{
    Item *item = [self.items objectAtIndex:index];
    UIView *bageView = [item viewWithTag:KFASegmentBageViewBaseTag + index];
    if (bageView) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, KFASegmentBageViewLeftOffset, KFASegmentBageViewBottomOffset, 0);
        CGPoint position = CGPointMake(1, 0);
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentControl:bagePointAtIndex:)]) {
            position = [self.dataSource segmentControl:self bagePointAtIndex:index];
            if (position.x < 0) position.x = 0;
            if (position.x > 1) position.x = 1;
            if (position.y < 0) position.y = 0;
            if (position.y > 1) position.y = 1;
        }
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(segmentControl:edgeInsetsAtIndex:)]) {
            insets = [self.dataSource segmentControl:self edgeInsetsAtIndex:index];
        }
        bageView.x = item.label.x + item.label.width * position.x - insets.left;
        bageView.y = item.label.y + item.label.height * position.y - bageView.height + insets.bottom;
    }
}

#pragma mark 更新阴影
- (void)updateShadow{
    //是否展示底部shadow
    if (_showBottomShadow) {
        self.backgroundColor = [UIColor whiteColor];
        [self kfa_setShadowPathWith:_targetColor ? [UIColor clearColor] : [UIColor blackColor] shadowOpacity:KFASegmentShadowOpacity shadowRadius:KFASegmentShadowRadius shadowSide:KFAShadowPathBottom shadowPathWidth:KFASegmentShadowPathWidth];
    }else{
        self.backgroundColor = [UIColor clearColor];
        [self kfa_setShadowPathWith:[UIColor blackColor] shadowOpacity:0 shadowRadius:0 shadowSide:KFAShadowPathBottom shadowPathWidth:0];
    }
    //添加阴影
    if (_indicatorWidthStyle != KFASegmentedControlIndicatorWidthStyleBackground) {
        [_indicator kfa_setShadowPathWith:_indicatorBackgroundColor shadowOpacity:KFAIndicatorShadowOpacity shadowRadius:KFAIndicatorShadowRadius shadowSide:KFAShadowPathBottom shadowPathWidth:KFAIndicatorShadowPathWidth];
    }
}

#pragma mark Indicator
- (void)updateIndicatorFrame{
    // indicator
    if (!_indicator) {
        return;
    }
    self.indicator.frame = [self indicatorFrame];
    self.indicator.layer.cornerRadius = self.indicator.height / 2;
    
    if (self.indicator.superview == nil && self.showsIndicator) {
        [self.container addSubview:self.indicator];
        [self.container sendSubviewToBack:_indicator];
    }
}
/** 计算当前indicator的Frame */
- (CGRect)indicatorFrame{
    return [self indicatorFrameFromIndex:_selectedSegmentIndex toIndex:_selectedSegmentIndex];
}

- (CGRect)indicatorFrameFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (toIndex >= self.items.count || !self.items) return CGRectZero;
    BOOL isToRight = fromIndex < toIndex;
    CGFloat x = 0, y = 0, width = 0;
    CGFloat height = self.indicatorHeight;
    Item *item = self.items[toIndex];
    CGSize itemMinSize = item.size;
    CGSize itemSize = [self measureTitleAtIndex:toIndex];
    //获取indicator偏移量
    CGFloat offset = _widthStyle == KFASegmentedControlWidthStyleDynamic ? (itemSize.width - itemMinSize.width) * 0.5 : 0;
    if (self.indicatorWidthStyle == KFASegmentedControlIndicatorWidthStyleShort) {
        width = _indicatorMinWidth;
        x = item.center.x - width * 0.5 - (isToRight ? offset : -offset);
        y = item.label.bottom + self.indicatorMarginTop;
    }else if(self.indicatorWidthStyle == KFASegmentedControlIndicatorWidthStyleText){
        width = itemSize.width;
        x = item.center.x - width * 0.5;
        y = item.label.bottom + self.indicatorMarginTop;
    }else{
        width = itemSize.width + _indicatorContentOffset.left + _indicatorContentOffset.right;
        height = itemSize.height + _indicatorContentOffset.top +    _indicatorContentOffset.bottom;
        CGRect targetRect = [item convertRect:item.label.frame toView:item.superview];
        x = targetRect.origin.x - _indicatorContentOffset.left;
        y = targetRect.origin.y - _indicatorContentOffset.top;
    }
    return (CGRect){x, y, width, height};
}

- (void)moveIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    CGRect frame = [self indicatorFrameFromIndex:fromIndex toIndex:toIndex];
    if (_indicatorAnimation && _selectIndexAnimation) {
        // indicator animate
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.66
              initialSpringVelocity:3.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.indicator.frame = frame;
                             if (self->_indicatorWidthStyle != KFASegmentedControlIndicatorWidthStyleBackground) {
                                 [self.indicator kfa_setShadowPathWith:self.indicator.backgroundColor shadowOpacity:KFAIndicatorShadowOpacity shadowRadius:KFAIndicatorShadowRadius shadowSide:KFAShadowPathBottom shadowPathWidth:KFAIndicatorShadowPathWidth];
                             }
                         } completion:^(BOOL finished) {
                         }];
    }else{
        self.indicator.frame = frame;
    }
}


- (void)textAnimationFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    self.fromIndex = fromIndex;
    self.toIndex = toIndex;
    if (_displayLink) {
        [_displayLink invalidate];
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(dis_textAnimation)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)dis_textAnimation{
    if (!self) return;
    __block UILabel *leftLabel = _toIndex > _fromIndex ? self.items[_fromIndex].label : self.items[_toIndex].label;
    __block UILabel *rightLabel = _toIndex > _fromIndex ? self.items[_toIndex].label : self.items[_fromIndex].label;
    int index = _toIndex > _fromIndex ? (int)_fromIndex : (int)_toIndex;
    
    self.isAnimation = YES;
    self.userInteractionEnabled = NO;
    
    NSTimeInterval duration = 0.15;
    self.timeout += duration / 20;
    self.animationTimeout = duration - self.timeout;
    NSTimeInterval tempTime = _toIndex > _fromIndex ? self.timeout : (duration - self.timeout);
    float leftScaleValue = self.maxFontSize - (self.maxFontSize - self.minFontSize) / duration * tempTime;
    float rightScaleValue = self.minFontSize + (self.maxFontSize - self.minFontSize) / duration * tempTime;
    float leftColorValue = _toIndex < _fromIndex ? (1 - self.timeout / duration) : self.timeout / duration;
    //根据偏移量来设置动画
    [self updateFontAndColorWithLeftLabel:leftLabel leftFontScale:leftScaleValue rightLabel:rightLabel rightFontScale:rightScaleValue colorScale:leftColorValue toIndex:index scrollToLeft:_toIndex > _fromIndex];
    if (self.timeout >= duration) {
        self.timeout = 0;
        [_displayLink invalidate];
        _displayLink = nil;
        self.isChangeByClick = NO;
        self.isAnimation = NO;
        self.userInteractionEnabled = YES;
        [self scrollToSelectedSegmentIndex];
    }
}

#pragma mark - 更新背景色和字体颜色
- (void)updateSelectIndexAttribute{
    if (_selectedSegmentIndex > 0) {
        [self segmentDidSelectAtIndex:_selectedSegmentIndex didDeselectAtIndex:0 ignoreAction:NO animation:NO];
    }
    for (int i = 0; i < _items.count; i++) {
        Item *item = _items[i];
        if (i == _selectedSegmentIndex) {
            NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[i]  attributes:self.attributesSelected];
            item.label.attributedText = mutableAttributed;
        }else{
            NSMutableAttributedString *mutableAttributed = [[NSMutableAttributedString alloc] initWithString:_curTitles[i]  attributes:self.attributesNormal];
            item.label.attributedText = mutableAttributed;
        }
    }
}

#pragma mark - EventResponse
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touches.anyObject locationInView:self];
    _isChangeByClick = YES;
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        NSInteger toIndex = 0;
        CGFloat widthLeft = touchLocation.x + self.container.contentOffset.x;
        for (Item *item in _items) {
            if (item.x <= widthLeft && CGRectGetMaxX(item.frame) >= widthLeft) {
                break;
            }
            toIndex++;
        }
        if (toIndex != NSNotFound && toIndex < self.items.count) {
            if (_selectedSegmentIndex != toIndex) {
                [self segmentDidSelectAtIndex:toIndex didDeselectAtIndex:_selectedSegmentIndex ignoreAction:NO animation:YES];
            } else {
                ///图库所用segment点击后value没有变化也需要触发事件才能实现功能
                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentControlDidEndScroll:isDragging:)]) {
        [self.delegate segmentControlDidEndScroll:self isDragging:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentControlViewWillBeginDragging:)]) {
        [self.delegate segmentControlViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentControlDidEndScroll:isDragging:)]) {
            [self.delegate segmentControlDidEndScroll:self isDragging:YES];
        }
    }
}

#pragma mark - Lazy
- (KFASegmentScrollView *)container{
    if (!_container) {
        _container = [[KFASegmentScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        _container.clipsToBounds = NO;
        _container.scrollsToTop = NO;
        _container.showsVerticalScrollIndicator = NO;
        _container.showsHorizontalScrollIndicator = NO;
        _container.translatesAutoresizingMaskIntoConstraints = NO;
        _container.delegate = self;
    }
    return _container;
}

- (CGFloat)segmentTotalWidth{
    if (self.titles.count <= 0) return 0;
    //获取当前最长的title宽度
    CGFloat minW = 0;
    CGFloat maxW = 0;
    CGFloat totalW = 0;
    for (int i = 0; i < self.titles.count; i++) {
        NSString *title = self.titles[i];
        CGSize maxSize = [KFASegmentFactory measureSizeWithTitle:title attributes:self.attributesSelected];
        CGSize minSize = [KFASegmentFactory measureSizeWithTitle:title attributes:self.attributesNormal];
        if (maxW < maxSize.width) {
            minW = minSize.width;
            maxW = maxSize.width;
        }
        totalW += minSize.width;
    }
    totalW = totalW - minW + maxW + (_segmentEdgeInset.left + _segmentEdgeInset.right) * 2 + _horizontalPadding * (self.titles.count - 1);
    return totalW;
}

- (void)setShowBottomShadow:(BOOL)showBottomShadow{
    if (_showBottomShadow == showBottomShadow) return;
    _showBottomShadow = showBottomShadow;
    if (_showBottomShadow) {
        self.backgroundColor = _targetColor ? [UIColor clearColor] : [UIColor whiteColor];
        [self kfa_setShadowPathWith:[UIColor blackColor] shadowOpacity:KFASegmentShadowOpacity shadowRadius:KFASegmentShadowRadius shadowSide:KFAShadowPathBottom shadowPathWidth:KFASegmentShadowPathWidth];
    }else{
        self.backgroundColor = [UIColor clearColor];
        [self kfa_setShadowPathWith:[UIColor whiteColor] shadowOpacity:0 shadowRadius:0 shadowSide:KFAShadowPathBottom shadowPathWidth:0];
    }
}

- (void)setShowsIndicator:(BOOL)showsIndicator {
    
    if (_showsIndicator != showsIndicator) {
        _showsIndicator = showsIndicator;
        // setup indicator
        if (showsIndicator) {
            _indicator = ({
                UIView *indicator = [UIView new];
                indicator.backgroundColor = _indicatorBackgroundColor ? _indicatorBackgroundColor : [UIColor blackColor];
                [self.container addSubview:indicator];
                indicator;
            });
            [self.container sendSubviewToBack:_indicator];
            [self updateIndicatorFrame];
        } else {
            if (_indicator) {
                [_indicator removeFromSuperview];
                _indicator = nil;
            }
        }
    }
}

- (void)setIndicatorBackgroundColor:(UIColor *)indicatorBackgroundColor {
    _indicatorBackgroundColor = indicatorBackgroundColor;
    self.indicator.backgroundColor = indicatorBackgroundColor;
}
- (void)setIndicatorWidthStyle:(KFASegmentedControlIndicatorWidthStyle)indicatorWidthStyle {
    _indicatorWidthStyle = indicatorWidthStyle;
    [self updateIndicatorFrame];
}

- (NSArray *)titles{
    return self.curTitles;
}

- (void)setTitles:(NSArray *)titles{
    self.curTitles = titles.copy;
}

- (NSMutableArray *)items{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end
