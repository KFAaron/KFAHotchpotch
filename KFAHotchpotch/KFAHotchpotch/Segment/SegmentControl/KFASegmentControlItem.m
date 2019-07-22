//
//  KFASegmentControlItem.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFASegmentControlItem.h"

@implementation KFASegmentControlItem

- (instancetype)initWithView:(UIView *)view{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        [self addSubview:view];
        if ([view isKindOfClass:[UILabel class]]) {
            _label = (UILabel *)view;
        }
    }
    return self;
}

@end
