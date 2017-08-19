//
//  ViewController.m
//  YWAuthorizationManager
//
//  Created by apple on 2017/8/19.
//  Copyright © 2017年 zjbojin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)requestCameraAu:(UIButton *)sender {
    [YWAuthorizationManager defaultManager].authorizationReminderType = YWAuthorizationReminderTypeStep;
    [[YWAuthorizationManager defaultManager] YW_requestAuthorizationWithCurrentController:self authorizationType:YWAuthorizationTypeCamera authorizedHandel:^{
        NSLog(@"相机权限已经授权");
    } unauthorizedHandel:^{
        NSLog(@"相机权限未授权");
    }];
}
- (IBAction)requestPhotoLibraryAu:(UIButton *)sender {
    [YWAuthorizationManager defaultManager].authorizationReminderType = YWAuthorizationReminderTypeSkip;
    [[YWAuthorizationManager defaultManager] YW_requestAuthorizationWithCurrentController:self authorizationType:YWAuthorizationTypePhotoLibrary authorizedHandel:^{
        NSLog(@"相册权限已经授权");
    } unauthorizedHandel:^{
        NSLog(@"相册权限未授权");
    }];
    
}
- (IBAction)requestLocationWhenInUseAu:(UIButton *)sender {
    [YWAuthorizationManager defaultManager].authorizationReminderType = YWAuthorizationReminderTypeSkip;
    [[YWAuthorizationManager defaultManager] YW_requestAuthorizationWithCurrentController:self authorizationType:YWAuthorizationTypeLocationWhenInUse authorizedHandel:^{
        NSLog(@"定位权限已经授权");
    } unauthorizedHandel:^{
        NSLog(@"定位权限未授权");
    }];
}
- (IBAction)requestLocationAlwaysAu:(UIButton *)sender {
    [YWAuthorizationManager defaultManager].authorizationReminderType = YWAuthorizationReminderTypeSkip;
    [[YWAuthorizationManager defaultManager] YW_requestAuthorizationWithCurrentController:self authorizationType:YWAuthorizationTypeLocationAlways authorizedHandel:^{
        NSLog(@"后台定位权限已经授权");
    } unauthorizedHandel:^{
        NSLog(@"后台定位权限未授权");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
