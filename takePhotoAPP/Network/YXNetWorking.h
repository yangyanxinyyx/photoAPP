//
//  YXNetWorking.h
//  Project_2
//
//  Created by yangyanxin on 16/4/11.
//  Copyright © 2016年 yangyanxin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,RequsetType)
{
    GET,
    POST
};


typedef void(^RequsetFinish) (NSData *data);

typedef void(^RequestError) (NSError *error);

@interface YXNetWorking : NSObject

+(void)requestWithType:(RequsetType)type urlString:(NSString*)urlString ParDic:(NSDictionary*)dic finish:(RequsetFinish)finish err:(RequestError)err;
@end
