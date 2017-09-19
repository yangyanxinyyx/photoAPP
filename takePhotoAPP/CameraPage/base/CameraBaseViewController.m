//
//  CameraBaseViewController.m
//  takePhotoAPP
//
//  Created by Melody on 2017/9/9.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "CameraBaseViewController.h"

@interface CameraBaseViewController ()

@end

@implementation CameraBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initBaseUI];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init Method
- (void)initBaseUI {
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.topView];
    [self.view addSubview:self.tabView];
    
}
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    
//    return UIStatusBarStyleLightContent;
//}
#pragma mark - Action Method

//- (void)toucheOrSOButtonValue:(UIButton *)button {
//    
//}
//- (void)toucheUpAndDownButton:(UIButton *)button {
//    
//}
//- (void)toucheFlashButton:(UIButton *)button {
//    
//}
#pragma mark - Privacy Method

#pragma mark - Setter&Getter

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TOPVIEW_HEIGHT)];
        _topView.backgroundColor = [UIColor whiteColor];
//        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//        effectView.frame = _topView.frame;
//        [_topView addSubview:effectView];
        
    }
    return _topView;
}

- (UIView *)tabView{
    if (!_tabView) {
        _tabView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - TABVIEW_HEIGHT, SCREEN_WIDTH,TABVIEW_HEIGHT)];
        _tabView.backgroundColor = [UIColor whiteColor];
    }
    return _tabView;
}



@end


