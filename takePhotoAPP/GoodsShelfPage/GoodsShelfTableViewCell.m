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
        _uploadStateLabel.font = [UIFont systemFontOfSize:16];
        [self.viewBackground addSubview:_uploadStateLabel];
        
        self.iconImageView = [[UIImageView alloc] init];
        [self.viewBackground addSubview:_iconImageView];
        
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

    if ([self.uploadState isKindOfClass:[NSString class]]) {
        if ([self.uploadState isEqualToString: GoodsUploadStateSuccess]) {
            _uploadStateLabel.text = @"已上传";
            _uploadStateLabel.textColor = UICOLOR(246, 188, 1, 1);
            [_uploadStateLabel sizeToFit];
            _uploadStateLabel.frame = CGRectMake(_viewBackground.frame.size.width - _uploadStateLabel.frame.size.width - 15 , (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, _uploadStateLabel.frame.size.width, _uploadStateLabel.frame.size.height);
            UIImage *image = [UIImage imageNamed:@"upload_succes"];
            self.iconImageView.image = image;
            self.iconImageView.frame = CGRectMake(_uploadStateLabel.frame.origin.x - 8 - image.size.width, (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, image.size.width, image.size.height);
            
        }else if ([self.uploadState isEqualToString: GoodsUploadStateUploading]){
            _uploadStateLabel.text = @"正在上传...";
            _uploadStateLabel.textColor = UICOLOR(213, 41, 39, 1);
            [_uploadStateLabel sizeToFit];
            _uploadStateLabel.frame = CGRectMake(185, (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, _uploadStateLabel.frame.size.width, _uploadStateLabel.frame.size.height);
            self.iconImageView.image = nil;
            
        }else if ([self.uploadState isEqualToString: GoodsUploadStateFail]){
            _uploadStateLabel.text = @"上传失败";
            _uploadStateLabel.textColor = UICOLOR(213, 41, 39, 1);
            [_uploadStateLabel sizeToFit];
            _uploadStateLabel.frame = CGRectMake(_viewBackground.frame.size.width - _uploadStateLabel.frame.size.width - 15 , (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, _uploadStateLabel.frame.size.width, _uploadStateLabel.frame.size.height);
            self.iconImageView.image = nil;
        }
    }
}

//- (void)changeUploadstate:(GoodsUploadState *)state{
//    
//    if ([state isKindOfClass:[NSString class]]) {
//        if ([self.uploadState isEqualToString: GoodsUploadStateSuccess]) {
//            _uploadStateLabel.text = @"已上传";
//            _uploadStateLabel.textColor = UICOLOR(246, 188, 1, 1);
//            [_uploadStateLabel sizeToFit];
//            _uploadStateLabel.frame = CGRectMake(_viewBackground.frame.size.width - _uploadStateLabel.frame.size.width - 15 , (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, _uploadStateLabel.frame.size.width, _uploadStateLabel.frame.size.height);
//            UIImage *image = [UIImage imageNamed:@"upload_succes"];
//            self.iconImageView.image = image;
//            self.iconImageView.frame = CGRectMake(_uploadStateLabel.frame.origin.x - 8 - image.size.width, (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, image.size.width, image.size.height);
//            
//        }else if ([state isEqualToString: GoodsUploadStateUploading]){
//            _uploadStateLabel.text = @"正在上传...";
//            _uploadStateLabel.textColor = UICOLOR(213, 41, 39, 1);
//            [_uploadStateLabel sizeToFit];
//            _uploadStateLabel.frame = CGRectMake(185, (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, _uploadStateLabel.frame.size.width, _uploadStateLabel.frame.size.height);
//            self.iconImageView.image = nil;
//            
//        }else if ([state isEqualToString: GoodsUploadStateFail]){
//            _uploadStateLabel.text = @"上传失败";
//            _uploadStateLabel.textColor = UICOLOR(213, 41, 39, 1);
//            [_uploadStateLabel sizeToFit];
//            _uploadStateLabel.frame = CGRectMake(_viewBackground.frame.size.width - _uploadStateLabel.frame.size.width - 15 , (self.contentView.frame.size.height - _uploadStateLabel.frame.size.height)/2, _uploadStateLabel.frame.size.width, _uploadStateLabel.frame.size.height);
//            self.iconImageView.image = nil;
//        }
//    }
//}

- (void)setUploadState:(GoodsUploadState)uploadState
{
    _uploadState = uploadState;
    [self setNeedsLayout];
    [self layoutIfNeeded];
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
