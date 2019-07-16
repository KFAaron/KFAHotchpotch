//
//  KFAMusicCacheManager.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/15.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMusicCacheManager.h"
#import "KFAMusicPlayerTool.h"

static NSString * const kMusicCacheField = @"kMusicCacheField";
static NSString * const kMusicCacheFileName = @"kMusicCacheFileName"; // 所有缓存文件都放在了沙盒Cache文件夹下kMusicCacheFileName文件夹里
static NSString * const kMusicArchiverName = @"KFAMusicPlayer.archiver";
static NSString * const kMusicModelArchiverName = @"KFAMusicModel.archiver";

@implementation KFAMusicCacheManager

+ (void)createMusicCachePathWithUserId:(NSString *)userId {
    NSString *uniqueId = @"public";
    if (userId) {
        if ([userId rangeOfString:@" "].location != NSNotFound) {
            userId = [userId stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        if (userId.length > 0) {
            uniqueId = userId;
        } else {
            KFALog(@"因为没有传入有效的userId，播放器缓存将用统一的cache :  user_public");
        }
    } else {
        KFALog(@"播放器使用统一的cache : user_public");
    }
    [[NSUserDefaults standardUserDefaults] setObject:uniqueId forKey:kMusicCacheField];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// KFAMusicPlayerCache文件夹的地址
+ (NSString *)playerCachePath {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [cachePath stringByAppendingPathComponent:kMusicCacheFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)currentUserCachePath {
    NSString *fileId = [[NSUserDefaults standardUserDefaults] stringForKey:kMusicCacheField];
    NSString *fileName = [NSString stringWithFormat:@"user_%@",fileId];
    NSString *userPath = [[KFAMusicCacheManager playerCachePath] stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:userPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return userPath;
}

/// 临时文件路径
+ (NSString *)audioTempFilePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"MusicTemp.mp4"];
}

+ (BOOL)creatTempFile {
    NSString *tempPath = [KFAMusicCacheManager audioTempFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    }
    return [[NSFileManager defaultManager] createFileAtPath:tempPath contents:nil attributes:nil];
}

+ (void)writeToTempFileWithData:(NSData *)data {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[KFAMusicCacheManager audioTempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readDataFromTempFileWith:(NSUInteger)offset length:(NSUInteger)length {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[KFAMusicCacheManager audioTempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)moveTempFileToCache:(NSURL *)url block:(void (^)(BOOL, NSError *))block {
    NSString *path = [KFAMusicCacheManager audioFileOfCachePathWith:url];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        NSNumber *numberId = [NSNumber numberWithInt:kMusicCacheField.intValue];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{NSFileOwnerAccountID:numberId} error:&error];
        if (error) {
            KFALog(@"error: %@",error.localizedDescription);
        }
    }
    NSString *audioName = url.path.lastPathComponent;
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@",path,audioName];
    NSError *error;
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:[KFAMusicCacheManager audioTempFilePath] toPath:cacheFilePath error:&error];
    if (!isSuccess) {
        // 安全性处理 如果没有保存成功，删除归档文件中的对应键值对
        [KFAMusicArchiverManager deleteHaveArchivedKeyValueWithUrl:url];
    }
    if (block) {
        block(isSuccess, error);
    }
}

+ (NSString *)audioFileOfCachePathWith:(NSURL *)url {
    NSString *filePath = [KFAMusicCacheManager currentUserCachePath];
    NSString *urlPath = [[url.absoluteString componentsSeparatedByString:@"//"].lastObject stringByDeletingLastPathComponent];
    NSString *path = [filePath stringByAppendingPathComponent:urlPath];
    return path;
}

+ (NSString *)checkAudioCacheExistWithAudioUrl:(NSURL *)url {
    NSString *path = [KFAMusicCacheManager audioFileOfCachePathWith:url];
    NSString *audioName = url.path.lastPathComponent;
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@",path,audioName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}

+ (void)clearAudioCacheWithAudioUrl:(NSURL *)url block:(void (^)(BOOL, NSError *))block {
    NSString *cacheFilePath = [self checkAudioCacheExistWithAudioUrl:url];
    if (cacheFilePath) {
        NSError *error;
        BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:&error];
        if (block) {
            block(isSuccess, error);
        }
    }
}

+ (void)clearMusicCacheForCurrentUser:(BOOL)isClearCurrentUser block:(void (^)(BOOL, NSError *))block {
    NSError *error;
    NSString *path = [KFAMusicCacheManager playerCachePath];
    if (isClearCurrentUser) {
        path = [KFAMusicCacheManager currentUserCachePath];
    }
    BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (block) {
        block(isSuccess, error);
    }
}

+ (CGFloat)countMusicCacheSizeForCurrentUser:(BOOL)isCurrentUser {
    NSString *path = [KFAMusicCacheManager playerCachePath];
    if (isCurrentUser) {
        path = [KFAMusicCacheManager currentUserCachePath];
    }
    return [self sizeWithPath:path];
}

+ (CGFloat)sizeWithPath:(NSString *)cachePath {
    NSArray *fileArr = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    CGFloat size = 0;
    for (NSString *path in fileArr) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:path];
        size += [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
    }
    CGFloat sizeM = size/1000.0/1000.0;
    return sizeM;
}

+ (void)countSystemSizeBlock:(void (^)(CGFloat, CGFloat))block {
    NSError *error = nil;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) {
        KFALog(@"error: %@",error.localizedDescription);
        if (block) {
            block(0, 0);
        }
    } else {
        NSNumber *free = [dictionary objectForKey:NSFileSystemFreeSize];
        float freesize = [free unsignedLongLongValue]/1000.0;
        NSNumber *total = [dictionary objectForKey:NSFileSystemSize];
        float totalSize = [total unsignedLongLongValue]/1000.0;
        if (block) {
            block(totalSize, freesize);
        }
    }
}

@end

NSString * const KFAMusicPlayerCurrentAudioInfoModelAudioUrl = @"KFAMusicPlayerCurrentAudioInfoModelAudioUrl";
NSString * const KFAMusicPlayerCurrentAudioInfoModelCurrentTime = @"KFAMusicPlayerCurrentAudioInfoModelCurrentTime";
NSString * const KFAMusicPlayerCurrentAudioInfoModelTotalTime = @"KFAMusicPlayerCurrentAudioInfoModelTotalTime";
NSString * const KFAMusicPlayerCurrentAudioInfoModelProgress = @"KFAMusicPlayerCurrentAudioInfoModelProgress";

@implementation KFAMusicArchiverManager

/// 归档文件路径
+ (NSString *)archiverFilePath {
    NSString *cachePath = [KFAMusicCacheManager currentUserCachePath];
    NSString *path = [cachePath stringByAppendingPathComponent:kMusicArchiverName];
    return path;
}

+ (NSMutableDictionary *)hasArchivedFileDictionary {
    NSString *path = [self archiverFilePath];
    _archiverDic = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!_archiverDic) {
        _archiverDic = [NSMutableDictionary dictionary];
    }
    return _archiverDic;
}

