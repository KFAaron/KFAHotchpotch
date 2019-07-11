//
//  KFAMarkModel.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFARecordModel;

NS_ASSUME_NONNULL_BEGIN

@interface KFAMarkModel : NSObject <NSCoding>

@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) KFARecordModel *recordModel;

@end

NS_ASSUME_NONNULL_END
