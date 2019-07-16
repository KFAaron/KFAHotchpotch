//
//  KFAMusicPlayer.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/12.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KFAMusicModel.h"

/**
 播放器类型

 - KFAMusicPlayerTypeAmbient: 用于播放。随静音键和屏幕关闭而静音。不终止其它应用播放声音
 - KFAMusicPlayerTypeSoloAmbient: 用于播放。随静音键和屏幕关闭而静音。终止其它应用播放声音
 - KFAMusicPlayerTypePlayback: 用于播放。不随静音键和屏幕关闭而静音。终止其它应用播放声音
                                                     需要在工程里设置targets->capabilities->选择backgrounds
                                                     modes->勾选audio,airplay,and picture in picture
 - KFAMusicPlayerTypePlayAndRecord: 用于播放和录音。不随着静音键和屏幕关闭而静音。终止其他应用播放声音
 - KFAMusicPlayerTypeMultiRoute: 用于播放和录音。不随着静音键和屏幕关闭而静音。可多设备输出
 */
typedef NS_ENUM(NSInteger, KFAMusicPlayerType) {
    KFAMusicPlayerTypeAmbient,
    KFAMusicPlayerTypeSoloAmbient,
    KFAMusicPlayerTypePlayback,
    KFAMusicPlayerTypePlayAndRecord,
    KFAMusicPlayerTypeMultiRoute,
};

/**
 播放器状态

 - KFAMusicPlayerStateFailed: 播放失败
 - KFAMusicPlayerStateBuffering: 缓冲中
 - KFAMusicPlayerStatePlaying: 播放中
 - KFAMusicPlayerStatePause: 暂停播放
 - KFAMusicPlayerStateStopped: 停止播放
 */
typedef NS_ENUM(NSInteger, KFAMusicPlayerState) {
    KFAMusicPlayerStateFailed,
    KFAMusicPlayerStateBuffering,
    KFAMusicPlayerStatePlaying,
    KFAMusicPlayerStatePause,
    KFAMusicPlayerStateStopped,
};

/**
 播放器播放模式

 - KFAMusicPlayerModeOnce: 单曲只播放一次
 - KFAMusicPlayerModeSingleCycle: 单曲循环
 - KFAMusicPlayerModeOrderCycle: 顺序循环
 - KFAMusicPlayerModeShuffleCycle: 随机循环
 */
typedef NS_ENUM(NSInteger, KFAMusicPlayerMode) {
    KFAMusicPlayerModeOnce,
    KFAMusicPlayerModeSingleCycle,
    KFAMusicPlayerModeOrderCycle,
    KFAMusicPlayerModeShuffleCycle,
};

/**
 错误码

 - KFAMusicPlayerStatesCodeNetUnvailable: 没有网络连接（注意：对于未缓存的网络音频，点击播放时若无网络会返回该状态码,播放时若无网络也会返回该状态码哦。KFAMusicPlayer支持运行时断点续传，即缓冲时网络从无到有，可以断点续传，而某音频没缓冲完就退出app，再进入app没做断点续传）
 - KFAMusicPlayerStatesCodeNetViaWWAN: WWAN网络状态（注意：属性isObserveWWAN（默认NO）为YES时，对于未缓存的网络音频，只在点击该音频时返回该状态码。而音频正在缓冲时，网络状态由wifi到wwan并不会返回该状态码）
 - KFAMusicPlayerStatesCodeTimeOut: 音频请求超时
 - KFAMusicPlayerStatesCodeUnavailableData: 无法获得该音频资源
 - KFAMusicPlayerStatesCodeUnavailableUrl: 无效的URL地址
 - KFAMusicPlayerStatesCodePlayError: 音频无法播放
 - KFAMusicPlayerStatesCodeDataError: 点击的音频ID不在当前数据源里（即数组越界）
 - KFAMusicPlayerStatesCodeCacheFailure: 当前音频缓存失败
 - KFAMusicPlayerStatesCodeCacheSuccess: 当前音频缓存完成
 - KFAMusicPlayerStatesCodeSetLastMusicError: 配置历史音频信息失败
 - KFAMusicPlayerStatesCodeUnknowError: 未知错误
 */
typedef NS_ENUM(NSInteger, KFAMusicPlayerStatesCode) {
    KFAMusicPlayerStatesCodeNetUnvailable        = 0,
    KFAMusicPlayerStatesCodeNetViaWWAN         =  1,
    KFAMusicPlayerStatesCodeTimeOut                 = 2,
    KFAMusicPlayerStatesCodeUnavailableData    = 3,
    KFAMusicPlayerStatesCodeUnavailableUrl       = 4,
    KFAMusicPlayerStatesCodePlayError                = 5,
    KFAMusicPlayerStatesCodeDataError               = 6,
    KFAMusicPlayerStatesCodeCacheFailure          = 7,
    KFAMusicPlayerStatesCodeCacheSuccess       = 8,
    KFAMusicPlayerStatesCodeSetLastMusicError = 9,
    KFAMusicPlayerStatesCodeUnknowError          = 100,
};

