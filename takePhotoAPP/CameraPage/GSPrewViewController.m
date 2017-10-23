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
#import "CGAffineTransformFun.h"
#import "UIImage+imageHelper.h"
#define kNormalButtonWidth 20

@interface GSPrewViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIButton * dismissBtn ;
@property (nonatomic, strong) UIButton * submitBtn ;

@property (nonatomic, strong) UIImageView * bgImageView ;

@property (nonatomic, strong) UIView * clipView ;
@property (nonatomic, strong) UIImageView * preView ;
@property (nonatomic, strong) GSChoosePhotosView * imageChooseView ;
@property (nonatomic, strong) UIButton * leftPreViewBtn ;
@property (nonatomic, strong) UIButton * rightPreViewBtn ;
/** <# 注释 #> */
@property (nonatomic, assign) NSInteger  selectImageIndex ;
/** <# 注释 #> */
@property (nonatomic, strong) NSMutableArray * imageDataArrM ;

@end

@implementation GSPrewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupData];
    [self initUI];
   
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

- (void)setupData {
    if (self.imageDateInfo) {
        NSArray *imagePathArr = self.imageDateInfo[kpuzzleImagePath];
        self.imageDataArrM = [[NSMutableArray alloc] init];
        for (NSString *imagePath in imagePathArr) {
            UIImage *image  = [UIImage imageWithContentsOfFile:imagePath];
            [self.imageDataArrM addObject:image];
        }
    }
    
}

- (void)initUI {
    
    
    self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    if (self.imageDataArrM) {
//        UIImage *bgImage =[self.imageDataArrM firstObject];
//        self.bgImageView.image = bgImage;
//    }
    if (SYSTEN_VERION >= 8.0) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = self.view.frame;
        [self.view insertSubview:effectView aboveSubview:self.bgImageView];
    }
    
    self.clipView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - TABVIEW_HEIGHT- TOPVIEW_HEIGHT)];
    self.preView = [[UIImageView alloc] initWithFrame:self.clipView.frame];
    UIImage *puzzle = [UIImage imageWithContentsOfFile:self.imageDateInfo[kpuzzlePath]];
    CGFloat puzzleRadio = puzzle.size.width / puzzle.size.height;
    CGFloat clipRadio = self.clipView.frame.size.width / self.clipView.frame.size.height;
    CGFloat newWidth;
    CGFloat newHeight;
    CGFloat newOffsetx;
    CGFloat newOffsety;
    if (clipRadio > puzzleRadio) {
        newOffsetx = 0;
        newWidth = self.clipView.frame.size.width;
        newHeight = newWidth / puzzleRadio;
        newOffsety = (newHeight - self.clipView.frame.size.height) * 0.5;
    }else {
        newOffsety = 0;
        newHeight = self.clipView.frame.size.height;
        newWidth = newHeight * puzzleRadio;
        newOffsetx = (newWidth - self.clipView.frame.size.width) * 0.5;
    }
    
    [self.preView setFrame:CGRectMake(0, 0, newWidth, newHeight)];
    
//    puzzle = [UIImage compressImage:puzzle newSize:[self resetPuzzleSize:puzzle.size clipViewSize:self.clipView.frame.size]];
    [self.preView setUserInteractionEnabled:YES];
    [self.preView setImage:puzzle];
    [self addGestureRecognizerToView];
    
    
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.clipView];
    [self.clipView addSubview:self.preView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.tabView];
    
    self.topView.backgroundColor = [UIColor colorWithRed:246/255.0 green:188/255.0 blue:1/255.0 alpha:1.0];
    [self.topView addSubview:self.dismissBtn];
    [self.topView addSubview:self.submitBtn];

    [self.tabView addSubview:self.imageChooseView];
    [self.tabView addSubview:self.leftPreViewBtn];
    [self.tabView addSubview:self.rightPreViewBtn];
}

#pragma mark - Action Method

