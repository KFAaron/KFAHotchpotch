//
//  KFAReadView.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFAReadViewControllerDelegate;

@interface KFAReadView : UIView

@property (nonatomic,assign) CTFrameRef frameRef;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSArray *imageArray;

// 这里必须用strong 用weak会造成提前释放，导致崩溃
//@property (nonatomic,strong) id<KFAReadViewControllerDelegate>delegate;
@property (nonatomic,weak) id<KFAReadViewControllerDelegate>delegate;

- (void)cancelSelected;

@end

