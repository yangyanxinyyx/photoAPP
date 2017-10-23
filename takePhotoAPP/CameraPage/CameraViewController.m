
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
#import "ImageModel.h"
#import "GSPrewViewController.h"
#import "GoodsShelfViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "BIAlertViewController.h"

#define IMAGEVIEWOVERLAPHEIGHT      (SCREEN_HEIGHT - TOPVIEW_HEIGHT -TABVIEW_HEIGHT)

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

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
@property (nonatomic, strong) UIButton * preViewBtn ;

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
@property (nonatomic, strong) UIImageView *focusCursorImageView;
@property (nonatomic, strong) GSProgressView *progressView;

@property (nonatomic, assign) NSInteger numberOrSos;
@property (nonatomic) BOOL isSingleModel;

@property (nonatomic, strong) UIView *rephotographTopView;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIImageView *rephotographImageView;
@property (nonatomic, strong) UIButton *rephotographButton;
@property (nonatomic, assign) BOOL isRephotograph;
@property (nonatomic, assign) NSUInteger selectImageIndex;

@property (nonatomic, strong) NSMutableArray *imageFileArray;

@property (nonatomic, strong) UIButton *rephotographTakePhotoButton;

@property (nonatomic) BOOL isOwner;

@property (nonatomic, strong) NSString * puzzlePath ;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _selectImageIndex = -1;
    _isorSo = NO;
    _isUpDown = YES;
    _isAngle = YES;
    _isFlash = NO;
    _isSingleModel = NO;
    _isRephotograph = NO;
    _numberOrSos = 0;
    _isOwner = NO;
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAppSkip) name:NOTIFICATIONSKIP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationVesion:) name:NOTIFICATIONVESION object:nil];
    [self setupUI];
    [self setInitMotionMangager];
    [self setUpGesture];

    self.effectiveScale = self.beginGestureScale = 1.0f;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"isURL"] isEqualToString:@"url"]) {
        _isOwner = YES;
        if (!self.captureSession) {
            [self initCamera];
        }
        [self.captureSession startRunning];
        [defaults setObject:@"" forKey:@"isURL"];
    }

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // =================== modify by Liangyz
    if ([[NSFileManager defaultManager] fileExistsAtPath:_puzzlePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_puzzlePath error:nil];
    }
    unlink([_puzzlePath UTF8String]);
    // ===================
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:VERSION];
    if ([version isEqualToString:@"0.0.1"] ) {
        NSString *userID = [defaults objectForKey:USERID];
        if (userID == nil || [userID isEqualToString:@""]) {
            _isOwner = NO;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请从微信公众号”活该赚“跳转" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            _isOwner = YES;
            [self.captureSession startRunning];
        }
    } else {
        _isOwner = YES;
        [self.captureSession startRunning];
    }
    
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

- (void)clearData{
 
    [self goBackBtnClick:nil];
    [self clearData1];
}

