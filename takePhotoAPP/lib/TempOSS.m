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
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = @"inno-sss";
    put.objectKey = [NSString stringWithFormat:@"hgz/photo/%@/%@/%@.jpg",[self getTime:file],[[NSUserDefaults standardUserDefaults]valueForKey:TASKID],[self getRandom]];
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
                finishURL(put.objectKey);
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

- (NSString *)getTimeNow
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [NSString stringWithFormat:@"%@",date];
    return timeNow;
}

- (NSString *)getTime:(NSString *)file
{
    NSString *name = [[file lastPathComponent] substringToIndex:10];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[name integerValue]];
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"YYYY-MM-dd"];
    stampFormatter.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateStr = [stampFormatter stringFromDate:date];
    return dateStr;
}

- (NSString *)getRandom
{
    int x = arc4random() % 10000;
    NSString *string = [NSString stringWithFormat:@"%d",x];
    return string;
}

@end
