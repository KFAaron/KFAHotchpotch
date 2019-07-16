//
//  KFAMusicPlayerTool.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/15.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const KFAMusicPlayerCurrentAudioInfoModelPlayNotificationKey = @"KFAMusicPlayerCurrentAudioInfoModelPlayNotificationKey";

/**
 网络状态

 - KFAMusicPlayerNetWorkStatusUnknown: 未知
 - KFAMusicPlayerNetWorkStatusNotReachable: 无网络连接
 - KFAMusicPlayerNetWorkStatusReachableViaWWAN: 2G/3G/4G
 - KFAMusicPlayerNetWorkStatusReachableViaWiFi: WIFI
 */
typedef NS_ENUM(NSInteger, KFAMusicPlayerNetWorkStatus) {
    KFAMusicPlayerNetWorkStatusUnknown                   = -1,
    KFAMusicPlayerNetWorkStatusNotReachable           = 0,
    KFAMusicPlayerNetWorkStatusReachableViaWWAN = 1,
    KFAMusicPlayerNetWorkStatusReachableViaWiFi      = 2,
};

@interface KFAMusicPlayerTool : NSObject

//链接
+ (NSURL *)customUrlWithUrl:(NSURL *)url;
+ (NSURL *)originalUrlWithUrl:(NSURL *)url;
//判断是否是本地音频
+ (BOOL)isLocalWithUrl:(NSURL *)url;
+ (BOOL)isLocalWithUrlString:(NSString *)urlString;

+ (KFAMusicPlayerTool *)shareInstance;

- (void)startMonitoringNetworkStatus:(void(^)(void))block;

@property (nonatomic, assign) KFAMusicPlayerNetWorkStatus networkStatus;

@end