+ (BOOL)archiveValue:(id)value forKey:(NSString *)key {
    NSMutableDictionary *dic = [self hasArchivedFileDictionary];
    [dic setValue:value forKey:key];
    NSString *path = [self archiverFilePath];
    return [NSKeyedArchiver archiveRootObject:dic toFile:path];
}

+ (void)deleteHaveArchivedKeyValueWithUrl:(NSURL *)url {
    NSMutableDictionary *dic = [self hasArchivedFileDictionary];
    __block BOOL isHave = NO;
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:url.absoluteString]) {
            [dic removeObjectForKey:key];
            isHave = YES;
            *stop = YES;
        }
    }];
    if (isHave) {
        NSString *path = [self archiverFilePath];
        [NSKeyedArchiver archiveRootObject:dic toFile:path];
    }
}

/// 归档文件路径
+ (NSString *)modelArchiverFilePath {
    NSString *cachePath = [KFAMusicCacheManager currentUserCachePath];
    NSString *path = [cachePath stringByAppendingPathComponent:kMusicModelArchiverName];
    return path;
}

+ (NSDictionary *)cunarchieInfoModelDictionary {
    NSString *path = [self modelArchiverFilePath];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

+ (BOOL)archiveInfoModelWithAudioUrl:(NSURL *)audioUrl currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime progress:(CGFloat)progress {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (audioUrl && [audioUrl isKindOfClass:[NSURL class]]) {
        if ([KFAMusicPlayerTool isLocalWithUrl:audioUrl]) {
            [dic setObject:audioUrl.absoluteString.lastPathComponent forKey:KFAMusicPlayerCurrentAudioInfoModelAudioUrl];
        } else {
            [dic setObject:audioUrl.absoluteString forKey:KFAMusicPlayerCurrentAudioInfoModelAudioUrl];
        }
    }
    if (currentTime) {
        [dic setObject:[NSNumber numberWithFloat:currentTime] forKey:KFAMusicPlayerCurrentAudioInfoModelCurrentTime];
    }
    if (totalTime) {
        [dic setObject:[NSNumber numberWithFloat:totalTime] forKey:KFAMusicPlayerCurrentAudioInfoModelTotalTime];
    }
    if (progress) {
        [dic setObject:[NSNumber numberWithFloat:progress] forKey:KFAMusicPlayerCurrentAudioInfoModelProgress];
    }
    NSString *path = [KFAMusicArchiverManager modelArchiverFilePath];
    return [NSKeyedArchiver archiveRootObject:dic toFile:path];
}

@end

