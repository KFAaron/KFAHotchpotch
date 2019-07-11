//
//  KFACatalogViewController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFACatalogViewController.h"
#import "KFAReadModel.h"
#import "KFAChapterVC.h"
#import "KFANoteVC.h"
#import "KFAMarkVC.h"

@interface KFACatalogViewController () <KFAViewPagerVCDelegate,KFAViewPagerVCDataSource,KFACatalogViewControllerDelegate>

@property (nonatomic,copy) NSArray *titleArray;
@property (nonatomic,copy) NSArray *VCArray;

@end

@implementation KFACatalogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleArray = @[@"目录",@"笔记",@"书签"];
    _VCArray = @[({
        KFAChapterVC *chapterVC = [[KFAChapterVC alloc]init];
        chapterVC.readModel = _readModel;
        chapterVC.delegate = self;
        chapterVC;
    }),({
        KFANoteVC *noteVC = [[KFANoteVC alloc] init];
        noteVC.readModel = _readModel;
        noteVC.delegate = self;
        noteVC;
    }),({
        KFAMarkVC *markVC =[[KFAMarkVC alloc] init];
        markVC.readModel = _readModel;
        markVC.delegate = self;
        markVC;
    })];
    self.forbidGesture = YES;
    self.delegate = self;
    self.dataSource = self;
}

- (NSInteger)numberOfViewControllersInViewPager:(KFAViewPagerVC *)viewPager {
    return _titleArray.count;
}

- (UIViewController *)viewPager:(KFAViewPagerVC *)viewPager indexOfViewControllers:(NSInteger)index {
    return _VCArray[index];
}

- (NSString *)viewPager:(KFAViewPagerVC *)viewPager titleWithIndexOfViewControllers:(NSInteger)index {
    return _titleArray[index];
}

- (CGFloat)heightForTitleOfViewPager:(KFAViewPagerVC *)viewPager {
    return 40.0f;
}

- (void)catalog:(KFACatalogViewController *)catalog didSelectChapter:(NSUInteger)chapter page:(NSUInteger)page {
    if ([self.catalogDelegate respondsToSelector:@selector(catalog:didSelectChapter:page:)]) {
        [self.catalogDelegate catalog:self didSelectChapter:chapter page:page];
    }
}

@end
