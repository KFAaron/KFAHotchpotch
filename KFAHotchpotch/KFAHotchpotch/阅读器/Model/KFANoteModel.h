//
//  KFANoteModel.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFARecordModel;

NS_ASSUME_NONNULL_BEGIN

@interface KFANoteModel : NSObject <NSCoding>

@property (nonatomic,strong) NSDate *date;
@property (nonatomic,copy) NSString *note;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,strong) KFARecordModel *recordModel;

@end

NS_ASSUME_NONNULL_END
