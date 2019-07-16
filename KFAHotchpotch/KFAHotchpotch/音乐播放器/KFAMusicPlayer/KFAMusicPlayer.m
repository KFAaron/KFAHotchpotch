//
//  KFAMusicPlayer.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/12.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMusicPlayer.h"
#import "KFAMusicPlayerRemoteApplication.h"
#import "KFAMusicCacheManager.h"
#import "KFAMusicPlayerTool.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KFAMusicPlayerResourceLoader.h"

/**类型KEY*/
NSString * const KFAPlayerModeKey                = @"KFAPlayerMode";
/**Asset KEY*/
NSString * const KFAPlayableKey                  = @"playable";
/**PlayerItem KEY*/
NSString * const KFAStatusKey                    = @"status";
NSString * const KFALoadedTimeRangesKey          = @"loadedTimeRanges";
NSString * const KFAPlaybackBufferEmptyKey       = @"playbackBufferEmpty";
NSString * const KFAPlaybackLikelyToKeepUpKey    = @"playbackLikelyToKeepUp";

@interface KFAMusicPlayer () <KFAMusicPlayerResourceLoaderDelegate>

/**其他应用是否正在播放*/
@property (nonatomic, assign) BOOL isOthetPlaying;
/**是否正在播放*/
@property (nonatomic, assign) BOOL isPlaying;
/**是否进入后台*/
@property (nonatomic, assign) BOOL isBackground;
/**组队列-网络*/
@property (nonatomic, strong) dispatch_group_t  netGroupQueue;
/**组队列-数据*/
@property (nonatomic, strong) dispatch_group_t  dataGroupQueue;
/**HIGH全局并发队列*/
@property (nonatomic, strong) dispatch_queue_t  HighGlobalQueue;
/**DEFAULT全局并发队列*/
@property (nonatomic, strong) dispatch_queue_t  defaultGlobalQueue;
/**player*/
@property (nonatomic, strong) AVPlayer *player;
/**playerItem*/
@property (nonatomic, strong) AVPlayerItem *playerItem;
/**播放进度监测*/
@property (nonatomic, strong) id  timeObserver;
/**当前正在播放的音频Id*/
@property (nonatomic, assign) NSInteger currentAudioTag;
/**随机数组*/
@property (nonatomic, strong) NSMutableArray *randomIndexArray;
/**随机数组元素index*/
@property (nonatomic, assign) NSInteger  randomIndex;
/**播放顺序标识*/
@property (nonatomic, assign) NSInteger playIndex1;
/**播放顺序标识*/
@property (nonatomic, assign) NSInteger playIndex2;
/**播放进度是否被拖拽了*/
@property (nonatomic, assign) BOOL isDraged;
/**当前音频是否缓存*/
@property (nonatomic, assign) BOOL isCached;
/**seek 等待*/
@property (nonatomic, assign) BOOL isSeekWaiting;
/**seek value*/
@property (nonatomic, assign) CGFloat seekValue;
/**是否是自然结束*/
@property (nonatomic, assign) BOOL isNaturalToEndTime;
/**音频信息model*/
@property (nonatomic, strong) KFAMusicModel *currentAudioModel;
/**历史model*/
@property (nonatomic, strong) KFALastPlayerMusicInfo *lastPlayerMusicInfo;
/**资源下载器*/
@property (nonatomic, strong) KFAMusicPlayerResourceLoader *resourceLoader;
/**model数据数组*/
@property (nonatomic, strong) NSMutableArray<KFAMusicModel *>   *playerModelArray;
/**工具类*/
@property (nonatomic, strong) KFAMusicPlayerTool *tool;
/**配置历史音频信息标记1*/
@property (nonatomic, assign) BOOL isSettingPreviousAudioModel;

@end

@implementation KFAMusicPlayer

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (KFAMusicPlayer *)shareInstance {
    static KFAMusicPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[KFAMusicPlayer alloc] init];
    });
    return player;
}

- (void)configWithUserId:(NSString *)userId {
    [KFAMusicCacheManager createMusicCachePathWithUserId:userId];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    
    self.isOthetPlaying = [AVAudioSession sharedInstance].isOtherAudioPlaying;
    NSUInteger user_playerMode = [[NSUserDefaults standardUserDefaults] integerForKey:KFAPlayerModeKey];
    self.playMode = user_playerMode?user_playerMode:KFAMusicPlayerModeOrderCycle;
    self.state = KFAMusicPlayerStateStopped;
    self.isObserveProgress = YES;
    self.isObserveBufferProgress = YES;
    self.isNeedCache = YES;
    self.isRemoteControl = YES;
    self.isObserveFileModifiedTime = NO;
    self.isHeadPhoneAutoPlay = NO;
    self.isObserveWWAN = NO;
    self.isBackground = NO;
    self.isCached = NO;
    self.isManualToPlay = YES;
    self.randomIndex = -1;
    self.playIndex2 = 0;
    
    // 添加观察者
    [self addPlayerObserver];
}

