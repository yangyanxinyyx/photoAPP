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
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    ViewController *VC = [[ViewController alloc] init];
    UINavigationController *Nav = [[UINavigationController alloc] initWithRootViewController:VC];
    
    self.window.rootViewController = Nav;
    [self.window makeKeyAndVisible];
    [[DataBaseManager shareDataBase] creatTable];
//    GoodsShelfModel *model = [[GoodsShelfModel alloc] init];
//    model.goodUploadState = @"a";
//    model.thumbLink = @"b";
//    model.imageCount = @"c";
//    model.imagePaths = @"e";
//    model.failArrays = @"d";
//    [[DataBaseManager shareDataBase] insertInToTableWithModel:model];
//    [[DataBaseManager shareDataBase] deleteInTableWithDbid:@"1"];
//    
//    GoodsShelfModel *model2 = [[GoodsShelfModel alloc] init];
//    model2.goodUploadState = @"1";
//    model2.thumbLink = @"2";
//    model2.imageCount = @"3";
//    model2.imagePaths = @"5";
//    model2.failArrays = @"4";
//    
//    [[DataBaseManager shareDataBase] insertInToTableWithModel:model2];
//    model2.dbid = @"2";
//    model2.goodUploadState = @"11";
//    
//    [[DataBaseManager shareDataBase] updateInTableWithModel:model2];
    
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
