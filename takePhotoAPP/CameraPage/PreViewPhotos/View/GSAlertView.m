//
//  GSAlertView.m
//  takePhotoAPP
//
//  Created by Melody on 2017/9/16.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GSAlertView.h"

@interface GSAlertView ()
/** <# 注释 #> */
@property (nonatomic, strong) UIView * alertView ;

@end

@implementation GSAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        
        
    }
    return self;
}

@end
