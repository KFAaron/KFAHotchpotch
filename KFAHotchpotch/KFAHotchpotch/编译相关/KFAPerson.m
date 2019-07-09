//
//  KFAPerson.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/6/12.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAPerson.h"

@implementation KFAPerson

+ (void)load {
    KFALog(@"Class：%@, func：%s, line：%d",NSStringFromClass([self class]), __func__, __LINE__);
}

+ (void)initialize {
    KFALog(@"Class：%@, func：%s, line：%d",NSStringFromClass([self class]), __func__, __LINE__);
}

@end
