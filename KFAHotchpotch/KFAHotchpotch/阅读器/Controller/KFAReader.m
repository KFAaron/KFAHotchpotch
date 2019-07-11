//
//  KFAReader.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAReader.h"
#import "KFAReadModel.h"
#import "KFAReadViewController.h"
#import "KFAChapterModel.h"
#import "KFAMenuView.h"
#import "KFACatalogViewController.h"
#import "UIImage+ImageEffects.h"
#import "KFANoteModel.h"
#import "KFAMarkModel.h"
#import <objc/runtime.h>
#import "NSString+HTML.h"
#import "KFARecordModel.h"
#import "KFATopMenuView.h"

#define AnimationDelay 0.3

@interface KFAReader () <UIPageViewControllerDelegate,UIPageViewControllerDataSource,KFAMenuViewDelegate,UIGestureRecognizerDelegate,KFACatalogViewControllerDelegate,KFAReadViewControllerDelegate>
{
    NSUInteger _chapter;    //当前显示的章节
    NSUInteger _page;       //当前显示的页数
    NSUInteger _chapterChange;  //将要变化的章节
    NSUInteger _pageChange;     //将要变化的页数
    BOOL _isTransition;     //是否开始翻页
}

@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,getter=isShowBar) BOOL showBar; //是否显示状态栏
@property (nonatomic,strong) KFAMenuView *menuView; //菜单栏
@property (nonatomic,strong) KFACatalogViewController *catalogVC;   //侧边栏
@property (nonatomic,strong) UIView * catalogView;  //侧边栏背景
@property (nonatomic,strong) KFAReadViewController *readView;   //当前阅读视图

@end

@implementation KFAReader

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.pageViewController];
    [_pageViewController setViewControllers:@[[self readViewWithChapter:_model.record.chapter page:_model.record.page]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    _chapter = _model.record.chapter;
    _page = _model.record.page;
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolMenu)];
        tap.delegate = self;
        tap;
    })];
    [self.view addSubview:self.menuView];
    
    [self addChildViewController:self.catalogVC];
    [self.view addSubview:self.catalogView];
    [self.catalogView addSubview:self.catalogVC.view];
    //添加笔记
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNotes:) name:KFANoteNotification object:nil];
}

- (void)addNotes:(NSNotification *)no {
    KFANoteModel *model = no.object;
    model.recordModel = [_model.record copy];
    [[_model mutableArrayValueForKey:@"notes"] addObject:model];    //这样写才能KVO数组变化
    [KFAReadUtilites showAlertTitle:nil content:@"保存笔记成功"];
}

- (BOOL)prefersStatusBarHidden {
    return !_showBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)showToolMenu {
    [_readView cancelReadViewSelected];
    NSString * key = [NSString stringWithFormat:@"%d_%d",(int)_model.record.chapter,(int)_model.record.page];
    
    id state = _model.marksRecord[key];
    state?(_menuView.topView.state=1): (_menuView.topView.state=0);
    [self.menuView showAnimation:YES];
    
}

#pragma mark - CatalogViewController Delegate
- (void)catalog:(KFACatalogViewController *)catalog didSelectChapter:(NSUInteger)chapter page:(NSUInteger)page {
    [_pageViewController setViewControllers:@[[self readViewWithChapter:chapter page:page]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self updateReadModelWithChapter:chapter page:page];
    [self hiddenCatalog];
}

#pragma mark -  UIGestureRecognizer Delegate
//解决TabView与Tap手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

#pragma mark - Privite Method
- (void)catalogShowState:(BOOL)show {
    show?({
        _catalogView.hidden = !show;
        [UIView animateWithDuration:AnimationDelay animations:^{
            _catalogView.frame = CGRectMake(0, 0,2*ViewSize(self.view).width, ViewSize(self.view).height);
            
        } completion:^(BOOL finished) {
            [_catalogView insertSubview:[[UIImageView alloc] initWithImage:[self blurredSnapshot]] atIndex:0];
        }];
    }):({
        if ([_catalogView.subviews.firstObject isKindOfClass:[UIImageView class]]) {
            [_catalogView.subviews.firstObject removeFromSuperview];
        }
        [UIView animateWithDuration:AnimationDelay animations:^{
            _catalogView.frame = CGRectMake(-ViewSize(self.view).width, 0, 2*ViewSize(self.view).width, ViewSize(self.view).height);
        } completion:^(BOOL finished) {
            _catalogView.hidden = !show;
            
        }];
    });
}

- (void)hiddenCatalog {
    [self catalogShowState:NO];
}

- (UIImage *)blurredSnapshot {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)), NO, 1.0f);
    [self.view drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    UIGraphicsEndImageContext();
    return blurredSnapshotImage;
}

