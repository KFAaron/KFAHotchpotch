//
//  KFAMarkVC.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFAReadModel;

@protocol KFACatalogViewControllerDelegate;

@interface KFAMarkVC : UIViewController

@property (nonatomic,strong) KFAReadModel *readModel;
@property (nonatomic,weak) id<KFACatalogViewControllerDelegate>delegate;

@end


