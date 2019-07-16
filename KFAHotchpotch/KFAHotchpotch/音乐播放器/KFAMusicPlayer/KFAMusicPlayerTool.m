//
//  KFAMusicPlayerTool.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/15.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMusicPlayerTool.h"
#import "KFANetworkReachabilityManager.h"

@implementation KFAMusicPlayerTool

+ (NSURL *)customUrlWithUrl:(NSURL *)url {
    NSString *urlStr = [url absoluteString];
    if ([urlStr rangeOfString:@":"].location != NSNotFound) {
        NSString *scheme = [[urlStr componentsSeparatedByString:@":"] firstObject];
        if (scheme) {
            NSString *newScheme = [scheme stringByAppendingString:@"-streaming"];
            urlStr = [urlStr stringByReplacingOccurrencesOfString:scheme withString:newScheme];
            return [NSURL URLWithString:urlStr];
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

+ (NSURL *)originalUrlWithUrl:(NSURL *)url {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:YES];
    components.scheme = [components.scheme stringByReplacingOccurrencesOfString:@"-streaming" withString:@""];
    return components.URL;
}

+ (BOOL)isLocalWithUrl:(NSURL *)url {
    return [self isLocalWithUrlString:url.absoluteString];
}

+ (BOOL)isLocalWithUrlString:(NSString *)urlString {
    if ([urlString hasPrefix:@"http"] || [urlString hasPrefix:@"https"]) {
        return NO;
    }
    return YES;
}

+ (KFAMusicPlayerTool *)shareInstance {
    static KFAMusicPlayerTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[KFAMusicPlayerTool alloc] init];
    });
    return tool;
}

- (void)startMonitoringNetworkStatus:(void (^)(void))block {
    KFANetworkReachabilityManager *manager = [KFANetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(KFANetworkReachabilityStatus status) {
        switch (status) {
            case KFANetworkReachabilityStatusUnknown:
                self.networkStatus = KFAMusicPlayerNetWorkStatusUnknown;
                break;
            case KFANetworkReachabilityStatusNotReachable:
                self.networkStatus = KFAMusicPlayerNetWorkStatusNotReachable;
                break;
            case KFANetworkReachabilityStatusReachableViaWWAN:
                self.networkStatus = KFAMusicPlayerNetWorkStatusReachableViaWWAN;
                break;
            case KFANetworkReachabilityStatusReachableViaWiFi:
                self.networkStatus = KFAMusicPlayerNetWorkStatusReachableViaWiFi;
                break;
                
            default:
                break;
        }
        if (block) {
            block();
        }
    }];
    [manager startMonitoring];
}

@end
