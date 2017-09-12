//
//  GoodsShelfTableViewCell.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 23/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GoodsShelfTableViewCell.h"

@implementation GoodsShelfTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UICOLOR(248, 248, 248, 1);
        self.backgroundColor = UICOLOR(248, 248, 248, 1);
        
        self.viewBackground = [[UIView alloc] init];
        [self.contentView addSubview:_viewBackground];
        
        self.thumbImageView = [[UIImageView alloc] init];
        [self.viewBackground addSubview:_thumbImageView];
        
        self.uploadStateLabel = [[UILabel alloc] init];
        [self.viewBackground addSubview:_uploadStateLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _viewBackground.frame = CGRectMake(10, 5, self.contentView.frame.size.width - 20, 110);
    _viewBackground.backgroundColor = [UIColor whiteColor];
    _viewBackground.layer.cornerRadius = 10;
    _viewBackground.layer.masksToBounds = YES;
    
    
    _thumbImageView.frame = CGRectMake(10, 10, 160, 90);
    _thumbImageView.backgroundColor = [UIColor redColor];
    
    _uploadStateLabel.frame  = CGRectMake(SCREEN_WIDTH - 80 * SCREEN_RATE - 10, 50, 80 * SCREEN_RATE, 16);
    _uploadStateLabel.backgroundColor = [UIColor greenColor];

    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
