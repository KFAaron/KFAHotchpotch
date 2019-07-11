//
//  KFAReadModel.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFAChapterModel, KFARecordModel, KFANoteModel, KFAMarkModel;

@interface KFAReadModel : NSObject <NSCoding>

@property (nonatomic,strong) NSURL *resource;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,assign) KFAReaderType type;
@property (nonatomic,strong) NSMutableArray <KFAMarkModel *>*marks;
@property (nonatomic,strong) NSMutableArray <KFANoteModel *>*notes;
@property (nonatomic,strong) NSMutableArray <KFAChapterModel *>*chapters;
@property (nonatomic,strong) NSMutableDictionary *marksRecord;
@property (nonatomic,strong) KFARecordModel *record;

- (instancetype)initWithContent:(NSString *)content;
- (instancetype)initWithePub:(NSString *)ePubPath;
+ (void)updateLocalModel:(KFAReadModel *)readModel url:(NSURL *)url;
+ (id)getLocalModelWithURL:(NSURL *)url;

@end

