//
//  GSPrewViewController.h
//  takePhotoAPP
//
//  Created by Melody on 2017/9/16.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "CameraBaseViewController.h"

@interface GSPrewViewController : CameraBaseViewController

@property (nonatomic, strong) NSDictionary * imageDateInfo ;
/** 拼图路径 */
@property (nonatomic, strong) NSString * puzzlePath ;
@end
