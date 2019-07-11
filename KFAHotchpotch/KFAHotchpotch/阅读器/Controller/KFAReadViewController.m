//
//  KFAReadViewController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAReadViewController.h"
#import "KFARecordModel.h"
#import "KFAReadModel.h"
#import "KFAReadView.h"
#import "KFAReadParser.h"
#import "KFAReadConfig.h"

@interface KFAReadViewController () <KFAReadViewControllerDelegate>

@end

@implementation KFAReadViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    [self.view setBackgroundColor:[KFAReadConfig shareInstance].theme];
    [self.view addSubview:self.readView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:KFAThemeNotification object:nil];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - KFAReadViewControllerDelegate

- (void)readViewEditeding:(KFAReadViewController *)readView {
    if ([self.delegate respondsToSelector:@selector(readViewEditeding:)]) {
        [self.delegate readViewEditeding:self];
    }
}

- (void)readViewEndEdit:(KFAReadViewController *)readView {
    if ([self.delegate respondsToSelector:@selector(readViewEndEdit:)]) {
        [self.delegate readViewEndEdit:self];
    }
}

#pragma mark - Notification

- (void)changeTheme:(NSNotification *)no {
    [KFAReadConfig shareInstance].theme = no.object;
    [self.view setBackgroundColor:[KFAReadConfig shareInstance].theme];
}

#pragma mark - Public

- (void)cancelReadViewSelected {
    [self.readView cancelSelected];
}

#pragma mark - Properties

- (KFAReadView *)readView {
    if (!_readView) {
        _readView = [[KFAReadView alloc] initWithFrame:CGRectMake(kLeftSpacing,kTopSpacing, self.view.frame.size.width-kLeftSpacing-kRightSpacing, self.view.frame.size.height-kTopSpacing-kBottomSpacing)];
        KFAReadConfig *config = [KFAReadConfig shareInstance];
        if (_type == KFAReaderTypeEpub) {
            _readView.frameRef = (__bridge_retained CTFrameRef)_epubFrameRef;
            _readView.imageArray = _imageArray;
        } else {
            _readView.frameRef = [KFAReadParser parserContent:_content config:config bouds:CGRectMake(0,0, _readView.frame.size.width, _readView.frame.size.height)];
        }
        _readView.content = _content;
        _readView.delegate = self;
    }
    return _readView;
}

@end
