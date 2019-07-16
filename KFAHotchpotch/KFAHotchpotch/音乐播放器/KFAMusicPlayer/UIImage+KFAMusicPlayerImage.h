//
//  UIImage+KFAMusicPlayerImage.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/15.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (KFAMusicPlayerImage)

//裁剪图片
- (UIImage *)imageByResizeToSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
