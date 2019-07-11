//
//  KFAMenuView.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFAMenuView, KFABottomMenuView, KFARecordModel, KFATopMenuView;

@protocol KFAMenuViewDelegate <NSObject>

@optional
-(void)menuViewDidHidden:(KFAMenuView *)menu;
-(void)menuViewDidAppear:(KFAMenuView *)menu;
-(void)menuViewInvokeCatalog:(KFABottomMenuView *)bottomMenu;
-(void)menuViewJumpChapter:(NSUInteger)chapter page:(NSUInteger)page;
-(void)menuViewFontSize:(KFABottomMenuView *)bottomMenu;
-(void)menuViewMark:(KFATopMenuView *)topMenu;

@end

@interface KFAMenuView : UIView

@property (nonatomic,weak) id<KFAMenuViewDelegate> delegate;
@property (nonatomic,strong) KFARecordModel *recordModel;
@property (nonatomic,strong) KFATopMenuView *topView;
@property (nonatomic,strong) KFABottomMenuView *bottomView;
-(void)showAnimation:(BOOL)animation;
-(void)hiddenAnimation:(BOOL)animation;

@end


