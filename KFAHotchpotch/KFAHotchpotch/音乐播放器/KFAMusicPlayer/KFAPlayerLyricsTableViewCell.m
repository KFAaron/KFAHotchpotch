//
//  KFAPlayerLyricsTableViewCell.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/16.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAPlayerLyricsTableViewCell.h"

@implementation KFAPlayerLyricsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundLrcLabel = [[UILabel alloc] init];
        self.backgroundLrcLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.backgroundLrcLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.backgroundLrcLabel];
        
        self.foregroundLrcLabel = [[UILabel alloc] init];
        self.foregroundLrcLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.foregroundLrcLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.foregroundLrcLabel];
        
        self.lrcMasklayer = [CALayer layer];
        self.lrcMasklayer.anchorPoint = CGPointMake(0, 0.5);
        self.foregroundLrcLabel.layer.mask = self.lrcMasklayer;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
