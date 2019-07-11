//
//  KFAReadUtilites.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KFAReadUtilites : NSObject

+ (void)separateChapter:(NSMutableArray **)chapters content:(NSString *)content;
+ (NSString *)encodeWithURL:(NSURL *)url;
+ (UIButton *)commonButtonSEL:(SEL)sel target:(id)target;
+ (UIViewController *)getCurrentVC;
+ (void)showAlertTitle:(NSString *)title content:(NSString *)string;
/**
 * ePub格式处理
 * 返回章节信息数组
 */
+ (NSMutableArray *)ePubFileHandle:(NSString *)path;

@end

