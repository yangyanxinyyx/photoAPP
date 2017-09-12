//
//  GSProgressView.h
//  takePhotoAPP
//
//  Created by admin on 11/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSProgressViewDelegate <NSObject>

- (void)camerScaleWithSliderValue:(float)sliderValue;

@end

@interface GSProgressView : UIView
@property (weak,nonatomic) id<GSProgressViewDelegate> delgegate;
@end
