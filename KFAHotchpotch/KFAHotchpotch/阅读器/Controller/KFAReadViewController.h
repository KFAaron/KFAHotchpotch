//
//  KFAReadViewController.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFAReadViewController, KFARecordModel, KFAReadModel, KFAReadView;

@protocol KFAReadViewControllerDelegate <NSObject>

- (void)readViewEditeding:(KFAReadViewController *)readView;
- (void)readViewEndEdit:(KFAReadViewController *)readView;

@end

@interface KFAReadViewController : UIViewController

@property (nonatomic,copy) NSString *content; //显示的内容
@property (nonatomic,strong) id epubFrameRef;  //epub显示内容
@property (nonatomic,copy) NSArray *imageArray;  //epub显示的图片
@property (nonatomic,assign) KFAReaderType type;   //文本类型
@property (nonatomic,strong) KFARecordModel *recordModel;   //阅读进度
@property (nonatomic,strong) KFAReadView *readView;
@property (nonatomic,weak) id<KFAReadViewControllerDelegate>delegate;

- (void)cancelReadViewSelected;

@end

