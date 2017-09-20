//
//  GSPrewViewController.m
//  takePhotoAPP
//
//  Created by Melody on 2017/9/16.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GSPrewViewController.h"
#import "GSChoosePhotosView.h"
#import "CustomCollectionViewLayout.h"
#import "GSThumbnailViewCell.h"
#import "ImageModel.h"
#import "GoodsShelfViewController.h"
#import "GoodsShelfDataManager.h"
#import "BIAlertViewController.h"
#define kNormalButtonWidth 20

@interface GSPrewViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UIButton * dismissBtn ;
@property (nonatomic, strong) UIButton * submitBtn ;

@property (nonatomic, strong) UIImageView * preView ;
@property (nonatomic, strong) GSChoosePhotosView * imageChooseView ;
@property (nonatomic, strong) UIButton * leftPreViewBtn ;
@property (nonatomic, strong) UIButton * rightPreViewBtn ;
/** <# 注释 #> */
@property (nonatomic, assign) NSInteger  selectImageIndex ;

///** <# 注释 #> */
//@property (nonatomic, strong) NSMutableArray * imageDataArrM ;
/** <# 注释 #> */
@property (nonatomic, strong) NSMutableArray * imageFilePathArrM ;
@end



@implementation GSPrewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    if (self.imageDateInfo) {
        self.imageFilePathArrM = self.imageDateInfo[@"image"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.imageChooseView) {
        [self.imageChooseView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Init Method
- (void)initUI {
//    if (SYSTEN_VERION >= 8.0) {
//        UIBlurEffect *effect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
//        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//        effectView.frame = self.view.frame;
//        [self.view insertSubview:effectView belowSubview:self.topView];
//    }else {
//        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT)];
//        toolbar.barStyle = UIBlurEffectStyleDark;
//        [self.view insertSubview:toolbar belowSubview:self.topView];
//    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.topView.backgroundColor = [UIColor colorWithRed:246/255.0 green:188/255.0 blue:1/255.0 alpha:1.0];
    [self.topView addSubview:self.dismissBtn];
    [self.topView addSubview:self.submitBtn];

    [self.tabView addSubview:self.imageChooseView];
    [self.tabView addSubview:self.leftPreViewBtn];
    [self.tabView addSubview:self.rightPreViewBtn];
    [self.view insertSubview:self.preView atIndex:0];
}

#pragma mark - Action Method

- (void)dismissbtnClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitbtnClick:(UIButton *)button {
   
    BIAlertViewController *alertVC = [BIAlertViewController alertControllerWithMessage:@"是否确认提交照片?"];
   
    BIAlertAction *confirm = [BIAlertAction actionWithTitle:@"确认" style:BIAlertActionStyleDefault handler:^(BIAlertAction * _Nonnull action) {
        
        NSString *path1 = [[NSBundle mainBundle] pathForResource:@"newsPic1" ofType:@"jpg"];
//        NSString *path2 = [[NSBundle mainBundle] pathForResource:@"newsPic2" ofType:@"jpg"];
//        NSString *path3 = [[NSBundle mainBundle] pathForResource:@"newsPic3" ofType:@"jpg"];
//        NSString *path4 = [[NSBundle mainBundle] pathForResource:@"newsPic4" ofType:@"jpg"];
//
        NSDictionary *param = @{@"thumbLink":[self.imageFilePathArrM firstObject],
                                @"imagePaths":self.imageFilePathArrM};
        [[GoodsShelfDataManager shareInstance] sendImageWithParam:param];
        GoodsShelfViewController *VC = [[GoodsShelfViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        
    }];
 
    [alertVC addAction:confirm];
    [self presentViewController:alertVC animated:YES completion:NULL];
    
    
   
}

- (void)leftBtnClick:(UIButton *)button {
    
}
- (void)rightBtnClick:(UIButton *)button {
    
}

#pragma mark - UICollectionViewDelegate&UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return self.imageDateArrM.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    GSThumbnailViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GSChoosePhotosView getReuseItemsName] forIndexPath:indexPath];
    cell.selected = NO ;
    ImageModel *model = [self.imageDateArrM objectAtIndex:indexPath.row];
    cell.itemImageView.image = model.image;
    cell.isSelect = model.isSelect;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    CGFloat width =  collectionView.frame.size.width;
    CGFloat height = collectionView.frame.size.height;
    CGFloat itemsWidth = 90 * 0.5;
    CGFloat itemsHeight ;
    CGFloat ktopMargin = 64 * 0.5 - 48 * 0.5;
    itemsHeight = height - 2 * ktopMargin  ;
//        itemsHeight = (height - 5 )/ 2.0 ;
    
    return CGSizeMake(itemsWidth, itemsHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"====>%ld===>%ld",(long)indexPath.section,(long)indexPath.row);

    self.selectImageIndex =  indexPath.row;
    
}

#pragma mark - Privacy Method

#pragma mark - Setter&Getter

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = kNormalButtonWidth;
        _dismissBtn.frame = CGRectMake( kTabViewLeftMargin,23, width, TOPVIEW_HEIGHT - 2 * 23);
        [_dismissBtn setBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        _dismissBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_dismissBtn addTarget:self action:@selector(dismissbtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _dismissBtn;
}

- (UIButton *)submitBtn {
    if (!_submitBtn) {
        CGFloat buttonW = 50 * SCREEN_RATE ;
        CGFloat buttonH = 64;
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.frame = CGRectMake(SCREEN_WIDTH - buttonW - kTabViewRightMargin, 0, buttonW , buttonH);
        [_submitBtn setTitle:@"提交" forState:0];
        [_submitBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submitbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

- (GSChoosePhotosView *)imageChooseView {
    
    if (!_imageChooseView) {
        CGFloat tabViewW = self.tabView.frame.size.width;
        CGFloat tabViewH = self.tabView.frame.size.height;
        CGFloat lefBtnW =kNormalButtonWidth,rightBtnW = kNormalButtonWidth;
        
        CustomCollectionViewLayout * flowLayout = [[CustomCollectionViewLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 5;
        
        _imageChooseView = [[GSChoosePhotosView alloc] initWithFrame:
                            CGRectMake( lefBtnW + 2 * kTabViewLeftMargin ,
                                       kCollectionViewTopMargin,
                                       tabViewW - lefBtnW - 2 * kTabViewLeftMargin - rightBtnW - 2 * kTabViewRightMargin , tabViewH - 2 * kCollectionViewTopMargin ) collectionViewLayout:flowLayout];
        
        _imageChooseView.backgroundColor = [UIColor whiteColor];
        _imageChooseView.dataSource = self;
        _imageChooseView.delegate = self;
    }
    
    return _imageChooseView;
}

- (UIButton *)leftPreViewBtn {
    if (!_leftPreViewBtn) {
        _leftPreViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = kNormalButtonWidth;
        _leftPreViewBtn.frame = CGRectMake( kTabViewLeftMargin,23, width, TABVIEW_HEIGHT - 2 * 23);
        [_leftPreViewBtn setBackgroundImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
        _leftPreViewBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_leftPreViewBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _leftPreViewBtn;
}

- (UIButton *)rightPreViewBtn {
    if (!_rightPreViewBtn) {
        _rightPreViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = kNormalButtonWidth;
        _rightPreViewBtn.frame = CGRectMake( SCREEN_WIDTH - width - kTabViewRightMargin,23, width, TABVIEW_HEIGHT - 2 * 23);
        [_rightPreViewBtn setBackgroundImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
        _rightPreViewBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_rightPreViewBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _rightPreViewBtn;
}

- (UIImageView *)preView {
    if (!_preView) {
        _preView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _preView.alpha = 0;
        _preView.userInteractionEnabled = YES;
    }
    return _preView;
}

- (void)setSelectImageIndex:(NSInteger)selectImageIndex {
    
    if (_selectImageIndex != selectImageIndex) {
        _selectImageIndex = selectImageIndex;
        ImageModel *model = [self.imageDateArrM objectAtIndex:selectImageIndex];
        for (ImageModel *model in self.imageDateArrM) {
            model.isSelect = NO;
        }
        model.isSelect = YES;
        [self.imageChooseView reloadData];
        
        [UIView animateWithDuration:0.3 animations:^{
            _preView.alpha = 1;
            _preView.image = model.image;
        }];
    }
    
}

@end
