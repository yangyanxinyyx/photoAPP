//
//  CameraBaseViewController.h
//  takePhotoAPP
//
//  Created by Melody on 2017/9/9.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TOPVIEW_HEIGHT 64
#define TABVIEW_HEIGHT 113
#define kTabViewTopMargin 20
#define kCollectionViewTopMargin 24
#define kTabViewLeftMargin 10
#define kTabViewRightMargin 10

#define kGoodsShelfPuzzleSize  CGSizeMake(160,90)
#define kpuzzleImagePath @"imagePath"
#define kpuzzleMode @"mode"
#define kpuzzlePath @"puzzlePath"
#define kpuzzleThumbPath @"puzzleThumbPath"
@interface CameraBaseViewController : UIViewController

// 顶部
@property (nonatomic, strong) UIView *topView;
// 底部
@property (nonatomic, strong) UIView *tabView;



@end

