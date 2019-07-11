//
//  KFACatalogViewController.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAViewPagerVC.h"

@class KFACatalogViewController, KFAReadModel;

@protocol KFACatalogViewControllerDelegate <NSObject>

@optional
- (void)catalog:(KFACatalogViewController *)catalog didSelectChapter:(NSUInteger)chapter page:(NSUInteger)page;

@end

@interface KFACatalogViewController : KFAViewPagerVC

@property (nonatomic,strong) KFAReadModel *readModel;
@property (nonatomic,weak) id<KFACatalogViewControllerDelegate>catalogDelegate;

@end


