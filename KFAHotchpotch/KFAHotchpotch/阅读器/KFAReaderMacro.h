//
//  KFAReaderMacro.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#ifndef KFAReaderMacro_h
#define KFAReaderMacro_h

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#define kDocuments NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject

#define kTopSpacing 40.0f
#define kBottomSpacing 40.0f
#define kLeftSpacing 20.0f
#define kRightSpacing  20.0f

#define ViewSize(view)  (view.frame.size)
#define DistanceFromLeftGuiden(view) (view.frame.origin.x + view.frame.size.width)
#define DistanceFromTopGuiden(view) (view.frame.origin.y + view.frame.size.height)

#define KFANoteNotification @"KFANoteNotification"
#define KFAThemeNotification @"KFAThemeNotification"

#define KFARGB(R, G, B)    [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

#define kMinFontSize 11.0f
#define kMaxFontSize 20.0f

typedef NS_ENUM(NSInteger, KFAReaderType) {
    KFAReaderTypeTxt,
    KFAReaderTypeEpub
};

#import "KFAReadUtilites.h"

#endif /* KFAReaderMacro_h */
