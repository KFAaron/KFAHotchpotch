//
//  KFAMarkModel.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMarkModel.h"
#import "KFARecordModel.h"

@implementation KFAMarkModel 

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.recordModel forKey:@"recordModel"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.recordModel = [aDecoder decodeObjectForKey:@"recordModel"];
    }
    return self;
}

@end
