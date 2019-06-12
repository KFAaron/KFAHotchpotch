//
//  main.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/5/23.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"启动 func：%s, line：%d", __func__, __LINE__);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
