//
//  YWAuthorizationManager.m
//  QRCode
//
//  Created by apple on 2017/8/18.
//  Copyright © 2017年 zjbojin. All rights reserved.
//

#import "YWAuthorizationManager.h"

@interface YWAuthorizationManager ()<CLLocationManagerDelegate>

@property(nonatomic,strong)CLLocationManager *locationManager;

@property(nonatomic,copy)void(^locationAlwaysAuthorizedHandel)();
@property(nonatomic,copy)void(^locationAlawysUnauthorizedHandel)();
@property(nonatomic,copy)void(^locationWhenInUseAuthorizedHandel)();
@property(nonatomic,copy)void(^locationWhenInUseUnauthorizedHandel)();

@end


@implementation YWAuthorizationManager

#pragma mark - DefaultIntial
- (instancetype)init{
    self = [super init];
    if (self) {
        self.isNeedReminder = YES;
        self.authorizationReminderType = YWAuthorizationReminderTypeStep;
    }
    return self;
}

/**
 单列对象
 */
+ (YWAuthorizationManager *)defaultManager{
    static YWAuthorizationManager *authorizationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authorizationManager = [[YWAuthorizationManager alloc] init];
    });
    return authorizationManager;
}


#pragma mark - Events
/**
 请求权限统一入口

 @param currentController 当前控制器
 @param authorizationType 权限类型
 @param authorizedHandel 授权后的回调
 @param unauthorizedHandel 未授权后的回调
 */
- (void)YW_requestAuthorizationWithCurrentController:(UIViewController *)currentController
                                  authorizationType:(YWAuthorizationType)authorizationType
                                   authorizedHandel:(void(^)())authorizedHandel
                                 unauthorizedHandel:(void(^)())unauthorizedHandel{
    
    switch (authorizationType) {
        case YWAuthorizationTypePhotoLibrary:
            [self requestPhotoLibraryWithCurrentController:currentController authorizedHandel:authorizedHandel unauthorizedHandel:unauthorizedHandel];
            break;
            
        case YWAuthorizationTypeCamera:
            [self requestCamemaWithCurrentController:currentController authorizedHandel:authorizedHandel unauthorizedHandel:unauthorizedHandel];
            break;
            
        case YWAuthorizationTypeAudio:
            [self requestAudioWithCurrentController:currentController authorizedHandel:authorizedHandel unauthorizedHandel:unauthorizedHandel];
            break;
            
        case YWAuthorizationTypeLocationAlways:
            [self requestLocationAlwaysWithCurrentController:currentController authorizedHandel:authorizedHandel unauthorizedHandel:unauthorizedHandel];
            break;
        
        case YWAuthorizationTypeLocationWhenInUse:
            [self requestLocationWhenInUseWithCurrentController:currentController authorizedHandel:authorizedHandel unauthorizedHandel:unauthorizedHandel];
            break;
    }
    
}

//相册权限
- (void)requestPhotoLibraryWithCurrentController:(UIViewController *)currentController
                                authorizedHandel:(void(^)())authorizedHandel
                              unauthorizedHandel:(void(^)())unauthorizedHandel{
    //判断授权状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {   //用户还没有作出选择
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {  //用户第一次同意了访问相册权限
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorizedHandel ? authorizedHandel() : nil;
                });
                
            } 
            
        }];
    } else if (status == PHAuthorizationStatusAuthorized){  //用户已经允许访问相册权限
        
        authorizedHandel ? authorizedHandel() : nil ;
        
    } else if (status == PHAuthorizationStatusDenied) {  //用户拒绝访问相册权限
        
        unauthorizedHandel ? unauthorizedHandel() : nil;
        
        if (self.isNeedReminder) {
            
            switch (self.authorizationReminderType) {
                case YWAuthorizationReminderTypeStep:{
                    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
                    NSString *message = [NSString stringWithFormat:@"请前往 -> [设置 - 隐私 - 照片 - %@] 打开访问开关",appName];
                    [self presentAlertControllerWithMessage:message currentController:currentController];
                }
                    break;
                    
                case YWAuthorizationReminderTypeSkip:{
                    [self presentAlertControllerWithTitle:@"相册授权未开启" message:@"请在系统设置中开启相册授权" currentController:currentController];
                }
                    break;
            }
            
        }
        
    }else if (status == PHAuthorizationStatusRestricted) {
        
        unauthorizedHandel ? unauthorizedHandel() : nil;
        
        if (self.isNeedReminder) {
            NSString *message = [NSString stringWithFormat:@"由于系统原因, 无法访问相册"];
            [self presentAlertControllerWithMessage:message currentController:currentController];
        }
    }
}

