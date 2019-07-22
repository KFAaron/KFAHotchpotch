//
//  KFAPageViewControllerMoveEvent.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol KFAPageViewControllerMoveEvent <NSObject>

/**
 即将离开当前VC
 
 @param viewController 即将到达的VC
 */
- (void)willMoveToViewController:(UIViewController *)viewController;

/**
 已经离开当前VC
 
 @param viewController 已经到达的VC
 */
- (void)didMoveToViewController:(UIViewController *)viewController;

/**
 即将到达当前VC
 
 @param viewController 上一个VC
 */
- (void)willEnterFromViewController:(UIViewController *)viewController;

/**
 已经到达当前VC
 
 @param viewController 上一个VC
 */
- (void)didEnterFromViewController:(UIViewController *)viewController;

@end


