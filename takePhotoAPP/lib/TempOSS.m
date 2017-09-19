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

+ (TempOSS *)shareInstance
{
    static TempOSS *aliyunOSSManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aliyunOSSManager = [[TempOSS alloc] init];
    });
    
    return aliyunOSSManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [OSSLog enableLog];
        [self setupEnvironment];
    }
    return self;
}

- (void)putImageAsyncWithObject:(NSDictionary *)object
                           file:(NSString *)file
                        process:(void (^)(NSDictionary *))process
                      finishURL:(void (^)(NSString *))finishURL
{
    NSString *bucketName = [object objectForKey:@"bucket_name"];
    NSString *objectKey = [object objectForKey:@"file_name"];
    NSString *file_url = [object objectForKey:@"file_url"];
    
    NSLog(@"bucketName=%@", bucketName);
    NSLog(@"file=%@", file);
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = bucketName;
    put.objectKey = objectKey;
    put.uploadingFileURL = [NSURL URLWithString:file];
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        if (process) {
            NSDictionary *obj = @{
                                  @"bytesSent": @(bytesSent),
                                  @"totalByteSent": @(totalByteSent),
                                  @"totalBytesExpectedToSend": @(totalBytesExpectedToSend)
                                  };
            process(obj);
        }
    };
    
    OSSTask * putTask = [self.client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        
        if (!task.error) {
            if (finishURL) {
                finishURL(file_url);
            }
        }
        else {
            NSLog(@"upload image failed, error: %@" , task.error);
            if (finishURL) {
                finishURL(nil);
            }
        }
        
        
        
        return nil;
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:@"cancelUploadImage" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
        if (!putTask.completed) {
            [put cancel];
        }
    }];
}

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