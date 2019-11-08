//
//  KFAMusicDemoController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/12.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAMusicDemoController.h"
#import "KFAMusicPlayer.h"

@interface KFAMusicDemoController ()<KFAMusicPlayerDelegate,KFAMusicPlayerDatasource>

@property (weak, nonatomic) IBOutlet UIButton *playModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLbl;

@property (nonatomic, copy) NSArray *modelArray;

@end

@implementation KFAMusicDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMusicPlayer];
}

- (void)initMusicPlayer {
    
    KFAMusicPlayer *player = [KFAMusicPlayer shareInstance];
    [player configWithUserId:nil];
    player.dataSource = self;
    player.delegate = self;
    player.type = KFAMusicPlayerTypeSoloAmbient;
    player.isObserveWWAN = YES;
    [player reloadData];
    
    [player setPreviousPlayedAudioInfo];
    
    // 默认开发播放第一手
    [player playWithAudioId:0];
}

#pragma mark - KFAMusicPlayerDatasource

- (NSArray<KFAMusicModel *> *)musicListPrepareForPlayer {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:self.modelArray.count];
    for (NSString *audioUrl in self.modelArray) {
        KFAMusicModel *md = [[KFAMusicModel alloc] init];
        md.audioId = [self.modelArray indexOfObject:audioUrl];
        if ([audioUrl hasPrefix:@"http"]) {
            md.audioUrl = [NSURL URLWithString:audioUrl];
        } else {
            NSString *path = [[NSBundle mainBundle] pathForResource:audioUrl ofType:@"mp3"];
            if (path) {
                md.audioUrl = [NSURL fileURLWithPath:path];
            }
        }
        [arr addObject:md];
    }
    return arr;
}

#pragma mark - KFAMusicPlayerDelegate

- (void)player:(KFAMusicPlayer *)player bufferProgress:(CGFloat)bufferProgress totalTime:(CGFloat)totalTime {
    KFALog(@"缓冲进度");
}

- (void)player:(KFAMusicPlayer *)player progress:(CGFloat)progress currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime {
    KFALog(@"%lf---%lf--%lf",progress,currentTime,totalTime);
    self.slider.value = progress;
    self.currentTimeLbl.text = [NSString stringWithFormat:@"%.2f",currentTime/60.0];
    self.totalTimeLbl.text = [NSString stringWithFormat:@"%.2f",totalTime/60.0];
}

- (void)player:(KFAMusicPlayer *)player didChangeStatusCode:(KFAMusicPlayerStatesCode)statusCode {
    KFALog(@"code: %ld",statusCode);
}

- (void)player:(KFAMusicPlayer *)player didChangeState:(KFAMusicPlayerState)state {
    if (state == KFAMusicPlayerStatePlaying) {
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    } else {
        [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)player:(KFAMusicPlayer *)player didChangePlayMode:(KFAMusicPlayerMode)playMode {
    if (playMode == KFAMusicPlayerModeOnce) {
        [self.playModeBtn setTitle:@"单曲一次" forState:UIControlStateNormal];
    } else if (playMode == KFAMusicPlayerModeSingleCycle) {
        [self.playModeBtn setTitle:@"单曲循环" forState:UIControlStateNormal];
    } else if (playMode == KFAMusicPlayerModeOrderCycle) {
        [self.playModeBtn setTitle:@"顺序播放" forState:UIControlStateNormal];
    } else if (playMode == KFAMusicPlayerModeShuffleCycle) {
        [self.playModeBtn setTitle:@"随机播放" forState:UIControlStateNormal];
    }
}

#pragma mark - Actions

- (IBAction)changePlayMode:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"KFAMusicPlayerModeOnce" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KFAMusicPlayer shareInstance].playMode = KFAMusicPlayerModeOnce;
    }];
    [alert addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"KFAMusicPlayerModeSingleCycle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KFAMusicPlayer shareInstance].playMode = KFAMusicPlayerModeSingleCycle;
    }];
    [alert addAction:action2];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"KFAMusicPlayerModeOrderCycle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KFAMusicPlayer shareInstance].playMode = KFAMusicPlayerModeOrderCycle;
    }];
    [alert addAction:action3];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"KFAMusicPlayerModeShuffleCycle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KFAMusicPlayer shareInstance].playMode = KFAMusicPlayerModeShuffleCycle;
    }];
    [alert addAction:action4];
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"cacel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action5];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)musicList:(id)sender {
}

- (IBAction)previous:(id)sender {
    [[KFAMusicPlayer shareInstance] previous];
}

- (IBAction)playOrPause:(id)sender {
    if ([KFAMusicPlayer shareInstance].state == KFAMusicPlayerStatePlaying) {
        [[KFAMusicPlayer shareInstance] pause];
    } else {
        [[KFAMusicPlayer shareInstance] play];
    }
}

- (IBAction)next:(id)sender {
    [[KFAMusicPlayer shareInstance] next];
}

- (IBAction)sliderAction:(id)sender {
    [[KFAMusicPlayer shareInstance] seek:self.slider.value];
}

#pragma mark - Properties

- (NSArray *)modelArray {
    if (!_modelArray) {
        _modelArray = @[
                        @"http://fs.ios.kugou.com/201907250016/4156fa0afd4eaedd8900add1f8994560/G080/M08/1A/03/MJQEAFhWFyyAQhaqAC-MI-z-Vx8982.mp3",
                        @"http://fs.ios.kugou.com/201907250017/6338bf5c4e68628acd573498da6883de/G009/M00/1F/17/qYYBAFTXM8qAdveMAE9EvYz7R0E659.mp3",
                        @"http://fs.ios.kugou.com/201907250017/43e989db1aa7eee077fccf8bff43266d/G007/M06/03/10/Rw0DAFS5pH-AOPAeADNbtTKnAgw475.mp3",
                        @"http://fs.ios.kugou.com/201907161750/e4e892474ad6fb30400b41ae44006172/G129/M0A/00/1F/YZQEAFpTAUCAaVEGADOLdQKpwCg960.mp3",
                        @"http://fs.ios.kugou.com/201907161643/e58a329442f080b011a9fee1ef3c23b8/G135/M06/17/13/xw0DAFtHOJOACZiNAEUe3eVFTx8339.mp3",
                        @"http://fs.ios.kugou.com/201907161754/1ad4abe8407848bad7e88eddbc6d7f08/G014/M0B/07/01/Tg0DAFUYQO-AR2F0AEo6KmS6Xo4986.mp3",
                        @"张杰-三生三世"];
    }
    return _modelArray;
}

@end
