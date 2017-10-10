//
//  UIImage+imageHelper.m
//  takePhotosTestDemo
//
//  Created by Melody on 2017/8/21.
//  Copyright © 2017年 Melody. All rights reserved.
//

#import "UIImage+imageHelper.h"

#define kPuzzleMixLeftOffset(width) width * (100 *SCREEN_RATE/SCREEN_WIDTH)
#define kPuzzleMixUpOffset(height) height * (75 * SCREEN_RATE/(SCREEN_HEIGHT - 64 - 113))
//#define kPuzzleMixLeftOffset (100 *SCREEN_RATE/SCREEN_WIDTH)
//#define kPuzzleMixUpOffset (75 * SCREEN_RATE/(SCREEN_HEIGHT - 64 - 113))


@implementation UIImage (imageHelper)

#pragma mark - 图片压缩
- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)imageMergeImagesWithMergeModel:(BOOL)isvertiacl images:(NSArray *)images {
    
    NSMutableArray *newImages = [[NSMutableArray alloc] init];
    CGFloat WIDTH = 0;
    CGFloat HEIGHT = 0;
    for (UIImage *newImage in images) {
        [newImages addObject:[newImage fixOrientation]];
        WIDTH = newImage.size.width;
        HEIGHT = newImage.size.height;
    }
    CGSize size;
    NSInteger rowNum = 1;
    if (!isvertiacl) {
        rowNum = 2;
    }
    
//    size.width = SCREEN_WIDTH * (images.count/rowNum);
//    size.height = SCREEN_HEIGHT * rowNum;
    if (isvertiacl) {
        CGFloat sizeWidth = 0.0;
        CGFloat sizeHeight = HEIGHT;

        for (NSInteger i = 0 ; i < newImages.count; i++) {
            if (i == 0) {
                sizeWidth = WIDTH;
            }else {
                sizeWidth += (WIDTH - kPuzzleMixLeftOffset(WIDTH));
            }
        }
        size = CGSizeMake(sizeWidth, sizeHeight);
    }else {
        CGFloat sizeWidth = 0.0;
        CGFloat sizeHeight = HEIGHT + (HEIGHT - kPuzzleMixUpOffset(HEIGHT));
        
        NSInteger count = ceil(newImages.count/(float)rowNum);
        for (NSInteger i = 0 ; i < count; i++) {
            if (i == 0) {
                sizeWidth = WIDTH;
            }else {
                sizeWidth += (WIDTH - kPuzzleMixLeftOffset(WIDTH));
            }
        }
        size = CGSizeMake(sizeWidth, sizeHeight);
    }
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    if (isvertiacl) {
        for (NSInteger i = 0 ; i < newImages.count ; i++ ) {
            UIImage *image =[newImages objectAtIndex: i];
            if (i == 0) {
                [image drawInRect:CGRectMake( 0, 0, WIDTH , HEIGHT)];
            }else {
                [image drawInRect:CGRectMake((WIDTH - kPuzzleMixLeftOffset(WIDTH)) * i , 0, WIDTH , HEIGHT)];
            }

        }
    }else {
        NSMutableArray *upImageArrM = [[NSMutableArray alloc] init];
        NSMutableArray *downImageArrM = [[NSMutableArray alloc] init];
        for (NSInteger i = 1 ; i <= newImages.count; i++) {
            UIImage * image = newImages[i - 1];
            if (i%2 != 0) {
                [upImageArrM addObject:image];
            }else {
                [downImageArrM addObject:image];
            }
        }
        
        for (NSInteger i = 0 ; i < upImageArrM.count; i ++) {
            UIImage *upImage =[upImageArrM objectAtIndex: i];
            if (i == 0) {
                [upImage drawInRect:CGRectMake( 0 , 0, WIDTH , HEIGHT)];
            }else {
                [upImage drawInRect:CGRectMake((WIDTH - kPuzzleMixLeftOffset(WIDTH)) * i , 0, WIDTH , HEIGHT)];
            }
         
        }
        for (NSInteger i = 0 ; i < downImageArrM.count ; i++) {
            UIImage *downImage =[downImageArrM objectAtIndex: i];
            if (i == 0) {
                [downImage drawInRect:CGRectMake( 0 , HEIGHT - kPuzzleMixUpOffset(HEIGHT), WIDTH, HEIGHT)];
            }else {
                [downImage drawInRect:CGRectMake( (WIDTH - kPuzzleMixLeftOffset(WIDTH)) * i ,HEIGHT - kPuzzleMixUpOffset(HEIGHT), WIDTH , HEIGHT)];
            }
        }
        
    }
  
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    
    return resultImage;

}

