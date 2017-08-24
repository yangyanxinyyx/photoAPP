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

typedef NS_ENUM(NSInteger, GoodsUploadState) {
    GoodsUploadStateSuccess,
    GoodsUploadStateUploading,
    GoodsUploadStateFail,
};

@interface GoodsShelfModel : NSObject

@property (nonatomic,assign) BOOL isLast;

@property (nonatomic,assign) NSInteger imageCount;
@property (nonatomic,assign) GoodsDirection goodDirection;

@property (nonatomic,strong) NSString *imagePath;
@property (nonatomic,assign) GoodsUploadState goodUploadState;

@end