#pragma mark - Notification

- (void)addPlayerObserver {
    self.defaultGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.HighGlobalQueue    = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    self.netGroupQueue      = dispatch_group_create();
    self.dataGroupQueue     = dispatch_group_create();
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_group_enter(self.netGroupQueue);
    });
    dispatch_group_async(self.netGroupQueue, self.defaultGlobalQueue, ^{
        self.tool = [KFAMusicPlayerTool shareInstance];
        [self.tool startMonitoringNetworkStatus:^{
            static dispatch_once_t onceToken1;
            dispatch_once(&onceToken1, ^{
                dispatch_group_leave(self.netGroupQueue);
            });
        }];
    });
    
    //将要进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kfa_playerWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    //已经进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kfa_playerDidEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    //监测耳机
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kfa_playerAudioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    //监听播放器被打断（别的软件播放音乐，来电话）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kfa_playerAudioBeInterrupted:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //监测其他app是否占据AudioSession
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kfa_playerSecondaryAudioHint:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:nil];
    //播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPrePlayToLoadPreviousAudio) name:KFAMusicPlayerCurrentAudioInfoModelPlayNotificationKey object:nil];
}

- (void)kfa_playerDidEnterForeground {
    self.isBackground = NO;
}

- (void)kfa_playerWillResignActive{
    self.isBackground = YES;
}

- (void)kfa_playerAudioRouteChange:(NSNotification *)notification {
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable://耳机插入
            if (self.delegate && [self.delegate respondsToSelector:@selector(player:isInsertEarphones:)]) {
                [self.delegate player:self isInsertEarphones:YES];
            } else {
                if (self.isHeadPhoneAutoPlay && self.currentAudioModel) {
                    [self play];
                }
            }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable://耳机拔出，停止播放操作
            if (self.delegate && [self.delegate respondsToSelector:@selector(player:isInsertEarphones:)]) {
                [self.delegate player:self isInsertEarphones:NO];
            } else {
                [self pause];
            }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            //
            break;
        default:
            break;
    }
}

- (void)kfa_playerAudioBeInterrupted:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    if ([dic[AVAudioSessionInterruptionTypeKey] integerValue] == 1) {//打断开始
        KFALog(@"-- KFAMusicPlayer： 音频被打断开始，并记录了播放信息");
        [self setPreviousPlayedAudioInfo];//打断时也要记录信息
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:isInterrupted:)]) {
            [self.delegate player:self isInterrupted:YES];
        }else{
            [self pause];
        }
    } else {//打断结束
        KFALog(@"-- KFAMusicPlayer： 音频被打断结束");
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:isInterrupted:)]) {
            [self.delegate player:self isInterrupted:NO];
        }else{
            if ([notification.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue] == 1) {
                KFALog(@"-- KFAMusicPlayer： 能够恢复播放");
                [self play];
            }
        }
    }
}

- (void)kfa_playerSecondaryAudioHint:(NSNotification *)notification {
    NSInteger type = [notification.userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] integerValue];
    if (type == 1) { // 开始被其他音频占据
        KFALog(@"-- KFAMusicPlayer： 其他音频占据开始");
    } else { // 占据结束
        KFALog(@"-- KFAMusicPlayer： 其他音频占据结束");
    }
}

- (void)kfa_playerDidPlayToEndTime:(NSNotification *)notification {
    self.isNaturalToEndTime = YES;
    [self next];
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicDidEndPlayInPlayer:)]) {
        [self.delegate musicDidEndPlayInPlayer:self];
    }
}

#pragma mark - 资源准备

- (void)audioPrePlayToLoadPreviousAudio {
    if (self.isSettingPreviousAudioModel) {
        [self audioPrePlayToLoadAudio];
    }
}

