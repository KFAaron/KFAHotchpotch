//
//  KFAReadConfig.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFAReadConfig : NSObject<NSCoding>

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat lineSpace;
@property (nonatomic,strong) UIColor *fontColor;
@property (nonatomic,strong) UIColor *theme;

+ (KFAReadConfig *)shareInstance;

@end

NS_ASSUME_NONNULL_END
