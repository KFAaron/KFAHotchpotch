//
//  KFAMan.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/6/12.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMan.h"

@implementation KFAMan

+ (void)load {
    NSLog(@"Class：%@, func：%s, line：%d",NSStringFromClass([self class]), __func__, __LINE__);
}

+ (void)initialize {
    NSLog(@"Class：%@, func：%s, line：%d",NSStringFromClass([self class]), __func__, __LINE__);
}

- (void)work {
    NSLog(@"Class：%@, func：%s, line：%d",NSStringFromClass([self class]), __func__, __LINE__);
}

@end
