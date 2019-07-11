//
//  KFAMarkVC.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMarkVC.h"
#import "KFAReadModel.h"
#import "KFACatalogViewController.h"
#import "KFAMarkModel.h"
#import "KFARecordModel.h"
#import "KFAChapterModel.h"

static  NSString *markCell = @"markCell";

@interface KFAMarkVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tabView;

@end

@implementation KFAMarkVC

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"readModel.marks"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"readModel.marks" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [_tabView reloadData];
    [KFAReadModel updateLocalModel:_readModel url:_readModel.resource]; //本地保存
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tabView];
}

#pragma mark - UITableView Delagete DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _readModel.marks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:markCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:markCell];
    }
    if (_readModel.marks[indexPath.row].recordModel.chapterModel.type == KFAReaderTypeEpub) {
        cell.textLabel.text = _readModel.marks[indexPath.row].recordModel.chapterModel.epubString[_readModel.marks[indexPath.row].recordModel.page];
    } else {
        cell.textLabel.text = [_readModel.marks[indexPath.row].recordModel.chapterModel stringOfPage:_readModel.marks[indexPath.row].recordModel.page];
    }
    cell.detailTextLabel.text = _readModel.marks[indexPath.row].recordModel.chapterModel.title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(catalog:didSelectChapter:page:)]) {
        [self.delegate catalog:nil didSelectChapter:_readModel.marks[indexPath.row].recordModel.chapter page:_readModel.marks[indexPath.row].recordModel.page];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_readModel.marks removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tabView.frame = CGRectMake(0, 0, ViewSize(self.view).width, ViewSize(self.view).height);
}

#pragma mark - ProPerties

-(UITableView *)tabView {
    if (!_tabView) {
        _tabView = [[UITableView alloc] init];
        _tabView.delegate = self;
        _tabView.dataSource = self;
        _tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tabView;
}

@end
