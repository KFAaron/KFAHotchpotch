//
//  KFAMacro.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/9.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#ifndef KFAMacro_h
#define KFAMacro_h

// 屏宽高
#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)

#ifdef DEBUG
#define KFALog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define KFALog(format, ...)
#endif

#ifdef DEBUG
# define KFADetailLog(fmt, ...) NSLog((@"文件名:%s\n" "函数名:%s\n" "行号:%d \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define KFADetailLog(...);
#endif

#endif /* KFAMacro_h */
