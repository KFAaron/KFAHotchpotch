//
//  KFAChainedMD.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/5/23.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAChainedMD.h"

@interface KFAChainedMD ()

@property (nonatomic, copy) NSString *mName;
@property (nonatomic, assign) NSUInteger mAge;

@end

@implementation KFAChainedMD

- (KFAChainedMD *(^)(NSString *))name {
    return ^(NSString *nm) {
        self.mName = nm;
        return self;
    };
}

- (KFAChainedMD *(^)(NSUInteger))age {
    return ^(NSUInteger ag) {
        self.mAge = ag;
        return self;
    };
}

- (KFAChainedMD *(^)(NSString *))eat {
    return ^(NSString *fd) {
        NSLog(@"%ld岁的%@在吃%@",self.mAge,self.mName,fd);
        return self;
    };
}

- (KFAChainedMD *(^)(NSString *))sing {
    return ^(NSString *sg) {
        NSLog(@"%ld岁的%@在唱%@",self.mAge,self.mName,sg);
        return self;
    };
}

- (KFAChainedMD *)changeName:(NSString *(^)(NSString *))changeNameBlock {
    if (changeNameBlock) {
        self.mName = changeNameBlock(self.mName);
    }
    return self;
}

- (BOOL)isAaron:(BOOL (^)(NSString *))judge {
    if (judge) {
        return judge(self.mName);
    }
    return NO;
}

@end
