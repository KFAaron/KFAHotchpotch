//
//  KFABottomMenuView.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFARecordModel;

@protocol KFAMenuViewDelegate;

@interface KFABottomMenuView : UIView

@property (nonatomic,weak) id<KFAMenuViewDelegate>delegate;
@property (nonatomic,strong) KFARecordModel *readModel;

@end

@interface KFAThemeView : UIView

@end

@interface KFAReadProgressView : UIView

-(void)title:(NSString *)title progress:(NSString *)progress;

@end
