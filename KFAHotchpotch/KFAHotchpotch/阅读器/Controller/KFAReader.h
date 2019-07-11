//
//  KFAReader.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFAReadModel;

@interface KFAReader : UIViewController

@property (nonatomic,strong) NSURL *resourceURL;
@property (nonatomic,strong) KFAReadModel *model;

@end


