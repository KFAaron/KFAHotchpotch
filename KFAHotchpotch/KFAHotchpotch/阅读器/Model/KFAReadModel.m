//
//  KFAReadModel.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAReadModel.h"
#import "KFAChapterModel.h"
#import "KFARecordModel.h"
#import "KFANoteModel.h"
#import "KFAMarkModel.h"

@implementation KFAReadModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.marks forKey:@"marks"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
    [aCoder encodeObject:self.chapters forKey:@"chapters"];
    [aCoder encodeObject:self.record forKey:@"record"];
    [aCoder encodeObject:self.resource forKey:@"resource"];
    [aCoder encodeObject:self.marksRecord forKey:@"marksRecord"];
    [aCoder encodeObject:@(self.type) forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.marks = [aDecoder decodeObjectForKey:@"marks"];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
        self.chapters = [aDecoder decodeObjectForKey:@"chapters"];
        self.record = [aDecoder decodeObjectForKey:@"record"];
        self.resource = [aDecoder decodeObjectForKey:@"resource"];
        self.marksRecord = [aDecoder decodeObjectForKey:@"marksRecord"];
        self.type = [[aDecoder decodeObjectForKey:@"type"] integerValue];
    }
    return self;
}

- (instancetype)initWithContent:(NSString *)content {
    if (self = [super init]) {
        _content = content;
        NSMutableArray *charpter = [NSMutableArray array];
        [KFAReadUtilites separateChapter:&charpter content:content];
        _chapters = charpter;
        _notes = [NSMutableArray array];
        _marks = [NSMutableArray array];
        _record = [[KFARecordModel alloc] init];
        _record.chapterModel = charpter.firstObject;
        _record.chapterCount = _chapters.count;
        _marksRecord = [NSMutableDictionary dictionary];
        _type = KFAReaderTypeTxt;
    }
    return self;
}

- (instancetype)initWithePub:(NSString *)ePubPath {
    if (self = [super init]) {
        _chapters = [KFAReadUtilites ePubFileHandle:ePubPath];
        _notes = [NSMutableArray array];
        _marks = [NSMutableArray array];
        _record = [[KFARecordModel alloc] init];
        _record.chapterModel = _chapters.firstObject;
        _record.chapterCount = _chapters.count;
        _marksRecord = [NSMutableDictionary dictionary];
        _type = KFAReaderTypeEpub;
    }
    return self;
}

+ (void)updateLocalModel:(KFAReadModel *)readModel url:(NSURL *)url {
    
    NSString *key = [url.path lastPathComponent];
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:readModel forKey:key];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

+ (id)getLocalModelWithURL:(NSURL *)url {
    NSString *key = [url.path lastPathComponent];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!data) {
        if ([[key pathExtension] isEqualToString:@"txt"]) {
            KFAReadModel *model = [[KFAReadModel alloc] initWithContent:[KFAReadUtilites encodeWithURL:url]];
            model.resource = url;
            [KFAReadModel updateLocalModel:model url:url];
            return model;
        } else if ([[key pathExtension] isEqualToString:@"epub"]){
            NSLog(@"this is epub");
            KFAReadModel *model = [[KFAReadModel alloc] initWithePub:url.path];
            model.resource = url;
            [KFAReadModel updateLocalModel:model url:url];
            return model;
        } else {
            @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
        }
    }
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    //主线程操作
    KFAReadModel *model = [unarchive decodeObjectForKey:key];
    return model;
}

@end
