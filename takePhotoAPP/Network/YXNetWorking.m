//
//  YXNetWorking.m
//  Project_2
//
//  Created by yangyanxin on 16/4/11.
//  Copyright © 2016年 yangyanxin. All rights reserved.
//

#import "YXNetWorking.h"

@implementation YXNetWorking


+(void)requestWithType:(RequsetType)type urlString:(NSString*)urlString ParDic:(NSDictionary*)dic finish:(RequsetFinish)finish err:(RequestError)err
{
    YXNetWorking *manager = [[YXNetWorking alloc] init];
    
    [manager requestWithType:type urlString:urlString ParDic:dic finish:finish err:err];
}


-(void)requestWithType:(RequsetType)type urlString:(NSString*)urlString ParDic:(NSDictionary*)dic finish:(RequsetFinish)finish err:(RequestError)err
{

    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    if (type == POST)
    {

        [request setHTTPMethod:@"POST"];

        if (dic.count>0)
        {
            NSData *data = [self DicToData:dic];
            [request setHTTPBody:data];
        }
    }
    

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            finish(data);
        }
        else
        {
            err(error);
        }
    }];
    [task resume];
}

#pragma mark- 把参数字典转化为NSData的私有方法
-(NSData*)DicToData:(NSDictionary*)dic
{

    NSMutableArray *dicArray = [NSMutableArray array];

    for (NSString *key in dic) {
        NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@",key,[dic valueForKey:key]];
        [dicArray addObject:keyAndValue];
    }

    NSString *parStr = [dicArray componentsJoinedByString:@"&"];
    // a=b&c=d&e=f
    NSLog(@"parStr = %@",parStr);
    

    NSData *data = [parStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}





@end
