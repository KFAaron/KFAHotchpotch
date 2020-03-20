//
//  ViewController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/5/23.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "ViewController.h"
#import "KFAStringTestClass.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self configDatasource];
    [KFAStringTestClass test];
}

- (void)configDatasource {
    
    self.dataSource = ({
        NSArray *arr = @[
  @{kTitle:@"编译",kClassName:@"KFACompileController"},
  @{kTitle:@"链式",kClassName:@"KFAChainedDemoController"},
  @{kTitle:@"阅读器",kClassName:@"KFAReaderDemoController"},
  @{kTitle:@"音乐播放器",kClassName:@"KFAMusicDemoController"},
  @{kTitle:@"Segment",kClassName:@"KFAPageViewController"},
  @{kTitle:@"系统权限",kClassName:@"KFAAuthorityViewController"}];
        arr;
    });
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KFAMainTableViewCellIndentifier" forIndexPath:indexPath];
    if (indexPath.section < self.dataSource.count) {
        NSDictionary *data = self.dataSource[indexPath.section];
        cell.textLabel.text = data[kTitle];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section < self.dataSource.count) {
        NSDictionary *data = self.dataSource[indexPath.section];
        NSString *className = data[kClassName];
        Class vcClass = NSClassFromString(className);
        if ([[vcClass alloc] isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = [[vcClass alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self toBeDevelopedTip];
        }
    }
}

- (void)toBeDevelopedTip {
    
    KFALog(@"待开发提示");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"此功能待开发~" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"哦了" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