- (void)clearData1{
    [self.arrayImages removeAllObjects];
    [self.imageFileArray removeAllObjects];
    self.showImageView.image = nil;
    _selectImageIndex = -1;
    _isAngle = YES;
    _isFlash = NO;
    _isRephotograph = NO;
    _numberOrSos = 0;
    self.imageOverlap = nil;
    self.imageViewOverlap.alpha = 0;
    [self.imageChooseView reloadData];
}
#pragma makr - Camera
- (void)initCamera{
    
    _captureSession = [[AVCaptureSession alloc] init];
    
    if ([_captureSession canSetSessionPreset: AVCaptureSessionPreset640x480]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
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
    [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResize];
    self.captureVideoPreviewLayer.frame = CGRectMake(0, TOPVIEW_HEIGHT, SCREEN_WIDTH , SCREEN_HEIGHT - TOPVIEW_HEIGHT - TABVIEW_HEIGHT);
    self.contentView.layer.masksToBounds = YES;
    [self.contentView.layer addSublayer:self.captureVideoPreviewLayer];
    [self addGenstureRecognizer];
    
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
    [self.contentView addGestureRecognizer:pinch];
}

//添加点击手势，点按时聚焦
- (void)addGenstureRecognizer{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [self.contentView addGestureRecognizer:tapGesture];
}

#pragma mark - GestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

- (void)tapScreen:(UITapGestureRecognizer *) tapGesture{
    
    CGPoint point = [tapGesture locationInView:self.contentView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

//设置聚焦光标位置
- (void)setFocusCursorWithPoint:(CGPoint)point{
    
    self.focusCursorImageView.center = point;
    self.angleImageView.center = point;
    self.focusCursorImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursorImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

//设置聚焦点
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
        
    }];
}
#pragma mark 拍照
- (void)takePhotoButtonClick:(UIButton *)sender{
    if (!_isOwner) {
        return;
    }
    
    //相机权限
    AVAuthorizationStatus authSatatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authSatatus == AVAuthorizationStatusRestricted || authSatatus == AVAuthorizationStatusDenied) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"活该赚想访问您的相机" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"不允许" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertC addAction:action];
        [alertC addAction:action1];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    
    self.rephotographTakePhotoButton.userInteractionEnabled = NO;
    self.takePhotButton.userInteractionEnabled = NO;
    
    AVCaptureConnection *stillImageConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation currenDeciceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation captureOrientation = [self AVCaptureVideoOrientationForDeviceOrientation:currenDeciceOrientation];
    [stillImageConnection setVideoOrientation:captureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *imageTakePhoto = [UIImage imageWithData:jpegData];
        UIImage *image = [self redrawImage:imageTakePhoto inStandardSize:1800.0f];
        self.imageOverlap = image;
        //重拍
        if (_isRephotograph) {
            ImageModel *model = [self.arrayImages objectAtIndex:_selectImageIndex];
            [self saveImageFilewithIndex:_selectImageIndex];
            model.imageFile = [self.imageFileArray objectAtIndex:_selectImageIndex];
            dispatch_async(dispatch_get_main_queue(), ^{
              
                [self goForWardBtnClick:nil];
                _isRephotograph = NO;
            });
            
            
        } else {
            [self saveImageFilewithIndex:-1];
            ImageModel *model = [[ImageModel alloc] init];
            model.imageFile = [self.imageFileArray lastObject];
            [self.arrayImages addObject:model];
            self.showImageView.image = self.imageOverlap;
            if (_isSingleModel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self setImageOverlapFrameWithType:0 image:self.imageOverlap];
                });
         
            } else {
                NSInteger index = self.imageFileArray.count % 2;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (index == 0) {
                        NSString *imageFile = [self.imageFileArray objectAtIndex:(self.imageFileArray.count - 2)];
                        UIImage *image = [UIImage imageWithContentsOfFile:imageFile];
                       [self setImageOverlapFrameWithType:0 image:image];
                    } else {
                        [self setImageOverlapFrameWithType:1 image:self.imageOverlap];
                    }
                });
                
                    
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self.imageChooseView reloadData];
            self.takePhotButton.userInteractionEnabled = YES;
            self.rephotographTakePhotoButton.userInteractionEnabled = YES;
        });
        
        
//        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
//        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
//        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
//            NSLog(@"无权限");
//            return ;
//        }
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//            });
//        }];
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
        if (self.effectiveScale > 3.0) {
            self.effectiveScale = 3.0;
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
        [self.progressView setProgressViewWithProgress:self.effectiveScale];
    }
}

