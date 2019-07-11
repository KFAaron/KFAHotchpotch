//
//  KFANoteVC.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFANoteVC.h"
#import "KFACatalogViewController.h"
#import "KFAReadModel.h"
#import "KFANoteModel.h"
#import "KFARecordModel.h"
#import "KFAChapterModel.h"

static  NSString *noteCell = @"noteCell";

@interface KFANoteVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tabView;

@end

@implementation KFANoteVC

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"readModel.notes"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"readModel.notes" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tabView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [_tabView reloadData];
    [KFAReadModel updateLocalModel:_readModel url:_readModel.resource]; //本地保存
}

#pragma mark - UITableView Delagete DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _readModel.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noteCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noteCell];
    }
    cell.textLabel.text = _readModel.notes[indexPath.row].content;
    cell.detailTextLabel.text = _readModel.notes[indexPath.row].note;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(catalog:didSelectChapter:page:)]) {
        [self.delegate catalog:nil didSelectChapter:_readModel.notes[indexPath.row].recordModel.chapter page:_readModel.notes[indexPath.row].recordModel.page];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_readModel.notes removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tabView.frame = CGRectMake(0, 0, ViewSize(self.view).width, ViewSize(self.view).height);
}

#pragma mark - Properties

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
