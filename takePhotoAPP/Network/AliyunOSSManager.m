//
//  AliyunOSSManager.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 14/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "AliyunOSSManager.h"


@implementation AliyunOSSManager

//NSString * const AliyunOSSMangerEndPoint = @"https://oss-cn-shenzhen.aliyuncs.com";
//NSString * const AliyunOSSMangerMultipartUploadKey = @"multipartUploadObject";
//
//+ (AliyunOSSManager *)shareInstance
//{
//    static AliyunOSSManager *aliyunOSSManager;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        aliyunOSSManager = [[AliyunOSSManager alloc] init];
//    });
//    
//    return aliyunOSSManager;
//}
//
//
//- (instancetype)init {
//    if (self = [super init]) {
//        [OSSLog enableLog];
//        [self setUpClient];
//    }
//    return self;
//}
//
//- (void)setUpClient {
//    if (!_client) {
//        
//        OSSClientConfiguration * conf = [OSSClientConfiguration new];
//        conf.maxRetryCount = 2;
//        conf.timeoutIntervalForRequest = 30;
//        conf.timeoutIntervalForResource = 24 * 60 * 60;
//        
//        id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:@"AccessKeyId" secretKeyId:@"AccessKeySecret" securityToken:@"SecurityToken"];
//        _client = [[OSSClient alloc] initWithEndpoint:AliyunOSSMangerEndPoint
//                                   credentialProvider:credential
//                                  clientConfiguration:conf];
//    }
//}
//
//- (void)setClientCredentialProviderWithAccessKey:(NSString *)tAccessKey secretKey:(NSString *)tSecretKey token:(NSString *)tToken
//{
//    OSSFederationCredentialProvider *credential =  [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
//        
//        OSSFederationToken *token = [OSSFederationToken new];
//        token.tAccessKey = tAccessKey;
//        token.tSecretKey = tSecretKey;
//        token.tToken = tToken;
//        
//        return token;
//    }];
//    
//    _client.credentialProvider = credential;
//}

+ (AliyunOSSManager *)shareInstance
{
    static AliyunOSSManager *aliyunOSSManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aliyunOSSManager = [[AliyunOSSManager alloc] init];
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
    NSString *tAccessKey = [object objectForKey:@"access_key_id"];
    NSString *tSecretKey = [object objectForKey:@"access_key_secret"];
    NSString *tToken = [object objectForKey:@"security_token"];
    NSString *bucketName = [object objectForKey:@"bucket_name"];
    NSString *objectKey = [object objectForKey:@"file_name"];
    NSString *file_url = [object objectForKey:@"file_url"];
    
    //[self setClientCredentialProviderWithAccessKey:tAccessKey secretKey:tSecretKey token:tToken];
    
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

@end
