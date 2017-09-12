
//
//  CameraViewController.m
//  takePhotoAPP
//
//  Created by admin on 30/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GSChoosePhotosView.h"
#import "CustomCollectionViewLayout.h"
#import "UIImage+imageHelper.h"
#import "GSThumbnailViewCell.h"
#import "GSImage.h"
#import <CoreMotion/CoreMotion.h>
#import "GSProgressView.h"
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
typedef NS_ENUM(NSInteger, kImageDataType) {
    kImageDataVerticallyType = 1, //竖直方向
    kImageDataHorizontalType, //横向方向
};
@interface CameraViewController ()<UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,GSProgressViewDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier; //后台任务标识
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, assign) CGFloat beginGestureScale;
@property (nonatomic, assign) CGFloat effectiveScale;
@property (nonatomic, strong) UIView *contentView;

//顶部
@property (nonatomic, strong) UIButton *OrSoButton; //左右
@property (nonatomic, strong) UIButton *upAndDownButton; //上下
@property (nonatomic, strong) UIButton *flashButton; //闪光

//底部
@property (nonatomic, strong) UIScrollView * tabScrollView ;
@property (nonatomic, strong) UIButton *accomplishButton;
@property (nonatomic, strong) UIButton *takePhotButton;     //拍照按钮;
@property (nonatomic, strong) UIButton * goForwardBtn;
@property (nonatomic, strong) UIImageView *showImageView;

/** 第二页leftButton */
@property (nonatomic, strong) UIButton *goBackBtn;
@property (nonatomic, strong) GSChoosePhotosView * imageChooseView ;
@property (nonatomic, strong) CustomCollectionViewLayout * imageChooseViewLayout ;

@property (nonatomic, strong) UIView *segmentView1;
@property (nonatomic, strong) UIView *segmentView2;
@property (nonatomic, strong) UIView *segmentView3;
@property (nonatomic, strong) UIView *segmentView4;

@property (nonatomic, strong) UIImageView *imageViewOverlap; //重叠图片视图
@property (nonatomic, strong) UIImage *imageOverlap;
@property (nonatomic, strong) NSMutableArray *arrayImages;

@property (nonatomic) BOOL isorSo;
@property (nonatomic) BOOL isUpDown;
@property (nonatomic) BOOL isFlash;
@property (nonatomic) BOOL isAngle;

@property (nonatomic, strong) UIImageView *angleImageView;
@property (nonatomic, strong) GSProgressView *progressView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    _isorSo = YES;
    _isUpDown = NO;
    _isAngle = YES;
    _isFlash = NO;
    [self getImageDataWithType:kImageDataVerticallyType imageArray:self.arrayImages];//模拟数据
    
    [self setupUI];
    [self setInitMotionMangager];
    [self initCamera];
    [self setUpGesture];
    [self.captureSession startRunning];
    self.effectiveScale = self.beginGestureScale = 1.0f;

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.captureSession) {
        [self.captureSession stopRunning];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma makr - Camera
- (void)initCamera{
    
    _captureSession = [[AVCaptureSession alloc] init];
    
    if ([_captureSession canSetSessionPreset: AVCaptureSessionPreset1920x1080]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    
    //获取输入设备
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!captureDevice) {
        NSLog(@"取得后置摄像头出现问题");
        return;
    }
    [captureDevice lockForConfiguration:nil];
    [captureDevice setFlashMode:AVCaptureFlashModeOff];
    [captureDevice unlockForConfiguration];
    NSError *error;
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"输出Error:%@",error);
    }
    
    self.captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.captureStillImageOutput setOutputSettings:outputSettings];
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
        [self.captureSession addOutput:self.captureStillImageOutput];
    }
    
    //初始化预览图层
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.captureVideoPreviewLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT);
    self.contentView.layer.masksToBounds = YES;
    [self.contentView.layer addSublayer:self.captureVideoPreviewLayer];
    
    
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

- (AVCaptureVideoOrientation)AVCaptureVideoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        result = AVCaptureVideoOrientationLandscapeRight;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        result = AVCaptureVideoOrientationLandscapeLeft;
    }
    return  result;
}

//属性改变操作
- (void)changeDeviceProperty:(PropertyChangeBlock ) propertyChange{
    
    AVCaptureDevice * captureDevice = [self.captureDeviceInput device];
    NSError * error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        
    } else {
        
        NSLog(@"设置设备属性过程发生错误，错误信息：%@", error.localizedDescription);
    }
}
#pragma mark - 手势
- (void)setUpGesture{
    UIPinchGestureRecognizer *pinch  = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
//    [self.contentView addGestureRecognizer:pinch];
}