- (void)audioPrePlayToLoadAudio {
    // 音频地址安全性判断
    NSURL *currentAudioUrl;
    if ([self.currentAudioModel.audioUrl isKindOfClass:[NSURL class]]) {
        currentAudioUrl = self.currentAudioModel.audioUrl;
    } else {
        KFALog(@"-- KFAMusicPlayer:音频地址错误，支持NSURL类型");
        return;
    }
    // 播放本地音频
    if ([KFAMusicPlayerTool isLocalWithUrl:currentAudioUrl]) {
        KFALog(@"-- KFAMusicPlayer： 播放本地音频");
        [self loadPlayerWithItemUrl:currentAudioUrl];
        self.isCached = YES;
    } else { // 播放网络音频
        NSString *cacheFilePath = [KFAMusicCacheManager checkAudioCacheExistWithAudioUrl:currentAudioUrl];
        KFALog(@"-- KFAMusicPlayer： 是否有缓存：%@",cacheFilePath?@"有":@"无");
        self.isCached = cacheFilePath?YES:NO;
        [self loadPlayerItemWithUrl:currentAudioUrl cacheFilePath:cacheFilePath];
    }
}

- (void)loadPlayerItemWithUrl:(NSURL *)currentAudioUrl cacheFilePath:(NSString *)cacheFilePath {
    dispatch_group_notify(self.netGroupQueue, self.defaultGlobalQueue, ^{
        // 如果监听WWAN，本地无缓存，网络状态是WWAN，三种情况同时存在时发起代理8
        if (self.isObserveWWAN && !cacheFilePath &&
            self.tool.networkStatus == KFAMusicPlayerNetWorkStatusReachableViaWWAN){
            [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeNetViaWWAN];
        } else {
            // 加载音频
            if (self.tool.networkStatus == KFAMusicPlayerNetWorkStatusUnknown || self.tool.networkStatus == KFAMusicPlayerNetWorkStatusNotReachable) { // 无网络
                if (cacheFilePath){//无网络 有缓存，播放缓存
                    [self loadPlayerWithItemUrl:[NSURL fileURLWithPath:cacheFilePath]];
                } else {//无网络 无缓存，提示联网
                    [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeNetUnvailable];
                }
            } else { // 有网络
                if (!self.isNeedCache){ // 不需要缓存
                    [self loadPlayerWithItemUrl:currentAudioUrl];
                } else { // 需要缓存
                    if (cacheFilePath && !self.isObserveFileModifiedTime) { // 有缓存且不监听改变时间，直接播放缓存
                        [self loadPlayerWithItemUrl:[NSURL fileURLWithPath:cacheFilePath]];
                    } else { // 无缓存 或 需要兼听
                        [self loadNetAudioWithUrl:currentAudioUrl cacheFilePath:cacheFilePath];
                    }
                }
            }
        }
    });
}

- (void)loadNetAudioWithUrl:(NSURL *)currentAudioUrl cacheFilePath:(NSString *)cacheFilePath {
    if (self.resourceLoader) {
        [self.resourceLoader stopLoading];
    }
    self.resourceLoader = [[KFAMusicPlayerResourceLoader alloc] init];
    self.resourceLoader.delegate = self;
    NSURL *customUrl = [KFAMusicPlayerTool customUrlWithUrl:currentAudioUrl];
    if (!customUrl) {
        [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeUnavailableUrl];
        return;
    }
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:customUrl options:nil];
    [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
    [asset loadValuesAsynchronouslyForKeys:@[KFAPlayableKey] completionHandler:^{
        dispatch_async( dispatch_get_main_queue(),^{
            if (!asset.playable) {
                [self.resourceLoader stopLoading];
                self.state = KFAMusicPlayerStateFailed;
                [asset cancelLoading];
            }
        });
    }];
    self.resourceLoader.isHaveCache = cacheFilePath?YES:NO;
    self.resourceLoader.isObserveFileModifiedTime = self.isObserveFileModifiedTime;

    @kfa_weakify(self);
    self.resourceLoader.checkStatusBlock = ^(NSInteger statusCode) {
        @kfa_strongify(self);
        if (statusCode == 200) {
            self.bufferProgress = 0;
            [self loadPlayerWithAsset:asset];
        } else if (statusCode == 304) {
            KFALog(@"-- KFAMusicPlayer： 服务器音频资源未更新，播放本地");
            [self loadPlayerWithItemUrl:[NSURL fileURLWithPath:cacheFilePath]];
        } else if (statusCode == 206) {

        } else {
            self.progress = self.bufferProgress = self.currentTime = self.totalTime = .0f;
            if (self.player) {
                self.player = nil;
            }
            [self.player.currentItem cancelPendingSeeks];
            [self.player.currentItem.asset cancelLoading];
            [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeUnavailableData];
        }
    };
}

