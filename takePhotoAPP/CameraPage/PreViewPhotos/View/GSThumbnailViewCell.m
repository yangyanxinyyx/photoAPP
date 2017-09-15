//
//  GSThumbnailViewCell.m
//  takePhotoAPP
//
//  Created by Melody on 2017/9/10.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GSThumbnailViewCell.h"

@interface GSThumbnailViewCell ()
@property (nonatomic, strong) UIImageView *shadeImageView;
@end

@implementation GSThumbnailViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.itemImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.itemImageView];
        [self.itemImageView addSubview:self.shadeImageView];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.itemImageView.frame = self.contentView.frame;
    self.shadeImageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)setIsSelect:(BOOL)isSelect{
    _isSelect = isSelect;
    if (isSelect) {
        _shadeImageView.alpha = 1;
        _itemImageView.layer.borderColor = [UIColor redColor].CGColor;
        _itemImageView.layer.borderWidth = 0.5;
    } else {
        _shadeImageView.alpha = 0;
        _itemImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}
- (UIImageView *)itemImageView{
    if (!_itemImageView) {
        _itemImageView = [[UIImageView alloc]init];
        _itemImageView.contentMode = UIViewContentModeScaleAspectFit;
        _itemImageView.layer.masksToBounds = YES;
        _itemImageView.layer.cornerRadius = 5;
    }
    return _itemImageView;
}

- (UIImageView *)shadeImageView{
    if (!_shadeImageView) {
        _shadeImageView = [[UIImageView alloc]init];
        _shadeImageView.alpha = 0;
        _shadeImageView.image = [UIImage imageNamed:@"hook"];
        _shadeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _shadeImageView.layer.masksToBounds = YES;
        _shadeImageView.layer.cornerRadius = 5;
    }
    return _shadeImageView;
}

@end
