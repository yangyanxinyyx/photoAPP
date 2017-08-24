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
        
        self.thumbImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_thumbImageView];
        
        self.uploadStateLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_uploadStateLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _thumbImageView.frame = CGRectMake(15, 15, 150 * SCREEN_RATE, 80 * SCREEN_RATE);
    
    _uploadStateLabel.frame  = CGRectMake(SCREEN_WIDTH - 80 * SCREEN_RATE - 10, 50, 80 * SCREEN_RATE, 50);

    
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
