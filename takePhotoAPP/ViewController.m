//
//  ViewController.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 22/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(20, 20, 100, 30);
    but.backgroundColor = [UIColor orangeColor];
    [but setTitle:@"镜头" forState:UIControlStateNormal];
    [but addTarget:self action:@selector(cameraVC) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:but];
    
}

- (void)cameraVC{
    CameraViewController *cVC = [[CameraViewController alloc] init];
    [self presentViewController:cVC animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
