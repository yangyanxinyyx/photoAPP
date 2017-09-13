//
//  DataBaseManager.h
//  takePhotoAPP
//
//  Created by yanxin_yang on 12/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "GoodsShelfModel.h"

@interface DataBaseManager : NSObject

+(DataBaseManager*)shareDataBase;

-(BOOL)creatTable;

- (BOOL)insertInToTableWithModel:(GoodsShelfModel *)model;
-(NSMutableArray *)selectTable;
-(BOOL)deleteInTableWithDbid:(NSString *)Dbid;
-(BOOL)updateInTableWithModel:(GoodsShelfModel *)model;
@end