//相机权限
- (void)requestCamemaWithCurrentController:(UIViewController *)currentController
                          authorizedHandel:(void(^)())authorizedHandel
                        unauthorizedHandel:(void(^)())unauthorizedHandel{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        
        //判断授权状态
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {     //用户还没有作出选择
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if (granted) {    //用户第一次同意了访问相机权限
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authorizedHandel ? authorizedHandel() : nil;
                    });
                }
                
            }];
            
        } else if (status == AVAuthorizationStatusAuthorized) {  //用户已经允许访问相机权限
            
            authorizedHandel ? authorizedHandel() : nil;
            
        } else if (status == AVAuthorizationStatusDenied) {   //用户拒绝访问相机权限
            
            unauthorizedHandel ? unauthorizedHandel() : nil;
            
            if (self.isNeedReminder) {
                
                switch (self.authorizationReminderType) {
                    case YWAuthorizationReminderTypeStep:{
                        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
                        NSString *message = [NSString stringWithFormat:@"请前往 -> [设置 - 隐私 - 相机 - %@] 打开访问开关",appName];
                        [self presentAlertControllerWithMessage:message currentController:currentController];
                    }
                        break;
                        
                    case YWAuthorizationReminderTypeSkip:
                        [self presentAlertControllerWithTitle:@"相机授权未开启" message:@"请在系统设置中开启相机授权" currentController:currentController];
                        break;
                }
                
            }
            
        } else if (status == AVAuthorizationStatusRestricted) {
            
            unauthorizedHandel ? unauthorizedHandel() : nil;
            
            if (self.isNeedReminder) {
                NSString *message = [NSString stringWithFormat:@"由于系统原因, 无法访问相机"];
                [self presentAlertControllerWithMessage:message currentController:currentController];
            }
            
        }
        
    } else {
        
        [self presentAlertControllerWithMessage:@"未检测到您的摄像头" currentController:currentController];
        
    }
}

//麦克风权限
- (void)requestAudioWithCurrentController:(UIViewController *)currentController
                         authorizedHandel:(void(^)())authorizedHandel
                       unauthorizedHandel:(void(^)())unauthorizedHandel{
    
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (device) {
        
        //判断授权状态
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (status == AVAuthorizationStatusNotDetermined) {     //用户还没有作出选择
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
                if (granted) {    //用户第一次同意了访问麦克风权限
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authorizedHandel ? authorizedHandel() : nil;
                    });
                }
                
            }];
            
        } else if (status == AVAuthorizationStatusAuthorized) {  //用户已经允许访问麦克风权限
            
            authorizedHandel ? authorizedHandel() : nil;
            
        } else if (status == AVAuthorizationStatusDenied) {   //用户拒绝访问相机权限
            
            unauthorizedHandel ? unauthorizedHandel() : nil;
            
            if (self.isNeedReminder) {
                
                switch (self.authorizationReminderType) {
                    case YWAuthorizationReminderTypeStep:{
                        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
                        NSString *message = [NSString stringWithFormat:@"请前往 -> [设置 - 隐私 - 麦克风 - %@] 打开访问开关",appName];
                        [self presentAlertControllerWithMessage:message currentController:currentController];
                    }
                        break;
                        
                    case YWAuthorizationReminderTypeSkip:
                        [self presentAlertControllerWithTitle:@"麦克风授权未开启" message:@"请在系统设置中开启麦克风授权" currentController:currentController];
                        break;
                }
                
            }
            
        } else if (status == AVAuthorizationStatusRestricted) {
            
            unauthorizedHandel ? unauthorizedHandel() : nil;
            
            if (self.isNeedReminder) {
                NSString *message = [NSString stringWithFormat:@"由于系统原因, 无法访问麦克风"];
                [self presentAlertControllerWithMessage:message currentController:currentController];
            }
            
        }

        
    } else {
        
        [self presentAlertControllerWithMessage:@"未检测到您的麦克风" currentController:currentController];
        
    }
}

