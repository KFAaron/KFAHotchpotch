//
//  KFAAccelerometerController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2020/3/21.
//  Copyright © 2020 KFAaron. All rights reserved.
//

#import "KFAAccelerometerController.h"
#import <CoreMotion/CoreMotion.h>

@interface KFAAccelerometerController ()<UIAccelerometerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *xlabel;
@property (weak, nonatomic) IBOutlet UILabel *ylabel;
@property (weak, nonatomic) IBOutlet UILabel *zlabel;

@end

@implementation KFAAccelerometerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 距离传感器 检测有物理在靠近或者远离屏幕
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateDidChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
//    [self motionPush];
    
//    // UIAccelerometer只在iOS5.0之前用
//    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)proximityStateDidChange:(NSNotification *)note {
    if ([UIDevice currentDevice].proximityState) {
        NSLog(@"靠近");
    } else {
        NSLog(@"离开");
    }
}

// 尽可能在 app 中只创建一个 CMMotionManager 对象，多个 CMMotionManager 对象会影响从加速计和陀螺仪接受数据的速率。
// CMMotionManager的push方式
// push 方式实时获取数据，采样频率高
- (void)motionPush {
    CMMotionManager *mManager = [[CMMotionManager alloc] init];
    mManager.deviceMotionUpdateInterval = 1/15.0;
    // 其次，在启动接收设备传感器信息前要检查传感器是否硬件可达，可以用deviceMotionAvailable 检测硬件是否正常，用 deviceMotionActive 检测当前 CMMotionManager 是否正在提供数据更新。
    if (mManager.deviceMotionAvailable) {
        KFALog(@"CMMotionManager可用");
        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            self.xlabel.text = @(motion.gravity.x).stringValue;
            self.ylabel.text = @(motion.gravity.y).stringValue;
            self.zlabel.text = @(motion.gravity.z).stringValue;
        }];
    } else {
        KFALog(@"CMMotionManager不可用");
    }
}

// CMMotionManager的pull方式
// pull 方式仅在需要数据时采集数据，Apple 更加推荐这种方式获取数据。
- (void)motionPull {
    CMMotionManager *mManager = [[CMMotionManager alloc] init];
    mManager.deviceMotionUpdateInterval = 1/15.0;
    if (mManager.deviceMotionAvailable) {
        KFALog(@"CMMotionManager可用");
        [mManager startDeviceMotionUpdates];
        self.xlabel.text = @(mManager.deviceMotion.gravity.x).stringValue;
        self.ylabel.text = @(mManager.deviceMotion.gravity.y).stringValue;
        self.zlabel.text = @(mManager.deviceMotion.gravity.z).stringValue;
    } else {
        KFALog(@"CMMotionManager不可用");
    }
}

// UIAccelerometer只在iOS5.0之前用
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [self.xlabel setText:[NSString stringWithFormat:@"%f",acceleration.x]];
    [self.ylabel setText:[NSString stringWithFormat:@"%f",acceleration.y]];
    [self.zlabel setText:[NSString stringWithFormat:@"%f",acceleration.z]];
}

@end
