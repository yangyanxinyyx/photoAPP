//
//  GoodsShelfTopBar.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 12/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GoodsShelfTopBar.h"

@implementation GoodsShelfTopBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    self.backgroundColor = UICOLOR(246, 188, 1, 1);
    
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:buttonBack];
    UIImage *buttonBackImage = [UIImage imageNamed:@"nav_back"];
    buttonBack.frame = CGRectMake(10, (64 - buttonBackImage.size.height)/2 , buttonBackImage.size.width, buttonBackImage.size.height);
    [buttonBack setImage: buttonBackImage forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(pressBtnToBack) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 65)];
    titleLabel.center = self.center;
    titleLabel.text  = @"货架预览";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:titleLabel];
    
    UIButton *buttonFinish = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:buttonFinish];
    buttonFinish.frame = CGRectMake(SCREEN_WIDTH - 44 - 10, (64-20)/2, 44, 20);
    [buttonFinish setTitle:@"完成" forState:UIControlStateNormal];
    [buttonFinish addTarget:self action:@selector(pressBtnToFinish) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pressBtnToBack
{
    if (_topBarDelegate && [_topBarDelegate respondsToSelector:@selector(pressToBack)]) {
        [_topBarDelegate pressToBack];
    }
}

- (void)pressBtnToFinish
{
    if (_topBarDelegate && [_topBarDelegate respondsToSelector:@selector(pressToFinish)]) {
        [_topBarDelegate pressToFinish];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
