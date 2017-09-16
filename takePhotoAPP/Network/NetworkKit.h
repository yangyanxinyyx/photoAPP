//
//  NetworkKit.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 14/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadModel.h"

#import "TempOSS.h"

typedef void (^NetworkSendBlock)(NSDictionary *object);
typedef void (^NetworkSendResponseBlock)(NSDictionary *urlObject, id responseObject, NSError *error);

@interface NetworkKit : NSObject

+ (void)sendImageWithObject:(UploadModel *)object
                    process:(NetworkSendBlock)process
                   response:(NetworkSendResponseBlock)response;

@end
