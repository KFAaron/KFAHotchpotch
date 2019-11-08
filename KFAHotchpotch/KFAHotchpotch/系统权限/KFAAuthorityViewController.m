//
//  KFAAuthorityViewController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/11/8.
//  Copyright © 2019 KFAaron. All rights reserved.
//
//  重点！！！隐私权限请求完成应在主线程中完成回调！！！重点
//  隐私权限四部曲：
//  1、在info.plist文件里配置相关权限。
//  2、在项目的Targets->Capabilities中开启相应开关，目前Siri、Health、NFC、HomeKit需要开启；
//  3、导入相应的库
//  4、使用代码获取权限

#import "KFAAuthorityViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <EventKit/EventKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Contacts/Contacts.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <HealthKit/HealthKit.h>
#import <HomeKit/HomeKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <StoreKit/StoreKit.h>
#import <CoreNFC/CoreNFC.h>
#import <Photos/Photos.h>
#import <Intents/Intents.h>
#import <Speech/Speech.h>

@interface KFAAuthorityViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation KFAAuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configDatasource];
}

- (void)configDatasource {
    
    self.dataSource = ({
          NSArray *arr = @[
              @{kTitle:@"蓝牙",kUsageDescription:@"NSBluetoothAlwaysUsageDescription",kAuthorityMethod:@"bluetoothAlways"},
    @{kTitle:@"日历",kUsageDescription:@"NSCalendarsUsageDescription",kAuthorityMethod:@"calendar"},
    @{kTitle:@"相机",kUsageDescription:@"NSCameraUsageDescription",kAuthorityMethod:@"camera"},
    @{kTitle:@"通讯录",kUsageDescription:@"NSContactsUsageDescription",kAuthorityMethod:@"contacts"},
    @{kTitle:@"FaceID",kUsageDescription:@"NSFaceIDUsageDescription",kAuthorityMethod:@"faceId"},
    @{kTitle:@"健康分享",kUsageDescription:@"NSHealthShareUsageDescription",kAuthorityMethod:@"healthShare"},
    @{kTitle:@"健康更新",kUsageDescription:@"NSHealthUpdateUsageDescription",kAuthorityMethod:@"healthUpdate"},
    @{kTitle:@"住宅配件",kUsageDescription:@"NSHomeKitUsageDescription",kAuthorityMethod:@"homeKit"},
    @{kTitle:@"位置",kUsageDescription:@"NSLocationUsageDescription",kAuthorityMethod:@"location"},
    @{kTitle:@"始终访问位置",kUsageDescription:@"NSLocationAlwaysUsageDescription",kAuthorityMethod:@"locationAlways"},
    @{kTitle:@"使用期间访问位置",kUsageDescription:@"NSLocationWhenInUseUsageDescription",kAuthorityMethod:@"locationWhenInUse"},
    @{kTitle:@"麦克风",kUsageDescription:@"NSMicrophoneUsageDescription",kAuthorityMethod:@"microphone"},
    @{kTitle:@"运动与健身",kUsageDescription:@"NSMotionUsageDescription",kAuthorityMethod:@"motion"},
    @{kTitle:@"媒体资料库",kUsageDescription:@"kTCCServiceMediaLibrary",kAuthorityMethod:@"tccServiceMediaLibrary"},
    @{kTitle:@"NFC",kUsageDescription:@"NFCReaderUsageDescription",kAuthorityMethod:@"nfcReader"},
    @{kTitle:@"相册",kUsageDescription:@"NSPhotoLibraryUsageDescription",kAuthorityMethod:@"photoLibrary"},
    @{kTitle:@"提醒事项",kUsageDescription:@"NSRemindersUsageDescription",kAuthorityMethod:@"reminders"},
    @{kTitle:@"Siri",kUsageDescription:@"NSSiriUsageDescription",kAuthorityMethod:@"siri"},
    @{kTitle:@"语音识别",kUsageDescription:@"NSSpeechRecognitionUsageDescription",kAuthorityMethod:@"speechRecognition"},
    @{kTitle:@"电视提供商",kUsageDescription:@"NSVideoSubscriberAccountUsageDescription",kAuthorityMethod:@"videoSubscriberAccount"}];
          arr;
      });
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *authorityTableViewCellIdentifier = @"KFAAuthorityTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:authorityTableViewCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authorityTableViewCellIdentifier];
    }
    if (indexPath.section < self.dataSource.count) {
        NSDictionary *data = self.dataSource[indexPath.section];
        cell.textLabel.text = data[kTitle];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section < self.dataSource.count) {
        NSDictionary *data = self.dataSource[indexPath.section];
        NSString *methodName = data[kAuthorityMethod];
        SEL selector = NSSelectorFromString(methodName);
        IMP imp = [self methodForSelector:selector];
        void(*authorityAction)(id, SEL) = (void *)imp;
        authorityAction(self, selector);
    }
}

