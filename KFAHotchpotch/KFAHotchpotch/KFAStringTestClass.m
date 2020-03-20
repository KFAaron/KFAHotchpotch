//
//  KFAStringTestClass.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2020/3/20.
//  Copyright © 2020 KFAaron. All rights reserved.
//

#import "KFAStringTestClass.h"

@implementation KFAStringTestClass

+ (void)test {
    NSString *a;
    // a的地址：0x0,a的值：(null)
    NSString *b = nil;
    // b的地址：0x0,b的值：(null)
    NSString *c = @"";
    // c的地址：0x10ed629d0,c的值：
    NSString *d = @"有值";
    // d的地址：0x10ed64b90,d的值：有值
    NSString *e = [[NSString alloc] initWithString:c];
    // e的地址：0x10ed629d0,e的值：
    NSString *f = [[NSString alloc] initWithString:d];
    // f的地址：0x10ed64b90,f的值：有值
    NSString *g = [NSString stringWithString:c];
    // g的地址：0x10ed629d0,g的值：
    NSString *h = [NSString stringWithString:d];
    // h的地址：0x10ed64b90,h的值：有值
    NSString *i = [[NSString alloc] initWithFormat:@"%@",b];
    // i的地址：0xabcec475a3275163,i的值：(null)
    NSString *j = [[NSString alloc] initWithFormat:@"%@",c];
    // j的地址：0x7fff806265c0,j的值：
    NSString *k = [[NSString alloc] initWithFormat:@"%@",d];
    // k的地址：0x60000271cdc0,k的值：有值
    NSString *l = [NSString stringWithFormat:@"%@",b];
    // l的地址：0xabcec475a3275163,l的值：(null)
    NSString *m = [NSString stringWithFormat:@"%@",c];
    // m的地址：0x7fff806265c0,m的值：
    NSString *n = [NSString stringWithFormat:@"%@",d];
    // n的地址：0x60000271ce00,n的值：有值
    NSString *o = [d copy];
    // o的地址：0x10ed64b90,o的值：有值
    KFALog(@"a的地址：%p,a的值：%@",a,a);
    KFALog(@"b的地址：%p,b的值：%@",b,b);
    KFALog(@"c的地址：%p,c的值：%@",c,c);
    KFALog(@"d的地址：%p,d的值：%@",d,d);
    KFALog(@"e的地址：%p,e的值：%@",e,e);
    KFALog(@"f的地址：%p,f的值：%@",f,f);
    KFALog(@"g的地址：%p,g的值：%@",g,g);
    KFALog(@"h的地址：%p,h的值：%@",h,h);
    KFALog(@"i的地址：%p,i的值：%@",i,i);
    KFALog(@"j的地址：%p,j的值：%@",j,j);
    KFALog(@"k的地址：%p,k的值：%@",k,k);
    KFALog(@"l的地址：%p,l的值：%@",l,l);
    KFALog(@"m的地址：%p,m的值：%@",m,m);
    KFALog(@"n的地址：%p,n的值：%@",n,n);
    KFALog(@"o的地址：%p,o的值：%@",o,o);
}

@end