@class KFAMusicPlayer;

/**
 播放器数据源
 */
@protocol KFAMusicPlayerDatasource <NSObject>

@required

/**
 播放的音乐列表 用来播放

 @return 播放的音乐列表
 */
- (NSArray<KFAMusicModel *> *)musicListPrepareForPlayer;

@end

/**
 播放器的代理方法
 */
@protocol KFAMusicPlayerDelegate <NSObject>

@optional

/**
 音频即将加入播放队列

 @param player 播放器
 */
- (void)musicWillAddToPlayQueueInPlayer:(KFAMusicPlayer *)player;

/**
 准备播放

 @param player 播放器
 */
- (void)musicReadyToPlayInfPlayer:(KFAMusicPlayer *)player;

/**
 缓冲进度代理 (属性isObserveBufferProgress(默认YES)为YES时有效）

 @param player 播放器
 @param bufferProgress 缓冲进度
 @param totalTime 音频总时长
 */
- (void)player:(KFAMusicPlayer *)player bufferProgress:(CGFloat)bufferProgress totalTime:(CGFloat)totalTime;

/**
 播放进度代理（属性isObserveProgress(默认YES)为YES时有效）

 @param player 播放器
 @param progress 播放进度
 @param currentTime 当前播放到的时间
 @param totalTime 音频总时长
 */
- (void)player:(KFAMusicPlayer *)player progress:(CGFloat)progress currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime;

/**
 播放状态代理

 @param player 播放器
 @param state 播放状态
 */
- (void)player:(KFAMusicPlayer *)player didChangeState:(KFAMusicPlayerState)state;

/**
 播放模式代理

 @param player 播放器
 @param playMode 播放模式
 */
- (void)player:(KFAMusicPlayer *)player didChangePlayMode:(KFAMusicPlayerMode)playMode;

/**
 播放结束代理

 @param player 播放器
 */
- (void)musicDidEndPlayInPlayer:(KFAMusicPlayer *)player;

/**
 播放器状态码改变

 @param player 播放器
 @param statusCode 状态码
 */
- (void)player:(KFAMusicPlayer *)player didChangeStatusCode:(KFAMusicPlayerStatesCode)statusCode;

/**
 播放器被系统打断

 @param player 播放器
 @param isInterrupted 是否被打断 YES-被打断   NO-被系统打断结束
 */
- (void)player:(KFAMusicPlayer *)player isInterrupted:(BOOL)isInterrupted;

/**
 监听耳机插入拔出

 @param player 播放器
 @param isInsertEarphones YES-插入 NO-拔出
 */
- (void)player:(KFAMusicPlayer *)player isInsertEarphones:(BOOL)isInsertEarphones;

@end

/**
 音频播放器
 */
@interface KFAMusicPlayer : NSObject

@property (nonatomic, weak) id<KFAMusicPlayerDelegate> delegate;
@property (nonatomic, weak) id<KFAMusicPlayerDatasource> dataSource;

/// 播放器类型 默认KFAMusicPlayerTypeSoloAmbient
@property (nonatomic, assign) KFAMusicPlayerType type;
/// 播放模式 默认KFAMusicPlayerModeOrderCycle
@property (nonatomic, assign) KFAMusicPlayerMode playMode;
/// 是否监听播放进度 默认YES
@property (nonatomic, assign) BOOL isObserveProgress;
/// 是否监听缓冲进度 默认YES
@property (nonatomic,assign) BOOL isObserveBufferProgress;
/// 是否需要缓存 默认YES
@property (nonatomic, assign) BOOL isNeedCache;
/// 是否接受远程控制
@property (nonatomic, assign) BOOL isRemoteControl;

/**
 KFAMusicPlayerModeOnce（单曲只播放一次）模式下，
 点击下一首(上一首)按钮(或使用线控播放下一首、上一首)，
 YES则播放下一首（上一首），NO则无响应。
 KFAMusicPlayerModeSingleCycle（单曲循环）模式下，
 点击下一首(上一首)按钮(或使用线控播放下一首、上一首)是重新开始播放当前音频还是播放下一首（上一首）
 KFAMusicPlayer默认YES，NO则重新开始播放当前音频
 */
