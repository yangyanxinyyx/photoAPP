//
//  GoodsShelfTopBar.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 12/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GoodsShelfTopBarDelegate <NSObject>

- (void)pressToBack;
- (void)pressToFinish;


@end

@interface GoodsShelfTopBar : UIView

@property (nonatomic,weak)id<GoodsShelfTopBarDelegate>topBarDelegate;

@end