- (void)loadPlayerWithAsset:(AVURLAsset *)asset{
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self loadPlayer];
}

- (void)loadPlayerWithItemUrl:(NSURL *)url {
    self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
    [self loadPlayer];
}

- (void)loadPlayer {
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    // 监听播放进度
    if (self.isObserveProgress) {
        [self addPlayProgressTimeObserver];
    }
    // 设置锁屏和控制中心音频信心
    [self addInformationOfLockScreen];
    
    [self play];
}

// 锁屏、后台模式信心
- (void)addInformationOfLockScreen {
    if (!self.currentAudioModel.audioName &&
        !self.currentAudioModel.audioAlbum &&
        !self.currentAudioModel.audioSinger &&
        !self.currentAudioModel.audioImage) {
        return;
    }
    MPNowPlayingInfoCenter *playInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.currentAudioModel.audioName) {
        dic[MPMediaItemPropertyTitle] = self.currentAudioModel.audioName;
    }
    if (self.currentAudioModel.audioAlbum) {
        dic[MPMediaItemPropertyAlbumTitle] = self.currentAudioModel.audioAlbum;
    }
    if (self.currentAudioModel.audioSinger) {
        dic[MPMediaItemPropertyArtist] = self.currentAudioModel.audioSinger;
    }
    dic[MPNowPlayingInfoPropertyPlaybackRate] = [NSNumber numberWithFloat:1.0];
    if ([self.currentAudioModel.audioImage isKindOfClass:[UIImage class]] && self.currentAudioModel.audioImage) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.currentAudioModel.audioImage];
        dic[MPMediaItemPropertyArtwork] = artwork;
    }
    playInfoCenter.nowPlayingInfo = dic;
}

#pragma mark - KFAMusicPlayerResourceLoaderDelegate

/**下载出错*/
- (void)loader:(KFAMusicPlayerResourceLoader *)loader requestError:(NSInteger)errorCode{
    if (errorCode == NSURLErrorTimedOut) {
        [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeTimeOut];
    }else if (self.tool.networkStatus == KFAMusicPlayerNetWorkStatusNotReachable) {
        [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeNetUnvailable];
    }
}
/**是否完成缓存*/
- (void)loader:(KFAMusicPlayerResourceLoader *)loader isCached:(BOOL)isCached{
    self.isCached = isCached;
    NSUInteger status = isCached?KFAMusicPlayerStatesCodeCacheSuccess:KFAMusicPlayerStatesCodeCacheFailure;
    [self playerStatusWithStatusCode:status];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:KFAStatusKey]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerItemStatusUnknown: //未知错误
                    self.state = KFAMusicPlayerStateFailed;
                    self.isSettingPreviousAudioModel = NO;
                    [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeUnknowError];
                    break;
                case AVPlayerItemStatusReadyToPlay://准备播放
                    [self setPlayerSeekTotimeWithPreviousAudioModel];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(musicReadyToPlayInfPlayer:)]) {
                        [self.delegate musicReadyToPlayInfPlayer:self];
                    }
                    break;
                case AVPlayerItemStatusFailed://准备失败.
                    self.state = KFAMusicPlayerStateFailed;
                    self.isSettingPreviousAudioModel = NO;
                    [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodePlayError];
                    break;
                default:
                    break;
            }
        } else if ([keyPath isEqualToString:KFALoadedTimeRangesKey]) {
            self.totalTime = CMTimeGetSeconds(self.playerItem.duration);
            if (self.isObserveBufferProgress) {//缓冲进度
                [self addBufferProgressObserver];
            }
        } else if ([keyPath isEqualToString:KFAPlaybackBufferEmptyKey]) {
            if (self.playerItem.playbackBufferEmpty) {//当缓冲是空的时候
                self.state = KFAMusicPlayerStateBuffering;
            }
        } else if ([keyPath isEqualToString:KFAPlaybackLikelyToKeepUpKey]) {
            NSLog(@"-- KFAMusicPlayer： 缓冲达到可播放");
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/**缓冲进度*/
- (void)addBufferProgressObserver{
    CMTimeRange timeRange   = [self.playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
    CGFloat startSeconds    = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    if (self.totalTime != 0) {//避免出现inf
        self.bufferProgress = (startSeconds + durationSeconds) / self.totalTime;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(player:bufferProgress:totalTime:)]) {
        [self.delegate player:self bufferProgress:self.bufferProgress totalTime:self.totalTime];
    }
    
    if (self.isSeekWaiting) {
        if (self.bufferProgress > self.seekValue) {
            self.isSeekWaiting = NO;
            [self didSeekToTimeWithValue:self.seekValue];
        }
    }
}

// 播放进度
- (void)addPlayProgressTimeObserver {
    @kfa_weakify(self);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        @kfa_strongify(self);
        AVPlayerItem *currentItem = self.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0){
            CGFloat currentT = (CGFloat)CMTimeGetSeconds(time);
            if (!self.isDraged) {
                self.currentTime = currentT;
            }
            if (self.totalTime != 0) {//避免出现inf
                self.progress = CMTimeGetSeconds([currentItem currentTime]) / self.totalTime;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(player:progress:currentTime:totalTime:)]) {
                [self.delegate player:self progress:self.progress currentTime:currentT totalTime:self.totalTime];
            }
            if (self.isBackground) {
                [self updatePlayingCenterInfo];
            }
        }
    }];
}