#pragma mark - Menu View Delegate
- (void)menuViewDidHidden:(KFAMenuView *)menu {
    _showBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)menuViewDidAppear:(KFAMenuView *)menu {
    _showBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)menuViewInvokeCatalog:(KFABottomMenuView *)bottomMenu {
    [_menuView hiddenAnimation:NO];
    [self catalogShowState:YES];
}

- (void)menuViewJumpChapter:(NSUInteger)chapter page:(NSUInteger)page {
    [_pageViewController setViewControllers:@[[self readViewWithChapter:chapter page:page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self updateReadModelWithChapter:chapter page:page];
}

- (void)menuViewFontSize:(KFABottomMenuView *)bottomMenu {
    
    [_model.record.chapterModel updateFont];
    [_pageViewController setViewControllers:@[[self readViewWithChapter:_model.record.chapter page:(_model.record.page>_model.record.chapterModel.pageCount-1)?_model.record.chapterModel.pageCount-1:_model.record.page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self updateReadModelWithChapter:_model.record.chapter page:(_model.record.page>_model.record.chapterModel.pageCount-1)?_model.record.chapterModel.pageCount-1:_model.record.page];
}

- (void)menuViewMark:(KFATopMenuView *)topMenu {
    
    NSString * key = [NSString stringWithFormat:@"%d_%d",(int)_model.record.chapter,(int)_model.record.page];
    id state = _model.marksRecord[key];
    if (state) {
        //如果存在移除书签信息
        [_model.marksRecord removeObjectForKey:key];
        [[_model mutableArrayValueForKey:@"marks"] removeObject:state];
    } else {
        //记录书签信息
        KFAMarkModel *model = [[KFAMarkModel alloc] init];
        model.date = [NSDate date];
        model.recordModel = [_model.record copy];
        [[_model mutableArrayValueForKey:@"marks"] addObject:model];
        [_model.marksRecord setObject:model forKey:key];
    }
    _menuView.topView.state = !state;
}

#pragma mark - Create Read View Controller

- (KFAReadViewController *)readViewWithChapter:(NSUInteger)chapter page:(NSUInteger)page{
    
    if (_model.record.chapter != chapter) {
        [_model.record.chapterModel updateFont];
        if (_model.type == KFAReaderTypeEpub) {
            if (!_model.chapters[chapter].epubframeRef) {
                NSString *path = [kDocuments stringByAppendingPathComponent:_model.chapters[chapter].chapterpath];
                NSString* html = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]] encoding:NSUTF8StringEncoding];
                _model.chapters[chapter].content = [html stringByConvertingHTMLToPlainText];
                [_model.chapters[chapter] parserEpubToDictionary];
            }
            [ _model.chapters[chapter] paginateEpubWithBounds:CGRectMake(0,0, kScreenWidth-kLeftSpacing-kRightSpacing, kScreenHeight-kTopSpacing-kBottomSpacing)];
        }
    }
    _readView = [[KFAReadViewController alloc] init];
    _readView.recordModel = _model.record;
    if (_model.type == KFAReaderTypeEpub) {
        _readView.type = KFAReaderTypeEpub;
        if (!_model.chapters[chapter].epubframeRef) {
            NSString *path = [kDocuments stringByAppendingPathComponent:_model.chapters[chapter].chapterpath];
            NSString* html = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]] encoding:NSUTF8StringEncoding];
            _model.chapters[chapter].content = [html stringByConvertingHTMLToPlainText];
            [_model.chapters[chapter] parserEpubToDictionary];
            [_model.chapters[chapter] paginateEpubWithBounds:CGRectMake(0,0, kScreenWidth-kLeftSpacing-kRightSpacing, kScreenHeight-kTopSpacing-kBottomSpacing)];
        }
        
        _readView.epubFrameRef = _model.chapters[chapter].epubframeRef[page];
        _readView.imageArray = _model.chapters[chapter].imageArray;
        _readView.content = _model.chapters[chapter].content;
    } else {
        _readView.type = KFAReaderTypeTxt;
        _readView.content = [_model.chapters[chapter] stringOfPage:page];
    }
    _readView.delegate = self;
    NSLog(@"_readGreate");
    
    return _readView;
}

