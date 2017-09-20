//
//  GoodsShelfDataManager.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 13/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GoodsShelfDataManager.h"
#import "DataBaseManager.h"
#import "UploadModel.h"
#import "GoodsShelfModel.h"
#import "NetworkKit.h"



@implementation GoodsShelfDataManager

+ (GoodsShelfDataManager *)shareInstance {
    static GoodsShelfDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GoodsShelfDataManager alloc] init];
    });
    
    return manager;
}

- (NSArray< GoodsShelfModel*> *)datas {
    if (_datas) {
        return _datas;
    }
    
    _datas = [[DataBaseManager shareDataBase] selectTable];
   
    return _datas;
}

- (void)sendImageWithParam:(NSDictionary *)param {
    
    NSString *thumbLink = param[@"thumbLink"];
    NSArray *imagePaths = param[@"imagePaths"];
    
    
    //添加数据库
    GoodsShelfModel *goodModel = [[GoodsShelfModel alloc] init];
    goodModel.goodUploadState = GoodsUploadStateUploading;
    goodModel.imageCount = [NSString stringWithFormat:@"%ld",imagePaths.count];
    goodModel.imagePaths = [GoodsShelfDataManager changeNSArrayToNSString:imagePaths];
    goodModel.failArrays = @"";
    goodModel.thumbLink = thumbLink;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    goodModel.addTime = [NSString stringWithFormat:@"%@", @(time)];
    [self addModel:goodModel];
    
    //上传
    NSMutableArray *failArray = [NSMutableArray array];
    for (NSInteger i=0; i<imagePaths.count; i++) {
        UploadModel *uploadModel = [[UploadModel alloc] init];
        uploadModel.imagePath = imagePaths[i];
        
         [NetworkKit sendImageWithObject:uploadModel process:^(NSDictionary *object) {
             
         } response:^(NSDictionary *urlObject, id responseObject, NSError *error) {
             if (error || responseObject == nil ) {
                 [failArray addObject:@(i)];
             }
             if (i == imagePaths.count - 1) {
                 if (failArray.count == 0) {
                     //全部成功
                     goodModel.goodUploadState = GoodsUploadStateSuccess;
                     [self updateModel:goodModel];
                     
                     //删除临时文件
                     
                 } else {
                     //有失败的
                     goodModel.goodUploadState = GoodsUploadStateFail;
                     goodModel.failArrays = [GoodsShelfDataManager changeNSArrayToNSString:failArray];
                     [self updateModel:goodModel];
                 }
             }
         }];
        
    }
    
    
    
}

- (void)reSendImagewithModel:(GoodsShelfModel *)model
{
    NSArray *failArrays = [GoodsShelfDataManager changeNSStringToNSArray:model.failArrays];
    NSArray *imagePaths = [GoodsShelfDataManager changeNSStringToNSArray:model.imagePaths];
    NSMutableArray *resendArray = [NSMutableArray array];
    for (int j=0 ; j< failArrays.count; j++) {
        NSInteger index = [failArrays[j] integerValue];
        [resendArray addObject:imagePaths[index]
         ];
    }
    
    model.goodUploadState = GoodsUploadStateUploading;
    [self updateModel:model];
    
    NSMutableArray *failArray = [NSMutableArray array];
    for (NSInteger i=0; i<resendArray.count; i++) {
        UploadModel *uploadModel = [[UploadModel alloc] init];
        uploadModel.imagePath = resendArray[i];
        
        [NetworkKit sendImageWithObject:uploadModel process:^(NSDictionary *object) {
            
        } response:^(NSDictionary *urlObject, id responseObject, NSError *error) {
            if (error ) {
                [failArray addObject:@(i)];
            }
            if (i == resendArray.count - 1) {
                if (failArray.count == 0) {
                    //全部成功
                    model.goodUploadState = GoodsUploadStateSuccess;
                    [self updateModel:model];
                    
                    //删除临时文件
                    
                } else {
                    //有失败的
                    model.goodUploadState = GoodsUploadStateFail;
                    model.failArrays = [GoodsShelfDataManager changeNSArrayToNSString:failArray];
                    model.imagePaths = [GoodsShelfDataManager changeNSArrayToNSString:imagePaths];
                    [self updateModel:model];
                }
            }
        }];
        
    }
    
    
}

- (void)addModel:(GoodsShelfModel*)model {
    BOOL flag = [[DataBaseManager shareDataBase] insertInToTableWithModel:model];
    if (flag) {
        [self.datas addObject:model];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddModelNotify object:@{@"model": model, @"index": @(0)}];
    }
    
}


- (void)updateModel:(GoodsShelfModel*)model {
    BOOL flag = [[DataBaseManager shareDataBase] updateInTableWithModel:model];
    if (flag) {
        NSInteger index = [self indexOfModel:model];
        if (index < self.datas.count && index > 0) {
            [self.datas replaceObjectAtIndex:index withObject:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateModelNotify object:@{@"model": model, @"index": @(index)}];
        }
        NSAssert(index >= 0, @"找不到对用的model");
    }
}

/**
 * 模块索引
 */
- (NSInteger)indexOfModel:(GoodsShelfModel *)model {
    for (NSInteger i = 0; i < self.datas.count; i++) {
        GoodsShelfModel *tmpModel = self.datas[i];
        if ([tmpModel.addTime isEqualToString:model.addTime]) {
            return i;
        }
    }
    
    return -1;
}

+ (NSString *)changeNSArrayToNSString:(NSArray *) array
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return string;
}


+ (NSArray*)changeNSStringToNSArray:(NSString *)string
{
    NSData *data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *array = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    return array;
}



+ (NSString *)changeNSDictionaryToNSString:(NSMutableDictionary *)dictionary
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return string;
}

+ (NSMutableDictionary*)changeNSStringToNSDictionary:(NSString *)string
{
    NSData *data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    return dic;
}

@end
