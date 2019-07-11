//
//  KFAReadParser.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KFAReadConfig.h"

@interface KFAReadParser : NSObject

+ (CTFrameRef)parserContent:(NSString *)content config:(KFAReadConfig *)parser bouds:(CGRect)bounds;
+ (NSDictionary *)parserAttribute:(KFAReadConfig *)config;
//根据触碰点获取当前文字的索引
+ (CFIndex)parserIndexWithPoint:(CGPoint)point frameRef:(CTFrameRef)frameRef;
/**
 *  根据触碰点获取默认选中区域
 *  @range 选中范围
 *  @return 选中区域
 */
+ (CGRect)parserRectWithPoint:(CGPoint)point range:(NSRange *)selectRange frameRef:(CTFrameRef)frameRef;
/**
 *  根据触碰点获取默认选中区域
 *  @range 选中范围
 *  @return 选中区域的集合
 */
+ (NSArray *)parserRectsWithPoint:(CGPoint)point range:(NSRange *)selectRange frameRef:(CTFrameRef)frameRef paths:(NSArray *)paths;
/**
 *  根据触碰点获取默认选中区域
 *  @range 选中范围
 *  @return 选中区域的集合
 *  @direction 滑动方向 (0 -- 从左侧滑动 1-- 从右侧滑动)
 */
+ (NSArray *)parserRectsWithPoint:(CGPoint)point range:(NSRange *)selectRange frameRef:(CTFrameRef)frameRef paths:(NSArray *)paths direction:(BOOL) direction;

/**
 转换epub文件成CTFrameRef对象
 
 @param content epub文件处理后的内容
 @param parser 字体属性
 @param bounds 渲染区间
 */
+ (CTFrameRef)parserEpub:(NSArray *)content config:(KFAReadConfig *)parser bounds:(CGRect)bounds;
+ (NSAttributedString *)parserEpubAttribute:(NSArray *)content config:(KFAReadConfig *)parser bounds:(CGRect)bounds;

/**
 解析图片属性
 
 */
+ (NSAttributedString *)parserEpubImageWithSize:(NSDictionary *)dic config:(KFAReadConfig *)config;

@end