#pragma mark 拼图
- (void)setImageOverlapFrameWithType:(NSInteger) index image:(UIImage *)image{
    if (_imageOverlap) {
        if (index == 0) {
            self.imageViewOverlap.frame = CGRectMake(- SCREEN_WIDTH + 100 * SCREEN_RATE, TOPVIEW_HEIGHT, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
            self.imageViewOverlap.image = image;
            self.imageViewOverlap.alpha = ALPHA;
        } else{
            self.imageViewOverlap.frame = CGRectMake(0, - IMAGEVIEWOVERLAPHEIGHT  + TOPVIEW_HEIGHT + 75 * SCREEN_RATE, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
            self.imageViewOverlap.image = image;
            self.imageViewOverlap.alpha = ALPHA;
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
    [self.view addSubview:self.rephotographTakePhotoButton];
    [self.view addSubview:self.angleImageView];
    [self.view addSubview:self.focusCursorImageView];
    [self.view addSubview:self.progressView];
    
    
    [self.view addSubview:self.rephotographImageView];
    
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
    [self.tabScrollView addSubview:self.preViewBtn];
    
    [self.view addSubview:self.rephotographTopView];
    [self.rephotographTopView addSubview:self.cancleButton];
    [self.rephotographImageView addSubview:self.rephotographButton];
    
}

//水平仪
- (void)setInitMotionMangager{
    CMMotionManager *motionManager = [[CMMotionManager alloc]init];
    
    NSOperationQueue*queue = [[NSOperationQueue alloc]init];
    
    //加速计
    
    if(motionManager.accelerometerAvailable) {
        
        motionManager.accelerometerUpdateInterval = 0.05;
        
        [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData*accelerometerData,NSError*error){
            
            if(error) {
                
                [motionManager stopAccelerometerUpdates];
                
                NSLog(@"error");
                
            }else{
                
                double zTheta = atan2(accelerometerData.acceleration.z,sqrtf(accelerometerData.acceleration.x*accelerometerData.acceleration.x+accelerometerData.acceleration.y*accelerometerData.acceleration.y))/M_PI*(-90.0)*2-90;
                
                double xyTheta = atan2(accelerometerData.acceleration.y,accelerometerData.acceleration.x)/M_PI*180.0;
                double zxTheta = atan2(accelerometerData.acceleration.z, accelerometerData.acceleration.x) / M_PI * 180.0;
                if (-zTheta > 60 && -zTheta < 120 ) {
                   // NSLog(@"==>%f",zxTheta);
                    if (-xyTheta > 85 && -xyTheta < 95) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
                            self.takePhotButton.userInteractionEnabled = YES;
                            self.angleImageView.image = [UIImage imageNamed:@"equilibristat"];
                            self.focusCursorImageView.image = [UIImage imageNamed:@"focusCursor"];
                            [self.rephotographTakePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_white"] forState:UIControlStateNormal];
                            self.rephotographTakePhotoButton.userInteractionEnabled = YES;
                            self.contentView.userInteractionEnabled = YES;
                        });
                    } else {
                        _isAngle = NO;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_gray"] forState:UIControlStateNormal];
                            self.takePhotButton.userInteractionEnabled = NO;
                            self.angleImageView.image = [UIImage imageNamed:@"equilibristat_red"];
                            self.focusCursorImageView.image = [UIImage imageNamed:@"focusCursor_whiter"];
                            self.contentView.userInteractionEnabled = NO;
                            [self.rephotographTakePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_gray"] forState:UIControlStateNormal];
                            self.rephotographTakePhotoButton.userInteractionEnabled = NO;
                        });
                    }
                    
                } else {
                    _isAngle = NO;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_gray"] forState:UIControlStateNormal];
                        self.takePhotButton.userInteractionEnabled = NO;
                        self.angleImageView.image = [UIImage imageNamed:@"equilibristat_red"];
                        self.focusCursorImageView.image = [UIImage imageNamed:@"focusCursor_whiter"];
                        self.contentView.userInteractionEnabled = NO;
                        [self.rephotographTakePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_gray"] forState:UIControlStateNormal];
                        self.rephotographTakePhotoButton.userInteractionEnabled = NO;
                    });
                }
                
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                   self.angleImageView.transform = CGAffineTransformMakeRotation(3.14159 / 180 * (zTheta + 90));
                });
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
    
    self.imageViewOverlap.alpha = 0;
    _isSingleModel = !_isSingleModel;
    _isRephotograph = NO;
    [self clearData1];
//    if (self.imageOverlap && !_isSingleModel) {
//        if (self.arrayImages.count == 1) {
//            [self.arrayImages removeAllObjects];
//            self.imageViewOverlap.alpha = 0;
//            self.showImageView.image = nil;
//            [self.imageChooseView reloadData];
//
//            return;
//        }
//        self.imageViewOverlap.frame = CGRectMake(- SCREEN_WIDTH / 3 * 2, TOPVIEW_HEIGHT, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
//        ImageModel *model = [self.arrayImages objectAtIndex:(self.arrayImages.count - 2)];
//        self.imageViewOverlap.image = [UIImage imageWithContentsOfFile:model.imageFile];
//        self.imageViewOverlap.alpha = ALPHA;
//
//
//
//    }
    
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
    _isSingleModel = !_isSingleModel;
    self.imageViewOverlap.alpha = 0;
    _isRephotograph = NO;
    [self clearData1];
//    if (!_isSingleModel) {
//        [self.arrayImages removeAllObjects];
//        self.imageViewOverlap.alpha = 0;
//        self.showImageView.image = nil;
//        [self.imageChooseView reloadData];
//        return;
//    }
//    if (!self.arrayImages) {
//        return;
//    }
//    if (self.imageOverlap && !_isSingleModel ) {
//        self.imageViewOverlap.frame = CGRectMake(0, - IMAGEVIEWOVERLAPHEIGHT / 3 * 2 + TOPVIEW_HEIGHT, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
//        ImageModel *model = [self.arrayImages objectAtIndex:self.arrayImages.count - 1];
//        self.imageViewOverlap.image = [UIImage imageWithContentsOfFile:model.imageFile];
//        self.imageViewOverlap.alpha = ALPHA;
//    }
    
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

#pragma maark- 完成
- (void)toucheAccomoplishButton:(UIButton *)sender{
    
//    [self saveImageFile];
    
//    GoodsShelfViewController *goodSVC = [[GoodsShelfViewController alloc] init];
//    [self.navigationController pushViewController:goodSVC animated:YES];
    [self priViewBtnClick:nil];
}


- (void)saveImageFilewithIndex:(NSInteger)index{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *novelPath =  [docPath stringByAppendingPathComponent:@"tmp"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:novelPath]) {
        NSLog(@"已存在");
    }else{
        NSLog(@"不存在");
        [manager createDirectoryAtPath:novelPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (index == -1) {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a = [dat timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%f", a];
        NSInteger number = [timeString integerValue];
        NSString *timeStringNumber = [NSString stringWithFormat:@"%ld",number];
        NSString *imageFile = [novelPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",timeStringNumber]];
        NSData *imageData = UIImageJPEGRepresentation(self.imageOverlap, 1);
        BOOL result = [imageData writeToFile:imageFile atomically:YES];
        if (result) {
            [self.imageFileArray addObject:imageFile];
            NSLog(@"写入图片=====%@",imageFile);
        } else {
            NSLog(@"写入失败");
        }
    } else {
        NSString *imageFile =  [self.imageFileArray objectAtIndex:index];
        BOOL result = [manager removeItemAtPath:imageFile error:nil];
        if (result) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
        NSData *imageData = UIImageJPEGRepresentation(self.imageOverlap, 1);
        BOOL resultWrite = [imageData writeToFile:imageFile atomically:YES];
        if (resultWrite) {
            [self.imageFileArray replaceObjectAtIndex:index withObject:imageFile];
        } else {
            NSLog(@"写入失败");
        }
    }
 
}


- (void)goForWardBtnClick:(UIButton *)button {
    self.rephotographTakePhotoButton.alpha = 1;
    self.progressView.alpha = 0;
    [self.tabScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
    [self.imageChooseView reloadData];
    if (_isRephotograph) {
        if (_isSingleModel) {
            
        }
        ImageModel *model = [self.arrayImages lastObject];
        self.imageOverlap = [UIImage imageWithContentsOfFile:model.imageFile];
        [self setImageOverlapFrameWithType:self.imageFileArray.count % 2 image:self.imageOverlap];
    }
    
    
}

- (void)goBackBtnClick:(UIButton *)button {
    self.rephotographTakePhotoButton.alpha = 0;
    self.progressView.alpha = 1;
    [self.tabScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
        self.rephotographTopView.frame = CGRectMake(0, -64, SCREEN_WIDTH, 64);
        self.rephotographImageView.alpha = 0;
        self.rephotographButton.alpha = 0;
    }];
    for (ImageModel *model in self.arrayImages) {
        model.isSelect = NO;
    }
}

- (void)priViewBtnClick:(UIButton *)button {
    
    if (self.arrayImages.count == 0 || self.imageFileArray.count == 0 ) {
        return;
    }
    if (!_isSingleModel) {
        if ((self.imageFileArray.count % 2 != 0) ) {
            BIAlertViewController *alertVC = [BIAlertViewController alertControllerWithMessage:@"竖拍模式，请保持偶数张照片"];
            
            BIAlertAction *confirm = [BIAlertAction actionWithTitle:@"确认" style:BIAlertActionStyleDefault handler:^(BIAlertAction * _Nonnull action) {
            }];
            
            [alertVC addAction:confirm];
            [self presentViewController:alertVC animated:YES completion:NULL];
            return ;
        }
    }
//    [self saveImageFile]; //保存 成文件路径
    [SVProgressHUD showWithStatus:@"正在处理.."];
    self.preViewBtn.enabled = NO;
    [SVProgressHUD setForegroundColor:ORANGECOLOR];
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        NSMutableDictionary *imageDateInfo = [[NSMutableDictionary alloc] init];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSString *imagePath in self.imageFileArray) {
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            [images addObject:image];
        }
        
        NSArray *puzzleArr = [self savePuzzlePhotos:images];
        NSString *puzzlePath = [puzzleArr firstObject];
        NSString *puzzleThumbPath = [puzzleArr lastObject];
        
        NSNumber * photosModel = [NSNumber numberWithBool:_isSingleModel];
        [imageDateInfo setValue:[NSMutableArray arrayWithArray:self.imageFileArray] forKey:kpuzzleImagePath];
        [imageDateInfo setValue:photosModel forKey:kpuzzleMode];
        [imageDateInfo setValue:puzzlePath forKey:kpuzzlePath];
        [imageDateInfo setValue:puzzleThumbPath forKey:kpuzzleThumbPath];
        
        if (self.arrayImages.count == 0) {
            NSAssert(YES, @"preView 有毒？？？");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            self.preViewBtn.enabled = YES;
            GSPrewViewController *GSPreView = [[GSPrewViewController alloc] init];
            if (self.puzzlePath) {
                GSPreView.puzzlePath = self.puzzlePath;
            }
            GSPreView.imageDateInfo = imageDateInfo ;
            [self.navigationController pushViewController:GSPreView animated:YES];
        });

    });

}

- (void)touchCancleButton{
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
        self.rephotographTopView.frame = CGRectMake(0, -64, SCREEN_WIDTH, 64);
        self.rephotographImageView.alpha = 0;
        self.rephotographButton.alpha = 0;
    }];
    for (ImageModel *model in self.arrayImages) {
        model.isSelect = NO;
    }
    [self.imageChooseView reloadData];
    
}