- (void)didSeekToTimeWithValue:(CGFloat)value{
    if (self.state == KFAMusicPlayerStatePlaying || self.state == KFAMusicPlayerStatePause) {
        // 跳转
        [self.player seekToTime:CMTimeMake(floorf(self.totalTime * value), 1) toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            if (finished) {
                [self play];
                self.isDraged = NO;
            }
        }];
    } else if (self.state == KFAMusicPlayerStateStopped){
        [self audioPrePlayToLoadPreviousAudio];
        self.progress = value;
    }
}

- (void)updatePlayingCenterInfo {
    NSDictionary *info=[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
    dic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithDouble:CMTimeGetSeconds(self.playerItem.currentTime)];
    dic[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithDouble:CMTimeGetSeconds(self.playerItem.duration)];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}

#pragma mark - PublicMethods
// 刷新数据
- (void)reloadData {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(musicListPrepareForPlayer)]) {
        if (!self.playerModelArray) {
            self.playerModelArray = [NSMutableArray array];
        }
        if (self.playerModelArray.count != 0) {
            [self.playerModelArray removeAllObjects];
        }
        dispatch_group_enter(self.dataGroupQueue);
        dispatch_group_async(self.dataGroupQueue, self.HighGlobalQueue, ^{
            dispatch_async(self.HighGlobalQueue, ^{
                [self.playerModelArray addObjectsFromArray:[self.dataSource musicListPrepareForPlayer]];
                
                //更新数据时更新audioId
                if (self.currentAudioModel.audioUrl) {
                    [self.playerModelArray enumerateObjectsWithOptions:(NSEnumerationConcurrent) usingBlock:^(KFAMusicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.audioUrl.absoluteString isEqualToString:self.currentAudioModel.audioUrl.absoluteString]) {
                            self.currentAudioModel.audioId = idx;
                            self.currentAudioTag = idx;
                            *stop = YES;
                        }
                    }];
                    //更新随机数组
                    [self updateRandomIndexArray];
                }
                //通知完成
                dispatch_group_leave(self.dataGroupQueue);
            });
        });
    }else{
        NSLog(@"-- KFAMusicPlayer：请实现musicListPrepareForPlayer数据源方法");
    }
}
// 更新随机播放数组
- (void)updateRandomIndexArray {
    if (self.randomIndexArray.count != 0) {
        [self.randomIndexArray removeAllObjects];
        self.randomIndexArray = [NSMutableArray arrayWithArray:[self getRandomPlayerModelIndexArray]];
    }
}

