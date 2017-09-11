//
//  GoodsShelfPreViewViewController.m
//  takePhotoAPP
//
//  Created by Melody on 2017/9/9.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GoodsShelfPreViewViewController.h"
#import "CustomCollectionViewLayout.h"
#import "GSChoosePhotosView.h"
#define kTabViewLeftButtonWidth 30
#define kTabViewMargin 8
#define kTabViewRightBuffonWidth 65

@interface GoodsShelfPreViewViewController ()

/** <# 注释 #> */
@property (nonatomic ,strong) GSChoosePhotosView * imageChooseView ;

/** <# 注释 #> */
@property (nonatomic ,strong) CustomCollectionViewLayout * selectPhotosLayout ;

/** <# 注释 #> */
@property (nonatomic ,strong) UIButton * goBackButton ;

/** <# 注释 #> */
@property (nonatomic ,strong) UIButton * prew ;

@end

@implementation GoodsShelfPreViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
}



#pragma mark - Init Method
- (void)setUI {
    
    self.view.backgroundColor = [UIColor orangeColor];
    [self.tabView addSubview:self.goBackButton];
    [self.tabView addSubview:self.imageChooseView];
    
}
#pragma mark - Action Method
- (void)toucheUpAndDownButton:(UIButton *)button {
    
}

- (void)toucheOrSOButtonValue:(UIButton *)button {
    
}

- (void)toucheFlashButton:(UIButton *)button {
    
}

- (void)goBackClick:(UIButton *)button {
    NSLog(@"=====>GOBack");
}

#pragma mark - Privacy Method

#pragma mark - Setter&Getter

- (GSChoosePhotosView *)imageChooseView {
    
    if (!_imageChooseView) {
        CGFloat tabViewW = self.tabView.frame.size.width;
        CGFloat tabViewH = self.tabView.frame.size.height;
        _imageChooseView = [[GSChoosePhotosView alloc] initWithFrame:
                            CGRectMake(kTabViewLeftButtonWidth + kTabViewMargin,
                                       kTabViewMargin,
                                       tabViewW - kTabViewLeftButtonWidth - 2 * kTabViewMargin - kTabViewRightBuffonWidth - kTabViewMargin , tabViewH - 2 * kTabViewMargin) collectionViewLayout:self.selectPhotosLayout];
        _imageChooseView.backgroundColor = [UIColor blueColor];
    }
    
    return _imageChooseView;
    
}

- (CustomCollectionViewLayout *)selectPhotosLayout {
    
    if (!_selectPhotosLayout) {
        _selectPhotosLayout = [[CustomCollectionViewLayout alloc] init];
        
    }
    
    return _selectPhotosLayout;
}

- (UIButton *)goBackButton {
    
    if (!_goBackButton) {
        _goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackButton.frame = CGRectMake(0, kTabViewMargin, kTabViewLeftButtonWidth, self.tabView.frame.size.height - 2 * kTabViewMargin);
        [_goBackButton setTitle:@"go" forState:UIControlStateNormal];
        [_goBackButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_goBackButton setImage:[UIImage imageNamed:<#(nonnull NSString *)#>] forState:<#(UIControlState)#>]
        [_goBackButton addTarget:self action:@selector(goBackClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goBackButton;
}

@end
