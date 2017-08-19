//
//  YWAuthorizationManager.h
//  QRCode
//
//  Created by apple on 2017/8/18.
//  Copyright © 2017年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, YWAuthorizationType){
    //相册
    YWAuthorizationTypePhotoLibrary = 0,
    //相机
    YWAuthorizationTypeCamera,
    //麦克风
    YWAuthorizationTypeAudio,
    //使用应用期间定位权限
    YWAuthorizationTypeLocationWhenInUse,
    //始终定位权限
    YWAuthorizationTypeLocationAlways
};

//弹窗提醒方式
typedef NS_ENUM(NSUInteger, YWAuthorizationReminderType) {
    //仅仅是提醒,并告知用户设置步骤
    YWAuthorizationReminderTypeStep = 0,
    //点击设置可以跳转至设置界面
    YWAuthorizationReminderTypeSkip
};

@interface YWAuthorizationManager : NSObject

@property(nonatomic,assign)BOOL isNeedReminder;      //是否需要提示,默认为YES

@property(nonatomic,assign)YWAuthorizationReminderType authorizationReminderType;    //提醒方式,默认为步骤

/**
 单列对象
 */
+ (YWAuthorizationManager *)defaultManager;


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
                                 unauthorizedHandel:(void(^)())unauthorizedHandel;

@end
