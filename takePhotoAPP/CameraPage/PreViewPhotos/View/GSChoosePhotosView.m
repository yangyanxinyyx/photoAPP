//
//  GSChoosePhotosView.m
//  takePhotoAPP
//
//  Created by Melody on 2017/9/10.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GSChoosePhotosView.h"
#import "GSThumbnailViewCell.h"
#define kCollectionViewCellName @"myCell"

@implementation GSChoosePhotosView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    if (self==[super initWithFrame:frame collectionViewLayout:layout]) {
        
        [self registerClass:[GSThumbnailViewCell class] forCellWithReuseIdentifier:kCollectionViewCellName];
        
    }
    return self;
}

+ (NSString *)getReuseItemsName {
    return kCollectionViewCellName;
}

@end
