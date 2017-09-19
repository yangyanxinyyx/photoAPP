//
//  GoodsShelfModel.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 23/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GoodsDirection) {
    GoodsDirectionHorizontal,
    GoodsDirectionVertical,
};

typedef NSString * GoodsUploadState;
extern GoodsUploadState const GoodsUploadStateSuccess;
extern GoodsUploadState const GoodsUploadStateUploading;
extern GoodsUploadState const GoodsUploadStateFail;

@interface GoodsShelfModel : NSObject
@property (nonatomic,assign) GoodsDirection goodDirection;

@property (nonatomic,strong) NSString *dbid;
@property (nonatomic,strong) NSString *imageCount;
@property (nonatomic,strong) NSString *thumbLink;
@property (nonatomic,strong) NSString *imagePaths;
@property (nonatomic,strong) NSString *failArrays;
@property (nonatomic,strong) GoodsUploadState goodUploadState;
@property (nonatomic,strong) NSString *addTime;

@end
