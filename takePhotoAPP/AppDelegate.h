//
//  AppDelegate.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 22/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier; //向系统申请后台运行的额外时间
@property (nonatomic, strong) NSTimer *backgroundTimer;
@end