//重拍
- (void)toucheRephotgraphButton{
    self.isRephotograph = YES;
    self.rephotographButton.alpha = 0;
    self.rephotographTakePhotoButton.alpha = 0;
    self.progressView.alpha = 1;
    [self goBackBtnClick:nil];
    if (_isSingleModel) {
        if (self.arrayImages.count == 1) {
            self.imageViewOverlap.alpha = 0;
            return;
        }
        if (_selectImageIndex == 0) {
            ImageModel *model = [self.arrayImages objectAtIndex:_selectImageIndex + 1];
            self.imageOverlap = [UIImage imageWithContentsOfFile:model.imageFile];
            self.imageViewOverlap.frame = CGRectMake(SCREEN_WIDTH - 100 * SCREEN_RATE, TOPVIEW_HEIGHT, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
            self.imageViewOverlap.image = self.imageOverlap;
            self.imageViewOverlap.alpha = ALPHA;
            return;
        }
        ImageModel *model = [self.arrayImages objectAtIndex:_selectImageIndex - 1];
        self.imageOverlap = [UIImage imageWithContentsOfFile:model.imageFile];
        self.imageViewOverlap.frame = CGRectMake(-SCREEN_WIDTH + SCREEN_RATE * 100, TOPVIEW_HEIGHT, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
        self.imageViewOverlap.image = self.imageOverlap;
        self.imageViewOverlap.alpha = ALPHA;
        
    } else {
        if (self.arrayImages.count == 1) {
            self.imageViewOverlap.alpha = 0;
            return;
        } else {
            if (_selectImageIndex == 0) {
                ImageModel *model = [self.arrayImages objectAtIndex:_selectImageIndex + 1];
                self.imageOverlap = [UIImage imageWithContentsOfFile:model.imageFile];
                self.imageViewOverlap.frame = CGRectMake(0, IMAGEVIEWOVERLAPHEIGHT + TOPVIEW_HEIGHT - 75 * SCREEN_RATE, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
                self.imageViewOverlap.image = self.imageOverlap;
                self.imageViewOverlap.alpha = ALPHA;
            } else{
                if (_selectImageIndex % 2 != 0) {
                    ImageModel *model = [self.arrayImages objectAtIndex:_selectImageIndex - 1];
                    self.imageOverlap = [UIImage imageWithContentsOfFile:model.imageFile];
                    self.imageViewOverlap.frame = CGRectMake(0, - IMAGEVIEWOVERLAPHEIGHT + TOPVIEW_HEIGHT + 75 * SCREEN_RATE, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
                    self.imageViewOverlap.image = self.imageOverlap;
                    self.imageViewOverlap.alpha = ALPHA;
                } else {
                    ImageModel *model = [self.arrayImages objectAtIndex:_selectImageIndex - 2];
                    self.imageOverlap = [UIImage imageWithContentsOfFile:model.imageFile];
                    self.imageViewOverlap.frame = CGRectMake( - SCREEN_WIDTH + SCREEN_RATE * 100, TOPVIEW_HEIGHT, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT);
                    self.imageViewOverlap.image = self.imageOverlap;
                    self.imageViewOverlap.alpha = ALPHA;
                }
            }
        }
    }
}

- (void)toucheRephotographTakePhotoButtonValue:(UIButton *)send{
    
}

#pragma mark - Privacy Method

- (NSArray *)savePuzzlePhotos:(NSArray *)images {
    
    NSMutableArray *composeImageArrM = [[NSMutableArray alloc] init];
    CGFloat composeScale = 1.0;

    if (images.count > 5) {
        if (images.count > 20) {
            composeScale = 0.3;
        }else {
            composeScale = 0.5;
        }
    }
    for (UIImage *image in images) {
        UIImage *composeImage = [UIImage compressImage:image newSize:CGSizeMake(image.size.width * composeScale, image.size.height * composeScale)];
        [composeImageArrM addObject:composeImage];
    }
    
    UIImage *puzzle = [UIImage imageMergeImagesWithMergeModel:self.isSingleModel images:composeImageArrM];
    UIImage *puzzleThumb = [UIImage compressImage:puzzle newSize:kGoodsShelfPuzzleSize];

    self.puzzlePath = [self imageSaveToTmp:puzzle];
//    NSString *puzzlePath =  [self imageSaveToTmp:puzzle];
    NSString *puzzleThumbPath = [self imageSaveToTmp:puzzleThumb];
    
    if (_puzzlePath && puzzleThumbPath) {
        return @[_puzzlePath,puzzleThumbPath];
    }
    NSAssert(YES, @"savePuzzlePhotoPathError");
    return nil;
}

- (NSString *)imageSaveToTmp:(UIImage *)image {
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *novelPath =  [docPath stringByAppendingPathComponent:@"tmp"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:novelPath]) {
    }else{
        [manager createDirectoryAtPath:novelPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    NSString *imageFile = [novelPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",timeString]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    BOOL result = [imageData writeToFile:imageFile atomically:YES];
    if (result) {
        return imageFile;
    }
    NSAssert(YES, @"imageSaveWithError");
    return nil;
}

#pragma mark - UICollectionViewDelegate&UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    
    return self.arrayImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    GSThumbnailViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GSChoosePhotosView getReuseItemsName] forIndexPath:indexPath];
    
    ImageModel *model = [self.arrayImages objectAtIndex:indexPath.row];
    cell.itemImageView.image = [UIImage imageWithContentsOfFile:model.imageFile];
    cell.isSelect = model.isSelect;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    CGFloat width =  collectionView.frame.size.width;
    CGFloat height = collectionView.frame.size.height;
    
    CGFloat itemsWidth = 90 * 0.5;
    CGFloat itemsHeight ;
    
    if (_isSingleModel) {
        CGFloat ktopMargin = 64 * 0.5 - 48 * 0.5;
        itemsHeight = height - 2 * ktopMargin  ;
    }else {
        itemsHeight = (height - 5 )/ 2.0 ;
    }
    
    return CGSizeMake(itemsWidth, itemsHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"====>%ld===>%ld",(long)indexPath.section,(long)indexPath.row);
    ImageModel *model = [self.arrayImages objectAtIndex:indexPath.row];
    for (ImageModel *model in self.arrayImages) {
        model.isSelect = NO;
    }
    
    
    model.isSelect = YES;
    
    [self.imageChooseView reloadData];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = CGRectMake(0, -64, SCREEN_WIDTH, 64);
        self.rephotographTopView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
        _rephotographImageView.alpha = 1;
        _rephotographImageView.image = [UIImage imageWithContentsOfFile:model.imageFile];
        _rephotographButton.alpha = 1;
    }];
    _selectImageIndex = indexPath.row;
    
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
        _segmentView3 = [[UIView alloc]initWithFrame:CGRectMake(0, IMAGEVIEWOVERLAPHEIGHT / 3 + TOPVIEW_HEIGHT, SCREEN_WIDTH, 1)];
        _segmentView3.backgroundColor = [UIColor whiteColor];
    }
    return _segmentView3;
}

