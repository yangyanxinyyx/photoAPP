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
#import "GoodsShelfViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
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


    UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
    bu.frame = CGRectMake(200, 20, 100, 30);
    bu.backgroundColor = [UIColor orangeColor];
    [bu setTitle:@"货架" forState:UIControlStateNormal];
    [bu addTarget:self action:@selector(pressToGoodsShelfVC) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:bu];
}

- (void)goGoodsShelfViewController:(UIButton *)button {
    
    GoodsShelfPreViewViewController *goodShelfVC = [[GoodsShelfPreViewViewController alloc] init];
    
    [self.navigationController pushViewController:goodShelfVC animated:YES];
    
}

- (void)cameraVC{
    CameraViewController *cVC = [[CameraViewController alloc] init];
    [self.navigationController pushViewController:cVC animated:YES];
    
}

- (void)pressToGoodsShelfVC {
    GoodsShelfViewController *VC = [[GoodsShelfViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