#pragma mark - GestureRecognizer delegate 
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark 拍照
- (void)takePhotoButtonClick:(UIButton *)sender{
   
    AVCaptureConnection *stillImageConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation currenDeciceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation captureOrientation = [self AVCaptureVideoOrientationForDeviceOrientation:currenDeciceOrientation];
    [stillImageConnection setVideoOrientation:captureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:jpegData];
        self.imageOverlap = image;
        NSMutableArray *array = [self.arrayImages lastObject];
        [array addObject:image];
       
        
        
        
        [self setImageOverlapFrame];
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
            NSLog(@"无权限");
            return ;
        }
        [self.captureSession stopRunning];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
            [self.captureSession startRunning];
        }];
    }];
    
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
 
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches];
    NSUInteger i;
    for (i = 0; i < numTouches; i++) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.contentView];
        CGPoint convertedLocation = [self.captureVideoPreviewLayer convertPoint:location fromLayer:self.captureVideoPreviewLayer.superlayer];
        if (! [self.captureVideoPreviewLayer containsPoint:convertedLocation]) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    if (allTouchesAreOnThePreviewLayer) {
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0) {
            self.effectiveScale = 1.0;
        }
        NSLog(@"%f ------------- %f ------------- recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        CGFloat maxScaleAndCropFactor = [[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor) {
            self.effectiveScale = maxScaleAndCropFactor;
        }
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.25f];
        [self.captureVideoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
}

#pragma mark 拼图
- (void)setImageOverlapFrame{
    if (_imageOverlap) {
        if (_isorSo) {
            self.imageViewOverlap.frame = CGRectMake(- SCREEN_WIDTH / 3 * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.imageViewOverlap.image = self.imageOverlap;
            self.imageViewOverlap.alpha = 0.5;
        }
        if (_isUpDown) {
            self.imageViewOverlap.frame = CGRectMake(0, - SCREEN_HEIGHT / 3 * 2, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.imageViewOverlap.image = self.imageOverlap;
            self.imageViewOverlap.alpha = 0.5;
        }
    }
}
#pragma mark - Init Method
- (void)setupUI{
    [self.view addSubview:self.contentView];
    
    [self.view addSubview:self.imageViewOverlap];
    [self.view addSubview:self.segmentView1];
    [self.view addSubview:self.segmentView2];
    [self.view addSubview:self.segmentView3];
    [self.view addSubview:self.segmentView4];
    
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.OrSoButton];
    [self.topView addSubview:self.upAndDownButton];
    [self.topView addSubview:self.flashButton];
    
    [self.view addSubview:self.tabView];
    [self.tabView addSubview:self.tabScrollView];
    [self.tabScrollView addSubview:self.accomplishButton];
    [self.tabScrollView addSubview:self.takePhotButton];
    [self.tabScrollView addSubview:self.goForwardBtn];
    [self.tabScrollView addSubview:self.showImageView];
    [self.tabScrollView addSubview:self.goBackBtn];
    [self.tabScrollView addSubview:self.imageChooseView];
    
    [self.view addSubview:self.angleImageView];
    [self.view addSubview:self.progressView];
    
    
}

- (void)setInitMotionMangager{
    CMMotionManager *motionManager = [[CMMotionManager alloc]init];
    
    NSOperationQueue*queue = [[NSOperationQueue alloc]init];
    
    //加速计
    
    if(motionManager.accelerometerAvailable) {
        
        motionManager.accelerometerUpdateInterval = 0.5;
        
        [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData*accelerometerData,NSError*error){
            
            if(error) {
                
                [motionManager stopAccelerometerUpdates];
                
                NSLog(@"error");
                
            }else{
                
                double zTheta = atan2(accelerometerData.acceleration.z,sqrtf(accelerometerData.acceleration.x*accelerometerData.acceleration.x+accelerometerData.acceleration.y*accelerometerData.acceleration.y))/M_PI*(-90.0)*2-90;


                if (-zTheta > 45 && -zTheta < 135 ) {
                    _isAngle = YES;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
                        self.takePhotButton.userInteractionEnabled = YES;
                      self.angleImageView.image = [UIImage imageNamed:@"equilibristat"];
                    });
                    
                } else {
                    _isAngle = NO;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_gray"] forState:UIControlStateNormal];
                        self.takePhotButton.userInteractionEnabled = NO;
                        self.angleImageView.image = [UIImage imageNamed:@"equilibristat_red"];
                    });
                    
                }
            }
            
        }];
        
    }else{
        
        NSLog(@"This device has no accelerometer");
        
    }

}