- (UIView *)segmentView4 {
    if (!_segmentView4) {
        _segmentView4 = [[UIView alloc]initWithFrame:CGRectMake(0, IMAGEVIEWOVERLAPHEIGHT / 3 * 2 + TOPVIEW_HEIGHT, SCREEN_WIDTH, 1)];
        _segmentView4.backgroundColor = [UIColor whiteColor];
    }
    return _segmentView4;
}

- (UIImageView *)imageViewOverlap{
    if (!_imageViewOverlap) {
        _imageViewOverlap = [[UIImageView alloc]initWithFrame:CGRectMake(0, - IMAGEVIEWOVERLAPHEIGHT / 3 * 2 + TOPVIEW_HEIGHT, SCREEN_WIDTH, IMAGEVIEWOVERLAPHEIGHT)];
        _imageViewOverlap.alpha = 0;
        
    }
    return _imageViewOverlap;
}

#pragma mark -- Top
- (UIButton *)OrSoButton{
    if (!_OrSoButton) {
        _OrSoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _OrSoButton.frame = CGRectMake((SCREEN_WIDTH - (32 * SCREEN_RATE))/2, 22, 32 * SCREEN_RATE, 32 *SCREEN_RATE);
        [_OrSoButton setBackgroundImage:[UIImage imageNamed:@"OrSo_gray"] forState:UIControlStateNormal];
        [_OrSoButton addTarget:self action:@selector(toucheOrSOButtonValue:) forControlEvents:UIControlEventTouchDown];
        
    }
    return _OrSoButton;
}

