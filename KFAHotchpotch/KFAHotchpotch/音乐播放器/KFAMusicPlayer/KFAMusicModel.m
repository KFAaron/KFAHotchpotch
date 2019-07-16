//
//  KFAMusicModel.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/12.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMusicModel.h"
#import "KFAMusicCacheManager.h"

@implementation KFAMusicModel

@end

@implementation KFALastPlayerMusicInfo

- (NSDictionary *)infoDic{
    return [KFAMusicArchiverManager cunarchieInfoModelDictionary];
}

- (NSString *)audioUrlAbsoluteString{
    return [[self infoDic] objectForKey:KFAMusicPlayerCurrentAudioInfoModelAudioUrl];
}
- (CGFloat)currentTime{
    return [[[self infoDic] objectForKey:KFAMusicPlayerCurrentAudioInfoModelCurrentTime] floatValue];
}
- (CGFloat)totalTime{
    return [[[self infoDic] objectForKey:KFAMusicPlayerCurrentAudioInfoModelTotalTime] floatValue];
}
- (CGFloat)progress{
    return [[[self infoDic] objectForKey:KFAMusicPlayerCurrentAudioInfoModelProgress] floatValue];
}

@end