- (NSMutableArray *)getRandomPlayerModelIndexArray {
    NSInteger startIndex = 0;
    NSInteger length = self.playerModelArray.count;
    NSInteger endIndex = startIndex+length;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:length];
    NSMutableArray *arr1 = [NSMutableArray arrayWithCapacity:length];
    @autoreleasepool{
        for (NSInteger i = startIndex; i < endIndex; i++) {
            [arr1 addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        for (NSInteger i = startIndex; i < endIndex; i++) {
            int index = arc4random()%arr1.count;
            int radom = [arr1[index] intValue];
            NSNumber *num = [NSNumber numberWithInt:radom];
            [arr addObject:num];
            [arr1 removeObjectAtIndex:index];
        }
    }
    return arr;
}

// 选择audioId对应的音频开始播放
- (void)playWithAudioId:(NSUInteger)audioId {
    dispatch_group_notify(self.dataGroupQueue, self.HighGlobalQueue, ^{
        if (self.playerModelArray.count > audioId) {
            self.currentAudioModel = self.playerModelArray[audioId];
            NSLog(@"-- KFAMusicPlayer： 点击了音频Id:%ld",(unsigned long)self.currentAudioModel.audioId);
            self.currentAudioTag = audioId;
            [self audioPrePlay];
        }else{
            [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeDataError];
        }
    });
}

// 预播放
- (void)audioPrePlay {
    //移除进度观察者
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    //重置进度和时间
    self.progress = self.bufferProgress = self.currentTime = self.totalTime = .0f;
    self.isSeekWaiting  = NO;
    self.isSettingPreviousAudioModel = NO;
    
    [self audioPrePlayToResetAudio];
    [self audioPrePlayToLoadAudio];
}

// 重置音频信息
- (void)audioPrePlayToResetAudio {
    // 暂停播放
    if (self.isPlaying) {
        [self pause];
    }
    // 移除进度观察者
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    // 音频将要加入播放队列
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicWillAddToPlayQueueInPlayer:)]) {
        [self.delegate musicWillAddToPlayQueueInPlayer:self];
    }
}

- (void)play {
    if (!self.isPlaying) {
        self.isPlaying = YES;
        self.state = KFAMusicPlayerStatePlaying;
    }
    [self.player play];
}

- (void)pause {
    if (self.isPlaying) {
        self.isPlaying = NO;
        self.state = KFAMusicPlayerStatePause;
    }
    [self.player pause];
}

- (void)next {
    switch (self.playMode) {
        case KFAMusicPlayerModeOnce:
            if (self.isNaturalToEndTime) {
                self.isNaturalToEndTime = NO;
                [self pause];
            } else {
                if (self.isManualToPlay) {
                    [self audioNextOrderCycle];
                }
            }
            break;
        case KFAMusicPlayerModeSingleCycle:
            /**解释：单曲循环模式下，如果是自动播放结束，则单曲循环。
             如果手动控制播放下一首或上一首，则根据isManualToPlay的设置判断播放下一首还是重新播放*/
            if (self.isNaturalToEndTime) {
                self.isNaturalToEndTime = NO;
                [self audioPrePlay];
            } else {
                if (self.isManualToPlay) {
                    [self audioNextOrderCycle];
                } else {
                    [self audioPrePlay];
                }
            }
            break;
        case KFAMusicPlayerModeOrderCycle:
            [self audioNextOrderCycle];
            break;
        case KFAMusicPlayerModeShuffleCycle:{
            self.playIndex2++;
            NSInteger tag = [self audioNextShuffleCycleIndex];
            //去重 避免随机到当前正在播放的音频
            if (tag == self.currentAudioTag) {
                tag = [self audioNextShuffleCycleIndex];
            }
            self.currentAudioTag = tag;
            self.currentAudioModel = self.playerModelArray[self.currentAudioTag];
            [self audioPrePlay];
            break;
        }
        default:
            break;
    }
}

- (void)previous {
    switch (self.playMode) {
        case KFAMusicPlayerModeOnce:
            if (self.isManualToPlay) {
                [self audioLastOrderCycle];
            } else {
                [self pause];
            }
            break;
        case KFAMusicPlayerModeSingleCycle:
            if (self.isManualToPlay) {
                [self audioLastOrderCycle];
            }else{
                [self audioPrePlay];
            }
            break;
        case KFAMusicPlayerModeOrderCycle:
            [self audioLastOrderCycle];
            break;
        case KFAMusicPlayerModeShuffleCycle:{
            if (self.playIndex2 == 1) {
                self.playIndex2 = 0;
                self.currentAudioModel = self.playerModelArray[self.playIndex1];
            } else {
                NSInteger tag = [self audioLastShuffleCycleIndex];
                //去重 避免随机到当前正在播放的音频
                if (tag == self.currentAudioTag) {
                    tag = [self audioLastShuffleCycleIndex];
                }
                self.currentAudioTag = tag;
                self.currentAudioModel = self.playerModelArray[self.currentAudioTag];
            }
            [self audioPrePlay];
            break;
        }
        default:
            break;
    }
}

- (NSString *)remoteControlClass {
    return NSStringFromClass([KFAMusicPlayerRemoteApplication class]);
}

