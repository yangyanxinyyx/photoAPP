//
//  GSProgressView.m
//  takePhotoAPP
//
//  Created by admin on 11/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GSProgressView.h"

@interface GSProgressView ()
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIImageView *identificationImageView;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UISlider *progressSlider;
@end


@implementation GSProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        [self addSubview:self.progressView];
//        [self addSubview:self.identificationImageView];
        [self addSubview:self.progressSlider];
        [self addSubview:self.numberLabel];
    }
    return self;
}

//- (UIView *)progressView{
//    if (!_progressView) {
//        _progressView = [[UIView alloc]initWithFrame:CGRectMake(0.5, 45 * SCREEN_RATE, 250 * SCREEN_RATE, 5 * SCREEN_RATE)];
//        _progressView.backgroundColor = [UIColor colorWithRed:246 / 255.0 green:188 / 255.0 blue:1 / 255.0 alpha:1];
//    }
//    return _progressView;
//}
//
//- (UIImageView *)identificationImageView{
//    if (!_identificationImageView) {
//        _identificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 37.5 * SCREEN_RATE, 20 * SCREEN_RATE, 20 * SCREEN_RATE)];
//        _identificationImageView.layer.masksToBounds = YES;
//        _identificationImageView.layer.cornerRadius = 10 * SCREEN_RATE;
//        _identificationImageView.image = [UIImage imageNamed:@"amplifier"];
//        _identificationImageView.userInteractionEnabled = YES;
//        
//        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changeScale:)];
//        [_identificationImageView addGestureRecognizer:panGR];
//        
//    }
//    return _identificationImageView;
//}
//
//
//- (void)changeScale:(UIPanGestureRecognizer *)panGR{
//    CGPoint point = [panGR translationInView:_identificationImageView];
//    if (point.x > 0 ) {
//        if (_identificationImageView.frame.origin.x < SCREEN_RATE * 255) {
//            _identificationImageView.transform = CGAffineTransformTranslate(_identificationImageView.transform, point.x, 0);
//            [panGR setTranslation:CGPointZero inView:_identificationImageView];
//        } else {
//            _identificationImageView.frame = CGRectMake(255, 37.5 * SCREEN_RATE, 20 * SCREEN_RATE, 20 * SCREEN_RATE);
//        }
//    }
//    
//    if (point.x < 0) {
//        if (_identificationImageView.frame.origin.x > 0) {
//            _identificationImageView.transform = CGAffineTransformTranslate(_identificationImageView.transform, point.x, 0);
//            [panGR setTranslation:CGPointZero inView:_identificationImageView];
//        } else {
//            _identificationImageView.frame = CGRectMake(0, 37.5 * SCREEN_RATE, 20 * SCREEN_RATE, 20 * SCREEN_RATE);
//        }
//    }
//}

- (UISlider *)progressSlider{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 17.5 * SCREEN_RATE, 250 * SCREEN_RATE, 40 * SCREEN_RATE)];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"amplifier"] forState:UIControlStateNormal];
        _progressSlider.minimumTrackTintColor = [UIColor colorWithRed:246 / 255.0 green:188 / 255.0 blue:1 / 255.0 alpha:1];
        _progressSlider.maximumTrackTintColor = [UIColor colorWithRed:246 / 255.0 green:188 / 255.0 blue:1 / 255.0 alpha:1];
        _progressSlider.value = 1;
        _progressSlider.minimumValue = 1.0;
        _progressSlider.maximumValue = 3.0;
        [_progressSlider addTarget:self action:@selector(progressSliderValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}

- (UILabel *)numberLabel{
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10 * SCREEN_RATE, 40 * SCREEN_RATE, 12)];
        _numberLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        _numberLabel.text = [NSString stringWithFormat:@"1.0X"];
        _numberLabel.textAlignment = NSTextAlignmentLeft;
        _numberLabel.font = [UIFont systemFontOfSize:12];
    }
    return _numberLabel;
}
- (void)progressSliderValue:(UISlider *)sender{
    NSLog(@"123");
    _numberLabel.frame = CGRectMake((sender.value - 1) * 250 * SCREEN_RATE / 2, 10 * SCREEN_RATE, 40 * SCREEN_RATE, 12);
    _numberLabel.text = [NSString stringWithFormat:@"%.1fX",sender.value];
    [self.delgegate camerScaleWithSliderValue:sender.value];
}
- (void)setProgressViewWithProgress:(CGFloat)progress{
    if (progress > 3.0) {
        return;
    }
    _numberLabel.frame = CGRectMake((progress - 1) * 250 * SCREEN_RATE / 2, 10 * SCREEN_RATE, 40 * SCREEN_RATE, 12);
    _numberLabel.text = [NSString stringWithFormat:@"%.1fX",progress];
    self.progressSlider.value = progress;
}
@end
