//
//  KFAChainedDemoController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/9.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAChainedDemoController.h"
#import "KFAChainedMD.h"

@interface KFAChainedDemoController ()

@end

@implementation KFAChainedDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    KFAChainedMD *md = [[KFAChainedMD alloc] init];
    md.name(@"Aaron").age(18).eat(@"苹果").sing(@"你好");
    [[md changeName:^NSString *(NSString *oldName) {
        KFALog(@"原来的名字叫%@",oldName);
        return @"Tom";
    }] isAaron:^BOOL(NSString *name) {
        KFALog(@"目前名字叫%@",name);
        return [name isEqualToString:@"Aaron"];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
