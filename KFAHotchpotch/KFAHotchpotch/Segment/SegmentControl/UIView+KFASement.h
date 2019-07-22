//
//  UIView+KFASement.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum :NSInteger{
    KFAShadowPathLeft,
    KFAShadowPathRight,
    KFAShadowPathTop,
    KFAShadowPathBottom,
    KFAShadowPathNoTop,
    KFAShadowPathAllSide
} KFAShadowPathSide;

@interface UIView (KFASement)

- (CGPoint)origin;
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)right;
- (CGFloat)bottom;

- (CGSize)size;
- (CGFloat)height;
- (CGFloat)width;

- (void)setBottom:(CGFloat)bottom;
- (void)setSize:(CGSize)size;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

- (void)setOrigin:(CGPoint)origin;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

- (void)setAnchorPoint:(CGPoint)anchorPoint;
- (void)setPosition:(CGPoint)point atAnchorPoint:(CGPoint)anchorPoint;

/*
 * shadowColor 阴影颜色
 * shadowOpacity 阴影透明度，默认0
 * shadowRadius  阴影半径，默认3
 * shadowPathSide 设置哪一侧的阴影，
 * shadowPathWidth 阴影的宽度，
 */
- (void)kfa_setShadowPathWith:(UIColor *)shadowColor
                shadowOpacity:(CGFloat)shadowOpacity
                 shadowRadius:(CGFloat)shadowRadius
                   shadowSide:(KFAShadowPathSide)shadowPathSide
              shadowPathWidth:(CGFloat)shadowPathWidth;

@end


