//
//  KFAPlayerLyricsTableViewCell.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/16.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface KFAPlayerLyricsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *backgroundLrcLabel;
@property (nonatomic, strong) UILabel *foregroundLrcLabel;
@property (nonatomic, strong) CALayer *lrcMasklayer;

@end


