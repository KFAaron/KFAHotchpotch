//
//  KFACompileController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/9.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFACompileController.h"
#import "KFAMan.h"

@interface KFACompileController ()

@end

@implementation KFACompileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)clickAction:(id)sender {
    KFAMan *man = [[KFAMan alloc] init];
    [man work];
}

- (IBAction)clickAgain:(id)sender {
    KFAMan *man = [[KFAMan alloc] init];
    [man work];
}

@end
