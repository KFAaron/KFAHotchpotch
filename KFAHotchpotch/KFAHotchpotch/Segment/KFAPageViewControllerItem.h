//
//  KFAPageViewControllerItem.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KFAPageViewControllerMoveEvent.h"

@interface UIViewController (KFAPageViewController) <KFAPageViewControllerMoveEvent>
@end

@interface KFAPageViewControllerItem : NSObject

@property (nonatomic, strong, nonnull) UIViewController *viewController;
@property (nonatomic, copy, nonnull) NSString *segmentTitle;

@end


