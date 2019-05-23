//
//  ViewController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/5/23.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "ViewController.h"
#import "KFAChainedMD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KFAChainedMD *md = [[KFAChainedMD alloc] init];
    md.name(@"Aaron").age(18).eat(@"苹果").sing(@"你好");
    
}


@end
