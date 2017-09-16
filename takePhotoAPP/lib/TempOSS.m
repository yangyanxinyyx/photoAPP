//
//  TempOSS.m
//  OSS对象储存Demo
//
//  Created by 许惠占 on 2017/9/4.
//  Copyright © 2017年 刘高升. All rights reserved.
//
/**
 *                       .::::.
 *                     .::::::::.
 *                    :::::::::::  FUCK YOU
 *                 ..:::::::::::'
 *              '::::::::::::'
 *                .::::::::::
 *           '::::::::::::::..
 *                ..::::::::::::.
 *              ``::::::::::::::::
 *               ::::``:::::::::'        .:::.
 *              ::::'   ':::::'       .::::::::.
 *            .::::'      ::::     .:::::::'::::.
 *           .:::'       :::::  .:::::::::' ':::::.
 *          .::'        :::::.:::::::::'      ':::::.
 *         .::'         ::::::::::::::'         ``::::.
 *     ...:::           ::::::::::::'              ``::.
 *    ```` ':.          ':::::::::'                  ::::..
 *                       '.:::::'                    ':'````..
 *
 */

#import "TempOSS.h"
@implementation TempOSS

// 异步上传
- (void)uploadObjectAsyncWithImageData:(NSData *)data {
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    // required fields
    put.bucketName = @"inno-sss";
    //文件路径/图片名称
    put.objectKey = [NSString stringWithFormat:@"hgz/photo/%@/%@.jpg",@"2017-09-20",@"2"];
    put.uploadingData = data;
    // optional fields
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        
    };
    //选填字段
    //    put.contentType = @"";
    //    put.contentMd5 = @"";
    //    put.contentEncoding = @"";
    //    put.contentDisposition = @"";
    
    OSSTask * putTask = [self.client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        
        task = [self.client presignPublicURLWithBucketName:put.bucketName withObjectKey:put.objectKey];
        NSLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            NSLog(@"upload object success!========");
        } else {
            NSLog(@"upload object failed, error: =======%@" , task.error);
        }
        return nil;
    }];
}

@end