- (UIButton *)upAndDownButton{
    if (!_upAndDownButton) {
        _upAndDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _upAndDownButton.frame = CGRectMake(30 * SCREEN_RATE, 22 , 32 * SCREEN_RATE, 32 * SCREEN_RATE);
        [_upAndDownButton setBackgroundImage:[UIImage imageNamed:@"upDown"] forState:UIControlStateNormal];
        [_upAndDownButton addTarget:self action:@selector(toucheUpAndDownButton:) forControlEvents:UIControlEventTouchDown];
        _upAndDownButton.userInteractionEnabled = NO;
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
        _takePhotButton.layer.cornerRadius = 35 * SCREEN_RATE;
        [_takePhotButton setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
        [_takePhotButton addTarget:self action:@selector(takePhotoButtonClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _takePhotButton;
}

- (SEL)extracted {
    return @selector(goForWardBtnClick:);
}

- (UIButton *)goForwardBtn {
    if (!_goForwardBtn) {
        _goForwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goForwardBtn.frame = CGRectMake(SCREEN_WIDTH - 73 , 0, 20, 113);
        [_goForwardBtn setBackgroundImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
        
        [_goForwardBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_goForwardBtn addTarget:self action:[self extracted] forControlEvents:UIControlEventTouchUpInside];
    }
    return _goForwardBtn;
}

- (UIImageView *)showImageView{
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 48, (113 - 50 ) / 2, 38 , 50 )];
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        
    }
    return _showImageView;
}

#pragma mark -- 第二条
- (UIButton *)goBackBtn {
    if (!_goBackBtn) {
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = 20;
        _goBackBtn.frame = CGRectMake(SCREEN_WIDTH + kTabViewLeftMargin, 0, width, 113);
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
        CGFloat preViewBtnW = 50;
        
        self.imageChooseViewLayout = [[CustomCollectionViewLayout alloc] init];
        //        self.imageChooseViewLayout.minimumLineSpacing = 5;
        self.imageChooseViewLayout.minimumInteritemSpacing = 5;
        //        self.imageChooseViewLayout.sectionInset = UIEdgeInsetsMake(0,0,4,5);
        
        _imageChooseView = [[GSChoosePhotosView alloc] initWithFrame:
                            CGRectMake(SCREEN_WIDTH + goBackBtnW + 2 * kTabViewLeftMargin ,
                                       kCollectionViewTopMargin,
                                       tabViewW - goBackBtnW - 2 * kTabViewLeftMargin - preViewBtnW - 2 * kTabViewRightMargin , tabViewH - 2 * kCollectionViewTopMargin ) collectionViewLayout:self.imageChooseViewLayout];
        
        _imageChooseView.backgroundColor = [UIColor whiteColor];
        _imageChooseView.dataSource = self;
        _imageChooseView.delegate = self;
        
    }
    
    return _imageChooseView;
    
}

- (UIButton *)preViewBtn {
    
    if (!_preViewBtn) {
        CGFloat preViewBtnW = 50;
        CGFloat preViewBtnH = 25;
        _preViewBtn = [UIButton buttonWithType:0];
        _preViewBtn.layer.cornerRadius = 5;
        
        _preViewBtn.frame = CGRectMake(SCREEN_WIDTH +  SCREEN_WIDTH - (preViewBtnW + 10 ) , (self.tabScrollView.frame.size.height - preViewBtnH) * 0.5, preViewBtnW, preViewBtnH);
        _preViewBtn.backgroundColor = [UIColor colorWithRed:246/255.0 green:188/255.0 blue:1.0/255.0 alpha:1.0];
        [_preViewBtn.titleLabel setFrame:CGRectMake(6, 11, preViewBtnW - 6 * 2, preViewBtnH - 11 * 2)];
        [_preViewBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_preViewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_preViewBtn addTarget:self
                        action:@selector(priViewBtnClick:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _preViewBtn;
}

- (UIImageView *)angleImageView{
    if (!_angleImageView) {
        _angleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150 * SCREEN_RATE, 100 * SCREEN_RATE)];
        _angleImageView.center = CGPointMake(self.view.center.x, TOPVIEW_HEIGHT + IMAGEVIEWOVERLAPHEIGHT / 2);
        _angleImageView.image = [UIImage imageNamed:@"equilibristat"];
    }
    return _angleImageView;
}

- (UIImageView *)focusCursorImageView{
    if (!_focusCursorImageView) {
        _focusCursorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150 * SCREEN_RATE, 100 * SCREEN_RATE)];
        _focusCursorImageView.center =  CGPointMake(self.view.center.x, TOPVIEW_HEIGHT + IMAGEVIEWOVERLAPHEIGHT / 2);
        _focusCursorImageView.image = [UIImage imageNamed:@"focusCursor"];
    }
    return _focusCursorImageView;
}
- (GSProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[GSProgressView alloc]initWithFrame:CGRectMake(61 * SCREEN_RATE, SCREEN_HEIGHT - 113 - 50 * SCREEN_RATE, 250 * SCREEN_RATE, 50 * SCREEN_RATE)];
        _progressView.delgegate = self;
        
    }
    return _progressView;
}

