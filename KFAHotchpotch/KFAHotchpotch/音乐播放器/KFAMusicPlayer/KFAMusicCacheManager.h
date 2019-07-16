//
//  KFAMusicCacheManager.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/15.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KFAMusicCacheManager : NSObject

/// 根据userid创建缓存目录
+ (void)createMusicCachePathWithUserId:(NSString *)userId;
/// 当前用户缓存目录
+ (NSString *)currentUserCachePath;
/// 创建临时文件
+ (BOOL)creatTempFile;
/// 往临时文件写入数据
+ (void)writeToTempFileWithData:(NSData *)data;
/// 读取临时文件的数据
+ (NSData *)readDataFromTempFileWith:(NSUInteger)offset length:(NSUInteger)length;

/// 保存临时文件到缓存
+ (void)moveTempFileToCache:(NSURL *)url block:(void(^)(BOOL isSuccess, NSError *error))block;

/**
 url对应音频是否已经在本地缓存
 
 @param url 网络音频url
 @return 有缓存返回缓存地址，无缓存返回nil
 */
+ (NSString *)checkAudioCacheExistWithAudioUrl:(NSURL *)url;

/**
 清除url对应的本地缓存
 
 @param url 网络音频url
 @param block 是否清除成功 错误信息
 */
+ (void)clearAudioCacheWithAudioUrl:(NSURL *)url
                                  block:(void(^)(BOOL isSuccess, NSError *error))block;

/**
 清除KFAMusicPlayer产生的缓存
 
 @param isClearCurrentUser YES:清除当前用户缓存  NO:清除所有用户缓存
 @param block 是否清除成功 错误信息
 */
+ (void)clearMusicCacheForCurrentUser:(BOOL)isClearCurrentUser
                                    block:(void(^)(BOOL isSuccess, NSError *error))block;

/**
 计算KFAMusicPlayer的缓存大小
 
 @param isCurrentUser YES:计算当前用户缓存大小  NO:计算所有用户缓存大小
 @return 大小
 */
+ (CGFloat)countMusicCacheSizeForCurrentUser:(BOOL)isCurrentUser;

/**
 计算系统磁盘空间 剩余可用空间
 
 @param block totalSize:总空间 freeSize:剩余空间
 */
+ (void)countSystemSizeBlock:(void(^)(CGFloat totalSize,CGFloat freeSize))block;

@end


static NSMutableDictionary *_archiverDic;
UIKIT_EXTERN NSString * const KFAMusicPlayerCurrentAudioInfoModelAudioUrl;
UIKIT_EXTERN NSString * const KFAMusicPlayerCurrentAudioInfoModelCurrentTime;
UIKIT_EXTERN NSString * const KFAMusicPlayerCurrentAudioInfoModelTotalTime;
UIKIT_EXTERN NSString * const KFAMusicPlayerCurrentAudioInfoModelProgress;


@interface KFAMusicArchiverManager : NSObject

/// 已经归档的数据
+ (NSMutableDictionary *)hasArchivedFileDictionary;
/// 归档
+ (BOOL)archiveValue:(id)value forKey:(NSString *)key;
/// 删除归档
+ (void)deleteHaveArchivedKeyValueWithUrl:(NSURL *)url;
/// 解析model
+ (NSDictionary *)cunarchieInfoModelDictionary;
/// 归档model
+ (BOOL)archiveInfoModelWithAudioUrl:(NSURL *)audioUrl currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime progress:(CGFloat)progress;

@end


