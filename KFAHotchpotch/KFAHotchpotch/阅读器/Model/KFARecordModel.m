//
//  KFARecordModel.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFARecordModel.h"
#import "KFAChapterModel.h"

@implementation KFARecordModel

- (id)copyWithZone:(NSZone *)zone {
    KFARecordModel *recordModel = [[KFARecordModel allocWithZone:zone]init];
    recordModel.chapterModel = [self.chapterModel copy];
    recordModel.page = self.page;
    recordModel.chapter = self.chapter;
    return recordModel;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.chapterModel forKey:@"chapterModel"];
    [aCoder encodeInteger:self.page forKey:@"page"];
    [aCoder encodeInteger:self.chapter forKey:@"chapter"];
    [aCoder encodeInteger:self.chapterCount forKey:@"chapterCount"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.chapterModel = [aDecoder decodeObjectForKey:@"chapterModel"];
        self.page = [aDecoder decodeIntegerForKey:@"page"];
        self.chapter = [aDecoder decodeIntegerForKey:@"chapter"];
        self.chapterCount = [aDecoder decodeIntegerForKey:@"chapterCount"];
    }
    return self;
}

@end
