//
//  KFAMenuView.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMenuView.h"
#import "KFABottomMenuView.h"
#import "KFARecordModel.h"
#import "KFATopMenuView.h"

#define AnimationDelay 0.3f
#define TopViewHeight 64.0f
#define BottomViewHeight 200.0f

@interface KFAMenuView () <KFAMenuViewDelegate>

@end

@implementation KFAMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenSelf)]];
}

- (KFATopMenuView *)topView {
    if (!_topView) {
        _topView = [[KFATopMenuView alloc] initWithFrame:CGRectMake(0, -TopViewHeight, ViewSize(self).width,TopViewHeight)];
        _topView.delegate = self;
    }
    return _topView;
}

- (KFABottomMenuView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[KFABottomMenuView alloc] initWithFrame:CGRectMake(0, ViewSize(self).height, ViewSize(self).width,BottomViewHeight)];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (void)setRecordModel:(KFARecordModel *)recordModel {
    _recordModel = recordModel;
    _bottomView.readModel = recordModel;
}

#pragma mark - LSYMenuViewDelegate

- (void)menuViewInvokeCatalog:(KFABottomMenuView *)bottomMenu {
    if ([self.delegate respondsToSelector:@selector(menuViewInvokeCatalog:)]) {
        [self.delegate menuViewInvokeCatalog:bottomMenu];
    }
}

- (void)menuViewJumpChapter:(NSUInteger)chapter page:(NSUInteger)page {
    if ([self.delegate respondsToSelector:@selector(menuViewJumpChapter:page:)]) {
        [self.delegate menuViewJumpChapter:chapter page:page];
    }
}

- (void)menuViewFontSize:(KFABottomMenuView *)bottomMenu {
    if ([self.delegate respondsToSelector:@selector(menuViewFontSize:)]) {
        [self.delegate menuViewFontSize:bottomMenu];
    }
}

- (void)menuViewMark:(KFATopMenuView *)topMenu {
    if ([self.delegate respondsToSelector:@selector(menuViewMark:)]) {
        [self.delegate menuViewMark:topMenu];
    }
}

#pragma mark -
- (void)hiddenSelf {
    [self hiddenAnimation:YES];
}

- (void)showAnimation:(BOOL)animation {
    self.hidden = NO;
    [UIView animateWithDuration:animation?AnimationDelay:0 animations:^{
        _topView.frame = CGRectMake(0, 0, ViewSize(self).width, TopViewHeight);
        _bottomView.frame = CGRectMake(0, ViewSize(self).height-BottomViewHeight, ViewSize(self).width,BottomViewHeight);
    } completion:^(BOOL finished) {
        
    }];
    if ([self.delegate respondsToSelector:@selector(menuViewDidAppear:)]) {
        [self.delegate menuViewDidAppear:self];
    }
}

- (void)hiddenAnimation:(BOOL)animation {
    [UIView animateWithDuration:animation?AnimationDelay:0 animations:^{
        _topView.frame = CGRectMake(0, -TopViewHeight, ViewSize(self).width, TopViewHeight);
        _bottomView.frame = CGRectMake(0, ViewSize(self).height, ViewSize(self).width,BottomViewHeight);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    if ([self.delegate respondsToSelector:@selector(menuViewDidHidden:)]) {
        [self.delegate menuViewDidHidden:self];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

@end
