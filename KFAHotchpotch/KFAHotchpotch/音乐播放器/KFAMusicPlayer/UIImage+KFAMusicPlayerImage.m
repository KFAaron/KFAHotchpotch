//
//  UIImage+KFAMusicPlayerImage.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/15.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "UIImage+KFAMusicPlayerImage.h"

@implementation UIImage (KFAMusicPlayerImage)

- (UIImage *)imageByResizeToSize:(CGSize)size {
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