- (UIView *)rephotographTopView{
    if (!_rephotographTopView) {
        _rephotographTopView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, SCREEN_WIDTH, 64)];
        _rephotographTopView.backgroundColor = ORANGECOLOR;
    }
    return _rephotographTopView;
}

- (UIButton *)cancleButton{
    if (!_cancleButton) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancleButton.frame = CGRectMake(SCREEN_WIDTH - 30 * SCREEN_RATE, 0, 20 * SCREEN_RATE, 64);
        [_cancleButton setBackgroundImage:[UIImage imageNamed:@"cancle"] forState:UIControlStateNormal];
        [_cancleButton addTarget:self action:@selector(touchCancleButton) forControlEvents:UIControlEventTouchDown];
    }
    return _cancleButton;
}
- (UIImageView *)rephotographImageView{
    if (!_rephotographImageView) {
        _rephotographImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, TOPVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - TOPVIEW_HEIGHT - TABVIEW_HEIGHT)];
        _rephotographImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rephotographImageView.alpha = 0;
        _rephotographImageView.userInteractionEnabled = YES;
    }
    return _rephotographImageView;
}

- (UIButton *)rephotographButton{
    if (!_rephotographButton) {
        _rephotographButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rephotographButton.frame = CGRectMake((SCREEN_WIDTH - 80 * SCREEN_RATE) / 2, SCREEN_HEIGHT - 60 * SCREEN_RATE - 113 - 64, 80 * SCREEN_RATE, 30 * SCREEN_RATE);
        _rephotographButton.backgroundColor = [UIColor colorWithRed:213 / 255.0 green:41 / 255.0 blue:39 / 255.0 alpha:1];
        [_rephotographButton setTitle:@"重拍" forState:UIControlStateNormal];
        [_rephotographButton setTitleColor:[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1] forState:UIControlStateNormal];
        _rephotographButton.layer.masksToBounds = YES;
        _rephotographButton.layer.cornerRadius = 10 * SCREEN_RATE;
        _rephotographButton.alpha = 0;
        [_rephotographButton addTarget:self action:@selector(toucheRephotgraphButton) forControlEvents:UIControlEventTouchDown];
    }
    return _rephotographButton;
}

