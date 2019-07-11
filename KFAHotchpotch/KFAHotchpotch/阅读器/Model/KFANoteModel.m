//
//  KFANoteModel.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFANoteModel.h"
#import "KFARecordModel.h"

@implementation KFANoteModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.note forKey:@"note"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.recordModel forKey:@"recordModel"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.note = [aDecoder decodeObjectForKey:@"note"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.recordModel = [aDecoder decodeObjectForKey:@"recordModel"];
    }
    return self;
}

@end