//使用期间定位权限
- (void)requestLocationWhenInUseWithCurrentController:(UIViewController *)currentController
                                     authorizedHandel:(void(^)())authorizedHandel
                                   unauthorizedHandel:(void(^)())unauthorizedHandel{
   //地理位置管理对象
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
    }
    
    //判断授权状态
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {    //用户还没决定
        
        [self.locationManager requestWhenInUseAuthorization];
        self.locationWhenInUseAuthorizedHandel = authorizedHandel;
        
    } else if (status == kCLAuthorizationStatusDenied) {   //用户拒绝访问定位服务
        
        unauthorizedHandel ? unauthorizedHandel() : nil;
        
        if (self.isNeedReminder) {
            switch (self.authorizationReminderType) {
                case YWAuthorizationReminderTypeStep:{
                    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
                    NSString *message = [NSString stringWithFormat:@"请前往 -> [设置 - 隐私 - 定位服务 - %@] 打开访问开关",appName];
                    [self presentAlertControllerWithMessage:message currentController:currentController];
                }
                    break;
                    
                case YWAuthorizationReminderTypeSkip:{
                    [self presentAlertControllerWithTitle:@"定位服务未开启" message:@"请在系统设置中开启定位服务" currentController:currentController];
                }
                    break;
            }
        }
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {    //允许访问定位服务
        
        authorizedHandel ? authorizedHandel() : nil;
        
    } else if (status == kCLAuthorizationStatusAuthorizedAlways) {   //允许访问定位服务
        
        authorizedHandel ? authorizedHandel() : nil;
        
    } else if (status == kCLAuthorizationStatusRestricted) {   
        
        unauthorizedHandel ? unauthorizedHandel() : nil;
        
        if (self.isNeedReminder) {
            [self presentAlertControllerWithMessage:@"由于系统原因, 无法开启定位服务" currentController:currentController];
        }
        
    }
    
}

//始终使用定位权限
- (void)requestLocationAlwaysWithCurrentController:(UIViewController *)currentController
                                     authorizedHandel:(void(^)())authorizedHandel
                                unauthorizedHandel:(void(^)())unauthorizedHandel{
    
    //地理位置管理对象
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
    }
    
    //判断授权状态
    CLAuthorizationStatus states = [CLLocationManager authorizationStatus];
    if (states == kCLAuthorizationStatusNotDetermined) {   //用户还没有决定
        
        [self.locationManager requestAlwaysAuthorization];
        self.locationAlwaysAuthorizedHandel = authorizedHandel;
        
    } else if (states == kCLAuthorizationStatusDenied || states == kCLAuthorizationStatusAuthorizedWhenInUse) {   //用户拒绝访问后台定位服务
        
        unauthorizedHandel ? unauthorizedHandel() : nil;
        
        if (self.isNeedReminder) {
            switch (self.authorizationReminderType) {
                case YWAuthorizationReminderTypeStep:{
                    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
                    NSString *message = [NSString stringWithFormat:@"请前往 -> [设置 - 隐私 - 定位服务 - %@ - 始终] 打开访问开关",appName];
                    [self presentAlertControllerWithMessage:message currentController:currentController];
                }
                    break;
                    
                case YWAuthorizationReminderTypeSkip:{
                    [self presentAlertControllerWithTitle:@"后台定位服务未开启" message:@"请在系统设置中开启后台定位服务" currentController:currentController];
                }
                    break;
            }
        }
    } else if (states == kCLAuthorizationStatusAuthorizedAlways) {    //允许访问后台定位
        
        authorizedHandel ? authorizedHandel() : nil;
        
    } else if (states == kCLAuthorizationStatusRestricted) {
        
        unauthorizedHandel ? unauthorizedHandel() : nil;
        
        if (self.isNeedReminder) {
            [self presentAlertControllerWithMessage:@"由于系统原因, 无法开启后台定位服务" currentController:currentController];
        }
        
    }
    
}

#pragma - mark Private Methods
/**
 弹窗提示(只有一个确定按钮)

 @param message 提示消息
 */
- (void)presentAlertControllerWithMessage:(NSString *)message
                        currentController:(UIViewController *)currentController{
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:action];
    [currentController presentViewController:alertC animated:YES completion:nil];
}

/**
 弹窗提示(取消和设置按钮)

 @param title 提示信息
 @param message 提示描述
 */
- (void)presentAlertControllerWithTitle:(NSString *)title
                              message:(NSString *)message
                        currentController:(UIViewController *)currentController{
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) return ;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
           
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            
        } else {
            
            [[UIApplication  sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
        }
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:sureAction];
    [alertC addAction:cancelAction];
    [currentController presentViewController:alertC animated:YES completion:nil];
    
}

#pragma mark - CLLocationManagerDelegate
//第一次调用请求权限也会调用该方法
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
            break;
        
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            self.locationWhenInUseAuthorizedHandel ? self.locationWhenInUseAuthorizedHandel() : nil;
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            self.locationAlwaysAuthorizedHandel ? self.locationAlwaysAuthorizedHandel() : nil;
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
            
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
    }
    
}

@end
