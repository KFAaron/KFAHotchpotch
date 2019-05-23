//
//  KFAChainedMD.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/5/23.
//  Copyright © 2019 KFAaron. All rights reserved.
//
// 函数式编程 支持链式调用

#import <Foundation/Foundation.h>

@interface KFAChainedMD : NSObject

@property (nonatomic, copy, readonly) KFAChainedMD * (^name)(NSString *name);
@property (nonatomic, copy, readonly) KFAChainedMD * (^age)(NSUInteger age);

// 如果返回值不用block，链式调用则报Property access result unused - getters should not be used for side effects
- (KFAChainedMD *(^)(NSString *food))eat;
- (KFAChainedMD *(^)(NSString *song))sing;

- (KFAChainedMD *)changeName:(NSString *(^)(NSString *oldName))changeNameBlock;
- (BOOL)isAaron:(BOOL(^)(NSString *name))judge;

@end

