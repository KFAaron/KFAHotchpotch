//
//  KFAMusicModel.h
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/12.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 音乐信息
 */
@interface KFAMusicModel : NSObject

/// 音频Id。从0开始，仅标识当前音频在数组中的位置
@property (nonatomic, assign) NSUInteger audioId;
/// 音频地址
@property (nonatomic, strong) NSURL *audioUrl;
/// 歌词
@property (nonatomic, copy, nullable) NSString *audioLyric;
/// 歌名
@property (nonatomic, copy, nullable) NSString *audioName;
/// 专辑名
@property (nonatomic, copy, nullable) NSString *audioAlbum;
/// 歌手名
@property (nonatomic, copy, nullable) NSString *audioSinger;
/// 歌曲配图
@property (nonatomic, copy, nullable) NSString *audioImage;

@end

/**
 上次播放的音乐信息
 */
@interface KFALastPlayerMusicInfo : NSObject

/**网络音频地址或本地音频名*/
@property (nonatomic, readonly, nonnull, copy) NSString *audioUrlAbsoluteString;
/**音频总时长*/
@property (nonatomic, readonly, assign) CGFloat totalTime;
/**以下属性只有缓存过或者本地音频才会配置该属性 */
/**音频当前播放到的时间*/
@property (nonatomic, readonly, assign) CGFloat currentTime;
/**音频播放进度*/
@property (nonatomic, readonly, assign) CGFloat progress;

@end

NS_ASSUME_NONNULL_END
