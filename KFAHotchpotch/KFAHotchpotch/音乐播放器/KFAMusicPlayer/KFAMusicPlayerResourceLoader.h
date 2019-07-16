//
//  KFAMusicPlayerResourceLoader.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/16.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KFAMusicPlayerRequestManager.h"

#define kMimeType @"video/mp4"

@class KFAMusicPlayerResourceLoader;
@protocol KFAMusicPlayerResourceLoaderDelegate <NSObject>

- (void)loader:(KFAMusicPlayerResourceLoader *)loader isCached:(BOOL)isCached;

- (void)loader:(KFAMusicPlayerResourceLoader *)loader requestError:(NSInteger)errorCode;

@end


@interface KFAMusicPlayerResourceLoader : NSObject<AVAssetResourceLoaderDelegate,KFAMusicPlayerRequestDelegate>

@property (nonatomic, weak) id<KFAMusicPlayerResourceLoaderDelegate> delegate;
@property (nonatomic, copy) void(^checkStatusBlock)(NSInteger statusCode);
@property (nonatomic, assign) BOOL isHaveCache;//是否有缓存
@property (nonatomic, assign) BOOL isObserveFileModifiedTime;//是否观察修改时间
/**退出播放器和切换歌曲时调用该方法*/
- (void)stopLoading;

@end