- (void)dismissbtnClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitbtnClick:(UIButton *)button {
    if (!self.imageDateInfo) {
        return;
    }
    
    BIAlertViewController *alertVC = [BIAlertViewController alertControllerWithMessage:@"是否确认提交照片?"];
   
    BIAlertAction *confirm = [BIAlertAction actionWithTitle:@"确认" style:BIAlertActionStyleDefault handler:^(BIAlertAction * _Nonnull action) {
        
        NSArray *imagePathArr = self.imageDateInfo[kpuzzleImagePath];
        NSString *puzzleThumbImagePath = self.imageDateInfo[kpuzzleThumbPath];
        
        NSDictionary *param = @{@"thumbLink":puzzleThumbImagePath,
                                @"imagePaths":imagePathArr};
        [[GoodsShelfDataManager shareInstance] sendImageWithParam:param];
        GoodsShelfViewController *VC = [[GoodsShelfViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        
        // =================== modify by Liangyz
        if ([[NSFileManager defaultManager] fileExistsAtPath:_puzzlePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_puzzlePath error:nil];
        }
        unlink([_puzzlePath UTF8String]);
        // ===================
        
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
    
    return self.imageDataArrM.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    GSThumbnailViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GSChoosePhotosView getReuseItemsName] forIndexPath:indexPath];
    cell.selected = NO ;
    UIImage *image = [self.imageDataArrM objectAtIndex:indexPath.row];
    cell.itemImageView.image = image;
    
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

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"====>%ld===>%ld",(long)indexPath.section,(long)indexPath.row);
//
//    self.selectImageIndex =  indexPath.row;
//
//}

#pragma mark - Privacy Method

-(void)addGestureRecognizerToView{
    // 移动手势
    UIPanGestureRecognizer *_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    _panGestureRecognizer.delegate = self;
    [self.preView addGestureRecognizer:_panGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *_pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.preView addGestureRecognizer:_pinchGestureRecognizer];
    _pinchGestureRecognizer.delegate = self;
}


// 处理移动手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *panView = panGestureRecognizer.view;
    CGPoint translation = [panGestureRecognizer translationInView:panView.superview];
    panView.center = CGPointMake(panView.center.x + translation.x, panView.center.y+translation.y);
    [panGestureRecognizer setTranslation:CGPointZero inView:panView.superview];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self limitMoveRect];
    }
    
    return;
    
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *pinchView = pinchGestureRecognizer.view;
    CGFloat scale = pinchGestureRecognizer.scale;
    pinchView.transform = CGAffineTransformScale(pinchView.transform, scale, scale);
    pinchGestureRecognizer.scale = 1.0f;
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat scalex = [CGAffineTransformFun scaleXWithCGAffineTransform:pinchView.transform];
        if (scalex < 1) {
            [UIView animateWithDuration:0.3 animations:^{
                pinchView.transform = CGAffineTransformIdentity;
            }];
        }
        else if (scalex > 3) {
            [UIView animateWithDuration:0.3 animations:^{
                pinchView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 3, 3);
            }];
        }
        
        [self limitMoveRect];
    }
    return;
    
}

- (void)limitMoveRect
{
    CGRect frame = self.preView.frame;
    if (frame.origin.x > 1) {
        frame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height);
    }
    if (frame.origin.x+frame.size.width < self.clipView.frame.size.width - 1) {
        frame = CGRectMake(self.clipView.frame.size.width-frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
    }
    if (frame.origin.y > 1) {
        frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);
    }
    if (frame.origin.y+frame.size.height < self.clipView.frame.size.height - 1) {
        frame = CGRectMake(frame.origin.x, self.clipView.frame.size.height - frame.size.height, frame.size.width, frame.size.height);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.preView.frame = frame;
    }];
}

- (CGSize)resetPuzzleSize:(CGSize)puzzleSize clipViewSize:(CGSize)clipSize {
    
    CGFloat videoRadio = puzzleSize.width / (CGFloat)puzzleSize.height;
    CGFloat screenRadio = clipSize.width / (CGFloat)clipSize.height;
    
    CGFloat newVideoW;
    CGFloat newVideoH;
    if (videoRadio > screenRadio) {
        newVideoW = SCREEN_WIDTH;
        newVideoH = newVideoW / videoRadio;
    }else {
        newVideoH = SCREEN_HEIGHT;
        newVideoW = newVideoH * videoRadio;
    }
    
    if (newVideoW > SCREEN_WIDTH) {
        newVideoW = SCREEN_WIDTH;
        newVideoH = newVideoW / videoRadio;
    }
    if (newVideoH > clipSize.height) {
        newVideoH = clipSize.height;
        newVideoW = newVideoH * videoRadio;
    }
    
    return CGSizeMake(newVideoW, newVideoH);
}

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

- (void)setSelectImageIndex:(NSInteger)selectImageIndex {
    
    if (_selectImageIndex != selectImageIndex) {
        _selectImageIndex = selectImageIndex;
        ImageModel *model = [self.imageDataArrM objectAtIndex:selectImageIndex];
        for (ImageModel *model in self.imageDataArrM) {
            model.isSelect = NO;
        }
        model.isSelect = YES;
        [self.imageChooseView reloadData];
        
        [UIView animateWithDuration:0.3 animations:^{
            _preView.alpha = 1;
            _preView.image = [UIImage imageWithContentsOfFile:model.imageFile];
        }];
    }
}


@end