- (void)updateReadModelWithChapter:(NSUInteger)chapter page:(NSUInteger)page {
    _chapter = chapter;
    _page = page;
    _model.record.chapterModel = _model.chapters[chapter];
    _model.record.chapter = chapter;
    _model.record.page = page;
    [KFAReadModel updateLocalModel:_model url:_resourceURL];
}

#pragma mark - Read View Controller Delegate
- (void)readViewEndEdit:(KFAReadViewController *)readView {
    for (UIGestureRecognizer *ges in self.pageViewController.view.gestureRecognizers) {
        if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
            ges.enabled = YES;
            break;
        }
    }
}

- (void)readViewEditeding:(KFAReadViewController *)readView {
    for (UIGestureRecognizer *ges in self.pageViewController.view.gestureRecognizers) {
        if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
            ges.enabled = NO;
            break;
        }
    }
}

#pragma mark -PageViewController DataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    _pageChange = _page;
    _chapterChange = _chapter;
    
    if (_chapterChange==0 &&_pageChange == 0) {
        return nil;
    }
    if (_pageChange==0) {
        _chapterChange--;
        _pageChange = _model.chapters[_chapterChange].pageCount-1;
    }
    else{
        _pageChange--;
    }
    
    return [self readViewWithChapter:_chapterChange page:_pageChange];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    _pageChange = _page;
    _chapterChange = _chapter;
    if (_pageChange == _model.chapters.lastObject.pageCount-1 && _chapterChange == _model.chapters.count-1) {
        return nil;
    }
    if (_pageChange == _model.chapters[_chapterChange].pageCount-1) {
        _chapterChange++;
        _pageChange = 0;
    } else {
        _pageChange++;
    }
    return [self readViewWithChapter:_chapterChange page:_pageChange];
}

#pragma mark -PageViewController Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) {
        KFAReadViewController *readView = previousViewControllers.firstObject;
        _readView = readView;
        _page = readView.recordModel.page;
        _chapter = readView.recordModel.chapter;
    } else {
        [self updateReadModelWithChapter:_chapter page:_page];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    _chapter = _chapterChange;
    _page = _pageChange;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _pageViewController.view.frame = self.view.frame;
    _catalogVC.view.frame = CGRectMake(0, 0, ViewSize(self.view).width-100, ViewSize(self.view).height);
    [_catalogVC reload];
}

#pragma mark - Properties

- (KFAMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[KFAMenuView alloc] initWithFrame:self.view.frame];
        _menuView.hidden = YES;
        _menuView.delegate = self;
        _menuView.recordModel = _model.record;
    }
    return _menuView;
}

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}

- (KFACatalogViewController *)catalogVC {
    if (!_catalogVC) {
        _catalogVC = [[KFACatalogViewController alloc] init];
        _catalogVC.readModel = _model;
        _catalogVC.catalogDelegate = self;
    }
    return _catalogVC;
}

- (UIView *)catalogView {
    if (!_catalogView) {
        _catalogView = [[UIView alloc] initWithFrame:CGRectMake(-ViewSize(self.view).width, 0, 2*ViewSize(self.view).width, ViewSize(self.view).height)];
        _catalogView.backgroundColor = [UIColor clearColor];
        _catalogView.hidden = YES;
        [_catalogView addGestureRecognizer:({
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenCatalog)];
            tap.delegate = self;
            tap;
        })];
    }
    return _catalogView;
}

@end
