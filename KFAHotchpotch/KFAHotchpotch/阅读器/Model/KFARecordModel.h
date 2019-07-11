//
//  KFARecordModel.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFAChapterModel;

NS_ASSUME_NONNULL_BEGIN

@interface KFARecordModel : NSObject <NSCopying,NSCoding>

@property (nonatomic,strong) KFAChapterModel *chapterModel;  //阅读的章节
@property (nonatomic) NSUInteger page;  //阅读的页数
@property (nonatomic) NSUInteger chapter;    //阅读的章节数
@property (nonatomic) NSUInteger chapterCount;  //总章节数

@end

NS_ASSUME_NONNULL_END
