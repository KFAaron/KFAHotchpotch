//
//  KFAReaderDemoController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAReaderDemoController.h"
#import "KFAReader.h"
#import "KFAReadModel.h"

@interface KFAReaderDemoController ()

@property (weak, nonatomic) IBOutlet UIButton *txtBtn;
@property (weak, nonatomic) IBOutlet UIButton *epubBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *txtActivity;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *epubActivity;

@end

@implementation KFAReaderDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtActivity.hidesWhenStopped = YES;
    self.epubActivity.hidesWhenStopped = YES;
}

- (IBAction)txtAction:(id)sender {
    
    [self.txtActivity startAnimating];
    [self.txtBtn setTitle:@"" forState:UIControlStateNormal];
    [self.epubBtn setEnabled:NO];
    KFAReader *pageView = [[KFAReader alloc] init];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"mdjyml"withExtension:@"txt"];
    pageView.resourceURL = fileURL;    //文件位置
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        pageView.model = [KFAReadModel getLocalModelWithURL:fileURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.txtActivity stopAnimating];
            [self.txtBtn setTitle:@"txt" forState:UIControlStateNormal];
            [self.epubBtn setEnabled:YES];
            
            [self presentViewController:pageView animated:YES completion:nil];
        });
    });
}

- (IBAction)epubAction:(id)sender {
    
    [self.epubActivity startAnimating];
    [self.epubBtn setTitle:@"" forState:UIControlStateNormal];
    [self.txtBtn setEnabled:NO];
    KFAReader *pageView = [[KFAReader alloc] init];
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"每天懂一点好玩心理学"withExtension:@"epub"];
    pageView.resourceURL = fileURL;    //文件位置
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        pageView.model = [KFAReadModel getLocalModelWithURL:fileURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.epubActivity stopAnimating];
            [self.epubBtn setTitle:@"epub" forState:UIControlStateNormal];
            [self.txtBtn setEnabled:YES];
            
            [self presentViewController:pageView animated:YES completion:nil];
        });
    });
}

@end
