//
//  ViewController.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 22/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
#import "GoodsShelfPreViewViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(20, 20, 100, 30);
    but.backgroundColor = [UIColor orangeColor];
    [but setTitle:@"镜头" forState:UIControlStateNormal];
    [but addTarget:self action:@selector(cameraVC) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:but];
    
    UIButton *buttonTest = ({
        buttonTest = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonTest setTitle:@"Go to preViewVC" forState:UIControlStateNormal];
        [buttonTest setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        CGFloat buttonW = 150 ;
        CGFloat buttonH = 60 ;
        buttonTest.frame = CGRectMake(self.view.center.x - buttonW * 0.5 , self.view.center.y - buttonH * 0.5, buttonW, buttonH);
        [buttonTest sizeToFit];
        [buttonTest addTarget:self action:@selector(goGoodsShelfViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:buttonTest];
        buttonTest;
    });

    
}

- (void)goGoodsShelfViewController:(UIButton *)button {
    
    GoodsShelfPreViewViewController *goodShelfVC = [[GoodsShelfPreViewViewController alloc] init];
    
    [self presentViewController:goodShelfVC animated:YES completion:nil];
    
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
