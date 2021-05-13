//
//  KFABiaoshifuViewController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2020/8/24.
//  Copyright © 2020 KFAaron. All rights reserved.
//

#import "KFABiaoshifuViewController.h"
#import "KFABiaoshifuTool.h"

@interface KFABiaoshifuViewController ()

@end

@implementation KFABiaoshifuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSString *macAddress = [KFABiaoshifuTool getMacAddress];
    NSLog(@"mac:%@",macAddress);
    
    NSString *idfaStr = [KFABiaoshifuTool getIDFA];
    NSLog(@"idfa:%@",idfaStr);
    
    NSString *idfvStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"idfv:%@",idfvStr);
    
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
