//
//  DataBaseManager.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 12/9/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "DataBaseManager.h"

static DataBaseManager *dataBase = nil;
@interface DataBaseManager ()
@property(nonatomic,strong)FMDatabase *db;
@end

@implementation DataBaseManager


+(DataBaseManager*)shareDataBase
{
    if (dataBase == nil) {
        dataBase = [[DataBaseManager alloc] init];
        
    }
    return dataBase;
}

-(id)init
{
    self = [super init];
    if (self) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"takePhoto.sqlite"];
        _db = [FMDatabase databaseWithPath:dbPath];
    }
    return self;
}

-(BOOL)creatTable
{
    if ([_db open]) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists goodsShelf (id  integer primary key autoincrement,state text,thumbLink text,photoCount text,failArray text,imagePaths text)"];
        BOOL result = [_db executeUpdate:sql];
        return result;
        
    }
    [_db close];
    return NO;
}

- (BOOL)insertInToTableWithModel:(GoodsShelfModel *)model
{
    model.goodUploadState = model.goodUploadState?model.goodUploadState:@"null";
    model.thumbLink = model.thumbLink?model.thumbLink:@"null";
    model.imageCount = model.imageCount?model.imageCount:@"null";
    model.failArrays = model.failArrays?model.failArrays:@"null";
    model.imagePaths = model.imagePaths?model.imagePaths:@"null";
    
    if ([_db open]) {
        NSString *sql = [NSString stringWithFormat:@"insert into goodsShelf (state,thumbLink,photoCount,failArray,imagePaths) values ('%@','%@','%@','%@','%@')",model.goodUploadState,model.thumbLink,model.imageCount,model.failArrays,model.imagePaths];
        BOOL result = [_db executeUpdate:sql];
        return result;
    }
    [_db close];
    return NO;
}

-(NSMutableArray *)selectTable
{
    NSMutableArray *array = [NSMutableArray array];
    if ([_db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from goodsShelf"];
        FMResultSet *set = [_db executeQuery:sql];
        while ([set next]) {
            NSString *state = [set stringForColumn:@"state"];
            NSString *thumbLink = [set stringForColumn:@"thumbLink"];
            NSString *photoCount = [set stringForColumn:@"photoCount"];
            NSString *failArray = [set stringForColumn:@"failArray"];
            NSString *imagePaths = [set stringForColumn:@"imagePaths"];
            int dbid = [set intForColumn:@"id"];
            GoodsShelfModel *model = [[GoodsShelfModel alloc] init];
            model.dbid = [NSString stringWithFormat:@"%d",dbid];
            model.goodUploadState = state;
            model.thumbLink = thumbLink;
            model.imageCount = photoCount;
            model.failArrays = failArray;
            model.imagePaths = imagePaths;
            [array addObject:model];
        }
        [_db close];
    }
    return array;
}

-(BOOL)deleteInTableWithDbid:(NSString *)Dbid
{
    if ([_db open]) {
        NSString *sql = [NSString stringWithFormat:@"delete from goodsShelf where id ='%d'",[Dbid intValue]];
        BOOL result = [_db executeUpdate:sql];
        return result;
    }
    [_db close];
    return NO;
}

-(BOOL)updateInTableWithModel:(GoodsShelfModel *)model
{
    model.goodUploadState = model.goodUploadState?model.goodUploadState:@"null";
    if ([_db open]) {
        NSString *sql = [NSString stringWithFormat:@"update movies set state = '%@' where id = '%d'",model.goodUploadState,[model.dbid intValue]];
        BOOL result = [_db executeUpdate:sql];
        [_db close];
        return result;
        
    }
    return NO;
}

@end