#pragma mark - Actions

- (void)bluetoothAlways {
//    CBCentralManager
}

- (void)calendar {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusNotDetermined) {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            KFALog(@"%d===%@",granted,error);
        }];
    }
}

- (void)camera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                KFALog(@"%d",granted);
            }];
        }
    }
}

- (void)contacts {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if ( status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            KFALog(@"%d===%@",granted,error);
        }];
    }
}

- (void)faceId {
    if (@available(iOS 11.0, *)) {
        LAContext *context = [[LAContext alloc] init];
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL]) {
            if (context.biometryType == LABiometryTypeFaceID) {
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"" reply:^(BOOL success, NSError * _Nullable error) {
                    KFALog(@"%d===%@",success,error);
                }];
            }
        }
    }
}

- (void)healthShare {
    if ([HKHealthStore isHealthDataAvailable]) {
        HKHealthStore *store = [[HKHealthStore alloc] init];
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        HKAuthorizationStatus status = [store authorizationStatusForType:type];
        if (status == HKAuthorizationStatusNotDetermined) {
            NSSet *set = [NSSet setWithObject:type];
            [store requestAuthorizationToShareTypes:set readTypes:set completion:^(BOOL success, NSError * _Nullable error) {
                KFALog(@"%d===%@",success,error);
            }];
        }
    }
}

- (void)healthUpdate {
    KFALog(@"见healthShare");
}

- (void)homeKit {
//    HMHomeManager
//    HMHomeManagerAuthorizationStatus
}

- (void)location {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        [manager requestAlwaysAuthorization];
    }
}

- (void)locationAlways {
    
}

- (void)locationWhenInUse {
    
}

- (void)microphone {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            KFALog(@"%d",granted);
        }];
    }
}

- (void)motion {
    
}

- (void)tccServiceMediaLibrary {
    if (@available(iOS 9.3, *)) {
        SKCloudServiceAuthorizationStatus status = [SKCloudServiceController authorizationStatus];
        if (status == SKCloudServiceAuthorizationStatusNotDetermined) {
            [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
                KFALog(@"%ld",status);
            }];
        }
    }
}

- (void)nfcReader {
    
}

- (void)photoLibrary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            KFALog(@"%ld",status);
        }];
    }
}

- (void)reminders {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if (status == EKAuthorizationStatusNotDetermined) {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
            KFALog(@"%d===%@",granted,error);
        }];
    }
}

- (void)siri {
    if (@available(iOS 10.0, *)) {
        INSiriAuthorizationStatus status = [INPreferences siriAuthorizationStatus];
        if (status == INSiriAuthorizationStatusNotDetermined) {
            [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
                KFALog(@"%ld",(long)status);
            }];
        }
    }
}

- (void)speechRecognition {
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
        if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
            [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                KFALog(@"%ld",status);
            }];
        }
    }
}

- (void)videoSubscriberAccount {
    
}

@end
