//
//  KFATopMenuView.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFAMenuViewDelegate;

@interface KFATopMenuView : UIView

@property (nonatomic,assign) BOOL state; //(0--未保存过，1-－保存过)
@property (nonatomic,weak) id<KFAMenuViewDelegate>delegate;

@end


