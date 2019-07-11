//
//  KFAMagnifierView.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/10.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMagnifierView.h"
#import "KFAReadConfig.h"

@implementation KFAMagnifierView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:CGRectMake(0, 0, 80, 80)]) {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self setBackgroundColor:[KFAReadConfig shareInstance].theme];
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 40;
        self.layer.masksToBounds = YES;
    }
    return self;
}
- (void)setTouchPoint:(CGPoint)touchPoint {
    
    _touchPoint = touchPoint;
    self.center = CGPointMake(touchPoint.x, touchPoint.y - 70);
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 通过平移变换截图选中的内容
    CGContextTranslateCTM(context, self.frame.size.width*0.5,self.frame.size.height*0.5);
    CGContextScaleCTM(context, 1.5, 1.5);
    CGContextTranslateCTM(context, -1 * (_touchPoint.x), -1 * (_touchPoint.y));
    [self.readView.layer renderInContext:context];
}

@end
