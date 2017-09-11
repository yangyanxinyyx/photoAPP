//
//  UIImage+imageHelper.h
//  takePhotosTestDemo
//
//  Created by Melody on 2017/8/21.
//  Copyright © 2017年 Melody. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageHelper)

/**
  等比缩放、图片

 @param sourceimage 源图片
 @param newImageWidth 缩放后图片宽度，像素为单位
 @return self-->(image)
 */
+ (UIImage *)compressImage:(UIImage *)sourceimage newWidth:(CGFloat)newImageWidth;

+ (UIImage *)compressImage:(UIImage *)sourceimage newSize:(CGSize)newSize;

+ (UIImage *)getThumbnailWidthImage:(UIImage *)image size:(CGSize)size;
/**
 指定Size按比例缩放、裁剪图片（超出会被裁剪）

 @param targetSize 指定宽高大小
 @param sourceImage 源图片
 @return  self-->(image)
 */
+ (UIImage*)imageByScalingAndClipForSize:(CGSize)targetSize sourceImage:(UIImage *)sourceImage;

@end
