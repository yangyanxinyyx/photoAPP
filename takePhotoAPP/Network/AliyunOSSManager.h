//
//  AliyunOSSManager.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 14/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AliyunOSS.h"
#import "AliyunOSS.h"

@interface AliyunOSSManager : AliyunOSS

+ (AliyunOSSManager *)shareInstance;

//图片上传
- (void)putImageAsyncWithObject:(NSDictionary *)object
                           file:(NSString *)file
                        process:(void (^)(NSDictionary *))process
                      finishURL:(void (^)(NSString *))finishURL;

@end
