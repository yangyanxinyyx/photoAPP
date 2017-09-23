//
//  AppDelegate.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 22/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "DataBaseManager.h"
#import "GoodsShelfModel.h"
#import "CameraViewController.h"
#import "GoodsShelfDataManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    CameraViewController *VC = [[CameraViewController alloc] init];
    UINavigationController *Nav = [[UINavigationController alloc] initWithRootViewController:VC];
    
    self.window.rootViewController = Nav;
    [self.window makeKeyAndVisible];
    [[DataBaseManager shareDataBase] creatTable];
    [[GoodsShelfDataManager shareInstance] datas];

    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"newsPic1" ofType:@"jpg"];
    NSLog(@"%@",NSHomeDirectory());
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //申请进入后台额外时间
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        [self endbackgroundTask];
    }];
    self.backgroundTimer =[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerMethod:)     userInfo:nil repeats:YES];
}


- (void) timerMethod:(NSTimer *)paramSender{
    
    
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    
    if (backgroundTimeRemaining == DBL_MAX){
        
        NSLog(@"没设置后台时间");
        
    } else {
        
        //NSLog(@"后台还剩 = %.02f 秒", backgroundTimeRemaining);
        if (backgroundTimeRemaining < 10) {
            NSLog(@"后台申请时间即将结束 即将进入后台");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FCHMessageListSetSendFail" object:nil];
        }
    }
}

-(void)endbackgroundTask
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
        
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