- (void)releasePlayer {
    [self pause];
    //解除激活,并还原其他应用播放器声音
    if (self.resourceLoader) {
        [self.resourceLoader stopLoading];
    }
    if (self.isOthetPlaying) {
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    } else {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    if (self.player) {
        self.player = nil;
    }
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
}

- (void)seek:(CGFloat)percent {
    self.isDraged = YES;
    // 先暂停
    [self pause];
    if (self.bufferProgress < percent) {
        self.isSeekWaiting = YES;
        self.seekValue = percent;
        if (self.isSettingPreviousAudioModel) {
            [self audioPrePlayToLoadPreviousAudio];
            self.progress = percent;
        }
    } else {
        self.isSeekWaiting = NO;
        [self didSeekToTimeWithValue:percent];
    }
}

- (void)audioNextOrderCycle{
    self.currentAudioTag++;
    if (self.currentAudioTag < 0 || self.currentAudioTag >= self.playerModelArray.count) {
        self.currentAudioTag = 0;
    }
    self.playIndex1 = self.currentAudioTag;
    self.playIndex2 = 0;
    self.currentAudioModel = self.playerModelArray[self.currentAudioTag];
    [self audioPrePlay];
}
- (void)audioLastOrderCycle{
    self.currentAudioTag--;
    if (self.currentAudioTag < 0) {
        self.currentAudioTag = self.playerModelArray.count-1;
    }
    self.currentAudioModel = self.playerModelArray[self.currentAudioTag];
    [self audioPrePlay];
}

//下一首随机index
- (NSInteger)audioNextShuffleCycleIndex{
    self.randomIndex++;
    if (self.randomIndex >= self.randomIndexArray.count) {
        self.randomIndex = 0;
    }
    NSInteger tag = [self.randomIndexArray[self.randomIndex] integerValue];
    return tag;
}
//上一首随机index
- (NSInteger)audioLastShuffleCycleIndex{
    self.randomIndex--;
    if (self.randomIndex < 0) {
        self.randomIndex = self.randomIndexArray.count-1;
    }
    NSInteger tag = [self.randomIndexArray[self.randomIndex] integerValue];
    return tag;
}

#pragma mark - 记录播放信息和配置播放器

- (BOOL)setPreviousPlayedAudioInfo {
    if (self.currentAudioModel) {
        BOOL isSuccess = [KFAMusicArchiverManager archiveInfoModelWithAudioUrl:self.currentAudioModel.audioUrl currentTime:self.currentTime totalTime:self.totalTime progress:self.progress];
        if (isSuccess) {
            KFALog(@"播放信息保存完成");
            return YES;
        }
    }
    KFALog(@"播放信息保存失败~");
    return NO;
}
// 用lastPlayerMusicInfo配置播放器数据
- (BOOL)configPlayerWithPreviousAudioInfo {
    self.lastPlayerMusicInfo = [[KFALastPlayerMusicInfo alloc] init];
    if (self.lastPlayerMusicInfo.audioUrlAbsoluteString) {
        __block BOOL isHave = NO;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_group_notify(self.dataGroupQueue, self.HighGlobalQueue, ^{
            isHave = [self private_configPlayerWithPreviousAudioInfo];
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (!isHave) {
            KFALog(@"-- KFAMusicPlayer： 当前数据源中不存在此数据，无法配置");
            [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeSetLastMusicError];
        }
        return isHave;
    } else {
        KFALog(@"-- KFAMusicPlayer： 存于沙盒的历史音频url已被清除，无法配置");
        [self playerStatusWithStatusCode:KFAMusicPlayerStatesCodeSetLastMusicError];
        return NO;
    }
}

- (void)playerStatusWithStatusCode:(NSUInteger)statusCode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(player:didChangeStatusCode:)]) {
        [self.delegate player:self didChangeStatusCode:statusCode];
    }
}

// 配置历史音频信息
- (BOOL)private_configPlayerWithPreviousAudioInfo {
    __block BOOL isHave = NO;
    [self.playerModelArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(KFAMusicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 判断数据源中是否有lastPlayerMusicInfo种的url
        NSString *urlStr = self.lastPlayerMusicInfo.audioUrlAbsoluteString;
        if ([KFAMusicPlayerTool isLocalWithUrlString:urlStr]) { // 本地
            if ([urlStr isEqualToString:obj.audioUrl.absoluteString.lastPathComponent]) {
                urlStr = [urlStr stringByRemovingPercentEncoding];
                NSString *path = [[NSBundle mainBundle] pathForResource:urlStr ofType:@""];
                if (path) {
                    isHave = YES;
                    NSURL *url = [NSURL fileURLWithPath:path];
                    [self setCurrentAudioModelWithPreviousAudioModelUrl:url audioId:idx];
                }
                *stop = YES;
            }
        } else { //
            if ([urlStr isEqualToString:obj.audioUrl.absoluteString]) {
                isHave = YES;
                NSURL *url = [NSURL URLWithString:urlStr];
                [self setCurrentAudioModelWithPreviousAudioModelUrl:url audioId:idx];
                *stop = YES;
            }
        }
    }];
    return isHave;
}

