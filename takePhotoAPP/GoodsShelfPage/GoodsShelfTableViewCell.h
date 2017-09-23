//
//  GoodsShelfTableViewCell.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 23/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsShelfModel.h"

@interface GoodsShelfTableViewCell : UITableViewCell

@property (nonatomic,strong) UIView *viewBackground;
@property (nonatomic,strong) UIImageView *thumbImageView;
@property (nonatomic,strong) UILabel *uploadStateLabel;
@property (nonatomic,strong) UIImageView *iconImageView;

@property (nonatomic,assign) GoodsUploadState uploadState;

@end