+ (UIImage *)compressImage:(UIImage *)sourceimage newWidth:(CGFloat)newImageWidth
{
    if (!sourceimage) return nil;
    float imageWidth = sourceimage.size.width;
    float imageHeight = sourceimage.size.height;
    float width = newImageWidth;
    float height = sourceimage.size.height/(sourceimage.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [sourceimage drawInRect:CGRectMake(0, 0, imageWidth/heightScale , height)];
    }
    else {
        [sourceimage drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

+ (UIImage *)compressImage:(UIImage *)sourceimage newSize:(CGSize)newSize
{
    if (!sourceimage) return nil;
  
    CGSize size = sourceimage.size;

    CGFloat scalex = newSize.width / size.width;
    CGFloat scaley = newSize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);


    UIGraphicsBeginImageContext(newSize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    float dclipwidth = ((newSize.width - width) / 2.0f);
    float dclipheight = ((newSize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dclipwidth, dclipheight, size.width * scale, size.height * scale);
    [sourceimage drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

+ (UIImage*)imageByScalingAndClipForSize:(CGSize)targetSize sourceImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)getThumbnailWidthImage:(UIImage *)image size:(CGSize)size {
    
    CGSize originImageSize = image.size;
    
    CGRect newRect = CGRectMake(0, 0, size.width, size.height);
    
    //根据当前屏幕scaling factor创建一个透明的位图图形上下文(此处不能直接从UIGraphicsGetCurrentContext获取,原因是UIGraphicsGetCurrentContext获取的是上下文栈的顶,在drawRect:方法里栈顶才有数据,其他地方只能获取一个nil.详情看文档)
    UIGraphicsBeginImageContextWithOptions(newRect.size,NO,0.0);
    
    //保持宽高比例,确定缩放倍数
    
    //(原图的宽高做分母,导致大的结果比例更小,做MAX后,ratio*原图长宽得到的值最小是40,最大则比40大,这样的好处是可以让原图在画进40*40的缩略矩形画布时,origin可以取=(缩略矩形长宽减原图长宽*ratio)/2 ,这样可以得到一个可能包含负数的origin,结合缩放的原图长宽size之后,最终原图缩小后的缩略图中央刚好可以对准缩略矩形画布中央)
    
    float ratio =MAX(newRect.size.width/ originImageSize.width, newRect.size.height/ originImageSize.height);
    
    //让image在缩略图范围内居中()
    
    CGRect projectRect;
    
    projectRect.size.width= originImageSize.width* ratio;
    
    projectRect.size.height= originImageSize.height* ratio;
    
    projectRect.origin.x= (newRect.size.width- projectRect.size.width) /2;
    
    projectRect.origin.y= (newRect.size.height- projectRect.size.height) /2;
    
    //在上下文中画图
    
    [image drawInRect:projectRect];
    
    //从图形上下文获取到UIImage对象,赋值给thumbnai属性
    
    UIImage*smallImg =UIGraphicsGetImageFromCurrentImageContext();
    
    //清理图形上下文(用了UIGraphicsBeginImageContext需要清理)
    
    UIGraphicsEndImageContext();
    return smallImg;

}



/**
 压图片质量
 
 @param image image
 @return Data
 */
+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    return compressedData;
}

#pragma mark - 图片缩放



@end
