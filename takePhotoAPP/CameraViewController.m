
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
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface CameraViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier; //后台任务标识
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, assign) CGFloat beginGestureScale;
@property (nonatomic, assign) CGFloat effectiveScale;
@property (nonatomic, strong) UIView *contentView;


@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *OrSoButton; //左右
@property (nonatomic, strong) UIButton *upAndDownButton; //上下
@property (nonatomic, strong) UIButton *flashButton; //闪光

@property (nonatomic, strong) UIView *tabView;
@property (nonatomic, strong) UIButton *accomplishButton;
@property (nonatomic, strong) UIButton *takePhotButton;     //拍照按钮;
@property (nonatomic, strong) UIImageView *showImageView;

@property (nonatomic, strong) UIView *segmentView1;
@property (nonatomic, strong) UIView *segmentView2;
@property (nonatomic, strong) UIView *segmentView3;
@property (nonatomic, strong) UIView *segmentView4;

@property (nonatomic, strong) UIImageView *imageViewOverlap; //重叠图片视图
@property (nonatomic, strong) UIImage *imageOverlap;
@property (nonatomic, strong) NSMutableArray *arrayImages;

@property (nonatomic) BOOL isorSo;
@property (nonatomic) BOOL isUpDown;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    _isorSo = YES;
    _isUpDown = NO;
    [self setupUI];
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
    [captureDevice setFlashMode:AVCaptureFlashModeAuto];
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
#pragma mark - 手势
- (void)setUpGesture{
    UIPinchGestureRecognizer *pinch  = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.contentView addGestureRecognizer:pinch];
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


#pragma mark - UI

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
    [self.tabView addSubview:self.accomplishButton];
    [self.tabView addSubview:self.takePhotButton];
    [self.tabView addSubview:self.showImageView];
    
}


- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _contentView.userInteractionEnabled = YES;
    }
    return _contentView;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64 * SCREEN_RATE)];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}
- (UIButton *)OrSoButton{
    if (!_OrSoButton) {
        _OrSoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _OrSoButton.frame = CGRectMake(40 * SCREEN_RATE, 22, 32 * SCREEN_RATE, 32 * SCREEN_RATE);
        [_OrSoButton setBackgroundImage:[UIImage imageNamed:@"orso"] forState:UIControlStateNormal];
        [_OrSoButton addTarget:self action:@selector(toucheOrSOButtonValue:) forControlEvents:UIControlEventTouchDown];
        _OrSoButton.userInteractionEnabled = NO;
    }
    return _OrSoButton;
}

- (UIButton *)upAndDownButton{
    if (!_upAndDownButton) {
        _upAndDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _upAndDownButton.frame = CGRectMake((SCREEN_WIDTH - (32 * SCREEN_RATE))/2, 22, 32 * SCREEN_RATE, 32 *SCREEN_RATE);
        [_upAndDownButton setBackgroundImage:[UIImage imageNamed:@"updownGray"] forState:UIControlStateNormal];
        [_upAndDownButton addTarget:self action:@selector(toucheUpAndDownButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _upAndDownButton;
}

- (UIButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.frame = CGRectMake(SCREEN_WIDTH - (72 * SCREEN_RATE), 22, 32 * SCREEN_RATE, 32 * SCREEN_RATE);
        [_flashButton setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(toucheFlashButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _flashButton;
}

- (UIView *)tabView{
    if (!_tabView) {
        _tabView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44)];
        _tabView.backgroundColor = [UIColor whiteColor];
    }
    return _tabView;
}

- (UIButton *)accomplishButton{
    if (!_accomplishButton) {
        _accomplishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _accomplishButton.frame = CGRectMake(40 * SCREEN_RATE, 5, 40, 32 * SCREEN_RATE);
        [_accomplishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_accomplishButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_accomplishButton addTarget:self action:@selector(toucheAccomoplishButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _accomplishButton;
}

- (UIButton *)takePhotButton{
    if (!_takePhotButton) {
        _takePhotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _takePhotButton.frame = CGRectMake((SCREEN_WIDTH - 40) / 2, 2, 40, 40);
        _takePhotButton.layer.masksToBounds = YES;
        _takePhotButton.layer.cornerRadius = 20;
        [_takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
        [_takePhotButton addTarget:self action:@selector(takePhotoButtonClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _takePhotButton;
}

- (UIImageView *)showImageView{
    if (_showImageView) {
        _showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 72 * SCREEN_RATE, 5, 32 * SCREEN_RATE, 32 *SCREEN_RATE)];
        _showImageView.backgroundColor = [UIColor orangeColor];
    }
    return _showImageView;
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

- (NSMutableArray *)arrayImages{
    if (!_arrayImages) {
        _arrayImages = [NSMutableArray array];
        NSMutableArray *array = [NSMutableArray array];
        [_arrayImages addObject:array];
    }
    return _arrayImages;
}
#pragma makr - function
//左右按钮
- (void)toucheOrSOButtonValue:(UIButton *)sender{
    if (!_isorSo) {
        [sender setBackgroundImage:[UIImage imageNamed:@"orso"] forState:UIControlStateNormal];
        [_upAndDownButton setBackgroundImage:[UIImage imageNamed:@"updownGray"] forState:UIControlStateNormal];
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
        [_OrSoButton setBackgroundImage:[UIImage imageNamed:@"soGray"] forState:UIControlStateNormal];
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
    
}

//完成
- (void)toucheAccomoplishButton:(UIButton *)sender{
    
}
@end