#pragma mark - Action Method
//左右按钮
- (void)toucheOrSOButtonValue:(UIButton *)sender{
    if (!_isorSo) {
        [sender setBackgroundImage:[UIImage imageNamed:@"OrSo"] forState:UIControlStateNormal];
        [_upAndDownButton setBackgroundImage:[UIImage imageNamed:@"upDown_gray"] forState:UIControlStateNormal];
        _upAndDownButton.userInteractionEnabled = YES;
        sender.userInteractionEnabled = NO;
    }
    _isorSo = !_isorSo;
    _isUpDown = !_isUpDown;
    
    NSMutableArray *arrayImage = [self.arrayImages lastObject];
    if (arrayImage.count >0) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arrayImages addObject:array];
    }
    self.imageOverlap = nil;
    self.imageViewOverlap.alpha = 0;
}

//上下
- (void)toucheUpAndDownButton:(UIButton *)sender{
    
    if (!_isUpDown){
        [sender setBackgroundImage:[UIImage imageNamed:@"upDown"] forState:UIControlStateNormal];
        [_OrSoButton setBackgroundImage:[UIImage imageNamed:@"OrSo_gray"] forState:UIControlStateNormal];
        _OrSoButton.userInteractionEnabled = YES;
        sender.userInteractionEnabled = NO;
    }
    _isUpDown = !_isUpDown;
    _isorSo = !_isorSo;
    self.imageOverlap = nil;
    self.imageViewOverlap.alpha = 0;
}

//闪光灯
- (void)toucheFlashButton:(UIButton *)sender{
    if (!_isFlash) {
        [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
            if ([captureDevice isFlashModeSupported:AVCaptureFlashModeOn]) {
                [captureDevice setFlashMode:AVCaptureFlashModeOn];
            }
        }];
        [sender setBackgroundImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];

        [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
            if ([captureDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
                [captureDevice setFlashMode:AVCaptureFlashModeOff];
            }
        }];

    }
    _isFlash = !_isFlash;
    
}

//完成
- (void)toucheAccomoplishButton:(UIButton *)sender{
    
}

- (void)goForWardBtnClick:(UIButton *)button {
    [self.tabScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
}

- (void)goBackBtnClick:(UIButton *)button {
    [self.tabScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
#pragma mark - Privacy Method

- (NSArray *)getImageDataWithType:(kImageDataType)imageType imageArray:(NSArray *)imageArray {
    
    switch (imageType) {
        case kImageDataVerticallyType: {
            NSMutableArray *imageDataArr = [[NSMutableArray alloc] init];

            for (NSArray *sectionArr in imageArray) {
                for (UIImage *image in sectionArr) {
                    
                    [imageDataArr addObject:image];
                }
            }
            return imageDataArr;
        }
            break;
        case kImageDataHorizontalType: {
            NSMutableArray *imageDataArr = [[NSMutableArray alloc] init];
            NSMutableArray *upArrM = [[NSMutableArray alloc] init];
            
            for (NSArray *sectionArr in imageArray) {
                
                if (sectionArr.count == 1) {
                    [upArrM addObject:[sectionArr objectAtIndex:0]];
                }
            }
            [imageDataArr addObject:upArrM];
            return imageDataArr;
        }
        default:
            break;
    }
    NSAssert(YES, @"imageData 数据错误");
    
}

#pragma mark - UICollectionViewDelegate&UICollectionViewDataSource

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    
//    int sectionCount = 0;
////    if (_isorSo) {
////        sectionCount = 1;
////    }
////    if (_isUpDown) {
////        sectionCount = 2;
////    }
//    
//    return sec;
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    NSArray *imageData = [self getImageDataWithType:kImageDataVerticallyType imageArray:self.arrayImages];
    
    return imageData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *imageData = [self getImageDataWithType:kImageDataVerticallyType imageArray:self.arrayImages];

    GSThumbnailViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GSChoosePhotosView getReuseItemsName] forIndexPath:indexPath];
    
    GSImage *image = [imageData objectAtIndex:indexPath.row];
//    image.imageID = indexPath.row;
    UIImage *thumb = [UIImage getThumbnailWidthImage:image size:cell.frame.size];
    UIImageView *imageView =[[UIImageView alloc] initWithImage:thumb];
    
    [cell.contentView addSubview:imageView];

    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width =  collectionView.frame.size.width;
    CGFloat height = collectionView.frame.size.height;
    
    CGFloat itemsWidth = width / 5.0;
    CGFloat itemsHeight ;
    
    if (_isorSo) {
        itemsHeight = height - 2 * kTabViewTopMargin  ;
    }else {
        itemsHeight = height / 2.0 - 2 * kTabViewTopMargin;
    }
   
    return CGSizeMake(itemsWidth, itemsHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"====>%ld===>%ld",(long)indexPath.section,(long)indexPath.row);
    
    
}