- (NSMutableArray *)imageFileArray{
    if (!_imageFileArray) {
        _imageFileArray = [NSMutableArray array];
    }
    return _imageFileArray;
}

- (UIButton *)rephotographTakePhotoButton{
    if (!_rephotographTakePhotoButton) {
        _rephotographTakePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rephotographTakePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_white"] forState:UIControlStateNormal];
        _rephotographTakePhotoButton.frame = CGRectMake((SCREEN_WIDTH - 43 * SCREEN_RATE) / 2, SCREEN_HEIGHT - 113 - 63 * SCREEN_RATE, 43 * SCREEN_RATE, SCREEN_RATE * 43);
        _rephotographTakePhotoButton.alpha = 0;
        [_rephotographTakePhotoButton addTarget:self action:@selector(takePhotoButtonClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _rephotographTakePhotoButton;
}

#pragma mark --Other

- (NSMutableArray *)arrayImages{
    if (!_arrayImages) {
        _arrayImages = [NSMutableArray array];
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
    if (self.effectiveScale > maxScaleAndCropFactor) {
        self.effectiveScale = maxScaleAndCropFactor;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25f];
    [self.captureVideoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
    [CATransaction commit];
    
}

//图片压缩
- (UIImage *)redrawImage:(UIImage *)img inStandardSize:(float)standardSize {
    
    float width, height, scale;
    width = img.size.width;
    height = img.size.height;
    if (width == 0.0) {
        width = 1.0;
    }
    if (height == 0.0) {
        height = 1.0;
    }
    
    
    if (width > height) {
        scale = standardSize / width;
    }else {
        scale = standardSize / height;
    }
    
    //    if (width <= standardSize && height <= standardSize) {
    //        return img;
    //    }
    
    
    int imgW = width * scale;
    int imgH = height *scale;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imgW, imgH), NO, 1.0f);
    
    [img drawInRect:CGRectMake(0, 0,imgW, imgH)];
    
    UIImage *ret_img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return ret_img;
    
}

#pragma mark -跳转
- (void)notificationAppSkip{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:USERID];
    if ([userID isEqualToString:@""] || userID == NULL) {
        _isOwner = NO;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请从微信公众号”活该赚“跳转" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        _isOwner = YES;
        if (!self.captureSession) {
           [self initCamera];
        }
        [self.captureSession startRunning];
    }
}
- (void)notificationVesion:(NSNotification *)notificationCenter{
    NSLog(@"%@",notificationCenter.userInfo);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:USERID];
    if ([userID isEqualToString:@""] || userID == NULL) {
        _isOwner = NO;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请从微信公众号”活该赚“跳转" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        _isOwner = YES;
        [self initCamera];
        [self.captureSession startRunning];
    }

}
@end