- (void)setCurrentAudioModelWithPreviousAudioModelUrl:(NSURL *)audioUrl audioId:(NSUInteger)audioId {
    self.isSettingPreviousAudioModel = YES;
    self.currentAudioModel = [[KFAMusicModel alloc] init];
    self.currentAudioModel.audioUrl = audioUrl;
    self.currentAudioModel.audioId = audioId;
    self.currentAudioTag = audioId;
    self.totalTime = self.lastPlayerMusicInfo.totalTime;
    NSString *cacheFilePath = [KFAMusicCacheManager checkAudioCacheExistWithAudioUrl:audioUrl];
    if (cacheFilePath || [KFAMusicPlayerTool isLocalWithUrl:audioUrl]) {
        self.progress = self.lastPlayerMusicInfo.progress;
        self.currentTime = self.lastPlayerMusicInfo.currentTime;
        self.bufferProgress = 1;
    } else {
        self.progress = self.bufferProgress = self.currentTime = .0f;
    }
    // 获取音频信息
    [self audioPrePlayToResetAudio];
}

// 配置历史音频进度
- (void)setPlayerSeekTotimeWithPreviousAudioModel {
    if (self.isSettingPreviousAudioModel) {
        self.isSettingPreviousAudioModel = NO;
        [self.player seekToTime:CMTimeMake(floorf(self.totalTime * self.progress), 1) toleranceBefore:(CMTimeMake(1, 1)) toleranceAfter:(CMTimeMake(1, 1)) completionHandler:^(BOOL finished) {
            if (finished) {
                self.isDraged = NO;
            }
        }];
    }
}

#pragma mark - Properties

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {
        return;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_playerItem removeObserver:self forKeyPath:KFAStatusKey];
        [_playerItem removeObserver:self forKeyPath:KFALoadedTimeRangesKey];
        [_playerItem removeObserver:self forKeyPath:KFAPlaybackBufferEmptyKey];
        [_playerItem removeObserver:self forKeyPath:KFAPlaybackLikelyToKeepUpKey];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kfa_playerDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [playerItem addObserver:self forKeyPath:KFAStatusKey options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:KFALoadedTimeRangesKey options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:KFAPlaybackBufferEmptyKey options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:KFAPlaybackLikelyToKeepUpKey options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setType:(KFAMusicPlayerType)type {
    _type = type;
    switch (type) {
        case KFAMusicPlayerTypeAmbient:
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
            break;
        case KFAMusicPlayerTypeSoloAmbient:
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
            break;
        case KFAMusicPlayerTypePlayback:
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            break;
        case KFAMusicPlayerTypePlayAndRecord:
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
            break;
        case KFAMusicPlayerTypeMultiRoute:
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
            break;
        default:
            break;
    }
}

- (void)setPlayMode:(KFAMusicPlayerMode)playMode {
    _playMode = playMode;
    
    [[NSUserDefaults standardUserDefaults] setInteger:playMode forKey:KFAPlayerModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:didChangePlayMode:)]) {
            [self.delegate player:self didChangePlayMode:playMode];
        }
    });
}

- (void)setIsRemoteControl:(BOOL)isRemoteControl {
    _isRemoteControl = isRemoteControl;
    if (_isRemoteControl) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }else{
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    }
}

- (void)setState:(KFAMusicPlayerState)state {
    _state = state;
    
    // 回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:didChangeState:)]) {
            [self.delegate player:self didChangeState:state];
        }
    });
}

- (void)setCurrentAudioModel:(KFAMusicModel *)currentAudioModel {
    _currentAudioModel = currentAudioModel;
}

- (void)setBufferProgress:(CGFloat)bufferProgress {
    _bufferProgress = bufferProgress;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
}

- (void)setCurrentTime:(CGFloat)currentTime {
    _currentTime = currentTime;
}

- (void)setTotalTime:(CGFloat)totalTime {
    _totalTime = totalTime;
}

- (NSMutableArray *)randomIndexArray{
    if (!_randomIndexArray) {
        _randomIndexArray = [NSMutableArray arrayWithArray:[self getRandomPlayerModelIndexArray]];
    }
    return _randomIndexArray;
}

@end