#pragma mark - Setter&Getter

#pragma mark -- Content
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _contentView.userInteractionEnabled = YES;
    }
    return _contentView;
}


- (UIView *)segmentView1{
    if (!_segmentView1) {
        _segmentView1 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3, 0, 1, SCREEN_HEIGHT)];
        _segmentView1.backgroundColor = [UIColor whiteColor];
    }
    return _segmentView1;
}

- (UIView *)segmentView2{
    if (!_segmentView2) {
        _segmentView2 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 3 * 2, 0, 1, SCREEN_HEIGHT)];
        _segmentView2.backgroundColor = [UIColor whiteColor];
    }
    return _segmentView2;
}

- (UIView *)segmentView3{
    if (!_segmentView3) {
        _segmentView3 = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT / 3, SCREEN_WIDTH, 1)];
        _segmentView3.backgroundColor = [UIColor whiteColor];
    }
    return _segmentView3;
}

- (UIView *)segmentView4 {
    if (!_segmentView4) {
        _segmentView4 = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT / 3 * 2, SCREEN_WIDTH, 1)];
        _segmentView4.backgroundColor = [UIColor whiteColor];
    }
    return _segmentView4;
}

- (UIImageView *)imageViewOverlap{
    if (!_imageViewOverlap) {
        _imageViewOverlap = [[UIImageView alloc]initWithFrame:CGRectMake(0, - SCREEN_HEIGHT / 3 * 2, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _imageViewOverlap.alpha = 0;
    }
    return _imageViewOverlap;
}

#pragma mark -- Top
- (UIButton *)OrSoButton{
    if (!_OrSoButton) {
        _OrSoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _OrSoButton.frame = CGRectMake(30 * SCREEN_RATE, 22 , 32 * SCREEN_RATE, 32 * SCREEN_RATE);
        [_OrSoButton setBackgroundImage:[UIImage imageNamed:@"OrSo"] forState:UIControlStateNormal];
        [_OrSoButton addTarget:self action:@selector(toucheOrSOButtonValue:) forControlEvents:UIControlEventTouchDown];
        _OrSoButton.userInteractionEnabled = NO;
    }
    return _OrSoButton;
}

- (UIButton *)upAndDownButton{
    if (!_upAndDownButton) {
        _upAndDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _upAndDownButton.frame = CGRectMake((SCREEN_WIDTH - (32 * SCREEN_RATE))/2, 22, 32 * SCREEN_RATE, 32 *SCREEN_RATE);
        [_upAndDownButton setBackgroundImage:[UIImage imageNamed:@"upDown_gray"] forState:UIControlStateNormal];
        [_upAndDownButton addTarget:self action:@selector(toucheUpAndDownButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _upAndDownButton;
}

- (UIButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.frame = CGRectMake(SCREEN_WIDTH - (72 * SCREEN_RATE), 22, 32 * SCREEN_RATE, 32 * SCREEN_RATE);
        [_flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(toucheFlashButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _flashButton;
}

#pragma mark -- bottom
- (UIScrollView *)tabScrollView {
    
    if (!_tabScrollView) {
        _tabScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,self.tabView.frame.size.width, self.tabView.frame.size.height)];
        _tabScrollView.scrollEnabled = NO;
        _tabScrollView.contentSize = CGSizeMake(2 * SCREEN_WIDTH , 0);
    }
    return _tabScrollView;
}

- (UIButton *)accomplishButton{
    if (!_accomplishButton) {
        _accomplishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _accomplishButton.frame = CGRectMake(10 , 50 , 40, 15 );
        [_accomplishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_accomplishButton setTitleColor:[UIColor colorWithRed:213 / 255.0 green:43 / 255.0 blue:39 / 255.0 alpha:1] forState:UIControlStateNormal];
        [_accomplishButton addTarget:self action:@selector(toucheAccomoplishButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _accomplishButton;
}

- (UIButton *)takePhotButton{
    if (!_takePhotButton) {
        _takePhotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _takePhotButton.frame = CGRectMake((SCREEN_WIDTH - 70 * SCREEN_RATE) / 2 , kTabViewTopMargin, 70 * SCREEN_RATE, 70 * SCREEN_RATE);
        _takePhotButton.layer.masksToBounds = YES;
        _takePhotButton.layer.cornerRadius = 35;
        [_takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
        [_takePhotButton addTarget:self action:@selector(takePhotoButtonClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _takePhotButton;
}

- (UIButton *)goForwardBtn {
    if (!_goForwardBtn) {
        _goForwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goForwardBtn.frame = CGRectMake(SCREEN_WIDTH - 86 , 0, 38, 113 - 10);
        [_goForwardBtn setBackgroundImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
        
        [_goForwardBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_goForwardBtn addTarget:self action:@selector(goForWardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goForwardBtn;
}

- (UIImageView *)showImageView{
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 48, (113 - 50 ) / 2, 38 , 50 )];
        _showImageView.image = [UIImage imageNamed:@"thumbnail"];
        
    }
    return _showImageView;
}

- (UIButton *)goBackBtn {
    if (!_goBackBtn) {
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = 50;
        _goBackBtn.frame = CGRectMake(SCREEN_WIDTH + kTabViewLeftMargin, kTabViewTopMargin, width, self.tabScrollView.frame.size.height - 2 * kTabViewTopMargin);
        [_goBackBtn setBackgroundImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
        [_goBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_goBackBtn addTarget:self action:@selector(goBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goBackBtn;
}

- (GSChoosePhotosView *)imageChooseView {
    
    if (!_imageChooseView) {
        CGFloat tabViewW = self.tabView.frame.size.width;
        CGFloat tabViewH = self.tabView.frame.size.height;
        CGFloat goBackBtnW = self.goBackBtn.frame.size.width;
        CGFloat preViewBtnW = 65;
        
        self.imageChooseViewLayout = [[CustomCollectionViewLayout alloc] init];
        self.imageChooseViewLayout.minimumLineSpacing = 8;
        self.imageChooseViewLayout.minimumInteritemSpacing = 8;
        self.imageChooseViewLayout.sectionInset = UIEdgeInsetsMake(12, 8, 12, 8);
        
        _imageChooseView = [[GSChoosePhotosView alloc] initWithFrame:
                            CGRectMake(SCREEN_WIDTH + goBackBtnW + kTabViewLeftMargin,
                                       kTabViewTopMargin,
                                       tabViewW - goBackBtnW - 2 * kTabViewLeftMargin - preViewBtnW - kTabViewRightMargin , tabViewH - 2 * kTabViewTopMargin) collectionViewLayout:self.imageChooseViewLayout];
        
        _imageChooseView.backgroundColor = [UIColor blueColor];
        _imageChooseView.dataSource = self;
        _imageChooseView.delegate = self;

    }
    
    return _imageChooseView;
    
}

- (UIImageView *)angleImageView{
    if (!_angleImageView) {
        _angleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150 * SCREEN_RATE, 100 * SCREEN_RATE)];
        _angleImageView.center = self.view.center;
        _angleImageView.image = [UIImage imageNamed:@"equilibristat"];
    }
    return _angleImageView;
}

- (GSProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[GSProgressView alloc]initWithFrame:CGRectMake(61 * SCREEN_RATE, SCREEN_HEIGHT - 113 - 50 * SCREEN_RATE, 250 * SCREEN_RATE, 50 * SCREEN_RATE)];
        _progressView.delgegate = self;
        
    }
    return _progressView;
}
#pragma mark --Other

- (NSMutableArray *)arrayImages{
    if (!_arrayImages) {
        _arrayImages = [NSMutableArray array];
        
        int photosCount = 10;
//        int sectionCount = 2;
        int rowCount = 2;

        for (int i = 1 ; i <= photosCount/rowCount ; i++) {
            
            NSMutableArray *array = [NSMutableArray array];

            for (int row = 1 ; row <= rowCount; row++) {
                
                UIImage *image = [UIImage imageNamed:@"000.JPG"];
                [array addObject:image];
            }
            [_arrayImages addObject:array];
        }
        
    }
    return _arrayImages;
}
#pragma mark GSPregressViewDelegate
- (void)camerScaleWithSliderValue:(float)sliderValue{
    self.effectiveScale = self.beginGestureScale * (sliderValue);
    if (self.effectiveScale < 1.0) {
        self.effectiveScale = 1.0;
    }

    CGFloat maxScaleAndCropFactor = [[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
    NSLog(@"%f",maxScaleAndCropFactor);
    if (self.effectiveScale > maxScaleAndCropFactor) {
        self.effectiveScale = maxScaleAndCropFactor;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25f];
    [self.captureVideoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
    [CATransaction commit];

}
@end
