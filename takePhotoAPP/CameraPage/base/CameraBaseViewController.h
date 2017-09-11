//
//  CameraBaseViewController.h
//  takePhotoAPP
//
//  Created by Melody on 2017/9/9.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTabViewTopMargin 8
#define kTabViewLeftMargin 8
#define kTabViewRightMargin 8

@interface CameraBaseViewController : UIViewController

// 顶部
@property (nonatomic, strong) UIView *topView;
// 底部
@property (nonatomic, strong) UIView *tabView;



@end