@property (nonatomic, assign) BOOL isManualToPlay;
/**
 当currentAudioModel存在时，是否插入耳机音频自动恢复播放，默认NO
 当您没有实现代理8的情况下，KFAMusicPlayer默认拨出耳机音频自动停止，插入耳机音频不会自动恢复。你可通过此属性控制插入耳机时音频是否可自动恢复
 当您实现代理8时，耳机插入拔出时的播放暂停逻辑由您处理。
 */
@property (nonatomic, assign) BOOL isHeadPhoneAutoPlay;
/**
 是否监测WWAN无线广域网（2g/3g/4g）,默认NO。
 播放本地音频（工程目录和沙盒文件）不监测。
 播放网络音频时，KFAMusicPlayer为您实现wifi下自动播放，无网络有缓存播放缓存，无网络无缓存返回无网络错误码。
 基于播放器具有循环播放的功能，开启该属性，无线广域网（WWAN）网络状态通过代理6返回错误码1。
 */
@property (nonatomic, assign) BOOL isObserveWWAN;
/**
 是否监听服务器文件修改时间，默认NO。
 在播放网络音频且需要KFAMusicPlayer的缓存功能的情况下，开启该属性，不必频繁更换服务端文件名来更新客户端播放内容。
 比如，你的服务器上有audioname.mp3资源，若更改音频内容而需重新上传音频时，您不必更改文件名以保证客户端获取最新资源，本属性为YES即可完成。
 第一次请求某资源时，KFAMusicPlayer缓存文件的同时会记录文件在服务器端的修改时间。
 开启该属性，以后播放该资源时，KFAMusicPlayer会判断服务端文件是否修改过，修改过则加载新资源，没有修改过则播放缓存文件。
 关闭此属性，有缓存时将直接播放缓存，不做更新校验，在弱网环境下播放响应速度更快。但您可自行实现每隔多少天或在哪一天检测的逻辑。
 无网络连接时，有缓存直接播放缓存文件。
 */
@property (nonatomic, assign) BOOL isObserveFileModifiedTime;

/// 播放器状态
@property (nonatomic, assign, readonly) KFAMusicPlayerState state;
/// 当前正在播放的音频
@property (nonatomic, strong, readonly) KFAMusicModel *currentAudioModel;
/// 当前音频缓冲进度
@property (nonatomic, assign, readonly) CGFloat bufferProgress;
/// 当前音频播放进度
@property (nonatomic, readonly, assign) CGFloat progress;
/// 当前音频当前时间
@property (nonatomic, readonly, assign) CGFloat currentTime;
/// 当前音频总时长
@property (nonatomic, readonly, assign) CGFloat totalTime;
/// 上次播放的音频信息。(本地音频或网络音频已缓存时有效)
@property (nonatomic, strong, readonly) KFALastPlayerMusicInfo *lastPlayerMusicInfo;

+ (KFAMusicPlayer *)shareInstance;

/**
 构造播放器
 
 @param userId 用户唯一Id。
 isNeedCache（默认YES）为YES时，若同一设备登录不同账号：
 1.userId存在时，KFAMusicPlayer将为每位用户建立不同的缓存文件目录。例如，user_001,user_002...
 2.userId为nil或@""时，统一使用KFAPlayerCache文件夹下的user_public文件夹作为缓存目录。
 isNeedCache为NO时,userId设置无效，此时不会在沙盒创建缓存目录
 */
- (void)configWithUserId:(NSString *)userId;

/// 刷新数据
- (void)reloadData;

/**
 选择audioId对应的音频开始播放。
 说明：KFAMusicPlayer通过数据源方法提前获取数据，通过playWithAudioId选择对应音频播放。
 而在删除、增加音频后需要调用[[KFAMusicPlayer shareInstance] reloadData];刷新数据。
 KFAMusicPlayer内部实现里做了线程优化，合理范围内的大数据量也毫无压力。
 */
- (void)playWithAudioId:(NSUInteger)audioId;

/// 播放
- (void)play;
/// 暂停
- (void)pause;
/// 下一首
- (void)next;
/// 上一首
- (void)previous;

/**
 设置历史播放信息
 （在合适的时机，调用该方法，将会在本地记录音频URL、当前播放到的时间、音频总时长、播放进度，以供下次继续播放）
 
 @return 是否保存成功
 */
- (BOOL)setPreviousPlayedAudioInfo;
/**
 用历史播放信息配置播放器(数据源中要有该条音频的URL才能配置哦)
 
 @return 是否配置成功
 */
- (BOOL)configPlayerWithPreviousAudioInfo;

/// 实现远程线控功能，需替换main.m中UIApplicationMain函数的第三个参数。
- (NSString *)remoteControlClass;

/// 释放播放器，还原其他播放器
- (void)releasePlayer;

/**
 音频跳转到指定位置

 @param percent 时间百分比
 */
- (void)seek:(CGFloat)percent;

@end

