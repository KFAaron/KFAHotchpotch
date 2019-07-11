//
//  KFAMagnifierView.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KFAMagnifierView : UIView

@property (nonatomic,weak) UIView *readView;
@property (nonatomic) CGPoint touchPoint;

@end

