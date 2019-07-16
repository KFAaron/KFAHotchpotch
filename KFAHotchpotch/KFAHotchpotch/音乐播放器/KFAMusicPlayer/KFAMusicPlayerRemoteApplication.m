//
//  KFAMusicPlayerRemoteApplication.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/15.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMusicPlayerRemoteApplication.h"
#import "KFAMusicPlayer.h"

@implementation KFAMusicPlayerRemoteApplication

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay: // 播放
                [[KFAMusicPlayer shareInstance] play];
                break;
            case UIEventSubtypeRemoteControlPause: // 暂停
                [[KFAMusicPlayer shareInstance] pause];
                break;
            case UIEventSubtypeRemoteControlStop: // 停止
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause: // 播放暂停键切换
            {
                if ([KFAMusicPlayer shareInstance].state == KFAMusicPlayerStatePlaying) {
                    [[KFAMusicPlayer shareInstance] pause];
                } else {
                    [[KFAMusicPlayer shareInstance] play];
                }
            }
                break;
            case UIEventSubtypeRemoteControlNextTrack: // 双击暂停键（下一曲）
                [[KFAMusicPlayer shareInstance] next];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack: // 三击暂停键（上一曲）
                [[KFAMusicPlayer shareInstance] previous];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward: // 三击不松开（快退开始）
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward: // 三击到了快退的位置松开（快退停止）
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward: // 两击不要松开（快进开始）
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward: // 两击到了快进的位置松开（快进停止）
                break;
                
            default:
                break;
        }
    }
}

@end
