//
//  NetworkKit.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 14/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "NetworkKit.h"


@implementation NetworkKit


+ (void)sendImageWithObject:(UploadModel *)object
                    process:(NetworkSendBlock)process
                   response:(NetworkSendResponseBlock)response {

    if (![[self class] isFileExistWithFilePath:object.imagePath]) {
        if (response) {
            response(nil, nil, [NSError errorWithDomain:@"找不到图片路径" code:1002 userInfo:nil]);
        }
    }
    [[self class] uploadImageToAliyunWithFilePath:object.imagePath process:process successBlock:^(NSDictionary *imageUrls) {
        
        @try {
            if ([imageUrls valueForKey:@"error"] && [[imageUrls valueForKey:@"error"] isEqualToString:@"error"]) {
                response(nil, nil, [NSError errorWithDomain:@"上传图片失败" code:1001 userInfo:nil]);
            }
            
            if ([imageUrls[@"result"] boolValue] == 1) {
                if (response) {
                    response(nil, imageUrls[@"finishURL"], nil);
                }
            } else {
                response(nil, nil, [NSError errorWithDomain:@"上传图片失败" code:1002 userInfo:nil]);
            }
           
        } @catch (NSException *exception) {
            NSLog(@"sendImageWithObject: error! %@", exception.description);
        }
    }];
}

/**
 * 上传图片
 */
+ (void)uploadImageToAliyunWithFilePath:(NSString *)filePath process:(void (^)(NSDictionary *))process successBlock:(void (^)(NSDictionary *))successBlock{
    
//    [FCHNetworking requestAPI:@"/public/index.php?r=Common/AliyunOSSToken" withParams:params callback:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
//        NSDictionary *accreditInfos = result[@"data"][@"result"];
//        if (!accreditInfos) {
//            //失败
//            successBlock(@{@"error": @"error"});
//            return;
//            
//        }
//        NSString *originalURL = accreditInfos[@"file_url"];
//        NSString *thumbnailURL = accreditInfos[@"file_url_thumbnail"];
//        
//       
//    }];
   
    NSDictionary *accreditInfos = @{};
    [[TempOSS shareInstance] putImageAsyncWithObject:accreditInfos file:filePath process:process finishURL:^(NSString *finishURL) {
        if (finishURL) {
            successBlock(@{@"finishURL": finishURL, @"result": @(YES)});
        } else {
            successBlock(@{@"result": @(NO)});
        }
    }];
  
}

//文件是否存在
+ (BOOL)isFileExistWithFilePath:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}


@end
