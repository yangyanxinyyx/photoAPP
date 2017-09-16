//
//  GoodsShelfDataManager.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 13/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsShelfModel.h"

@interface GoodsShelfDataManager : NSObject

@property (nonatomic,strong) NSMutableArray<GoodsShelfModel *>*datas;

+ (GoodsShelfDataManager *)shareInstance;

- (void)sendImageWithParam:(NSDictionary *)param;

+ (NSString *)changeNSArrayToNSString:(NSArray *)array;
+ (NSArray *)changeNSStringToNSArray:(NSString *)string;
+ (NSString *)changeNSDictionaryToNSString:(NSMutableDictionary *)dictionary;
+ (NSMutableDictionary*)changeNSStringToNSDictionary:(NSString *)string;
@end
