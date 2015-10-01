//
//  DataBaseHelper.m
//  VoiceImage
//
//  Created by caiwb on 15/8/19.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "DataBaseHelper.h"
#import "Global.h"

@interface DataBaseHelper()

@end

@implementation DataBaseHelper

+(NSString *) getDBPath
{
    if ([dbPath isEqualToString:@""]) {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documents = [paths objectAtIndex:0];
        NSString * databasePath = [documents stringByAppendingPathComponent:DBNAME];
        dbPath = databasePath;
    }
    
    return dbPath;
}

/**
 * 打开数据库，不存在则创建
 */
+(BOOL)initDB
{
    NSString * databasePath = [DataBaseHelper getDBPath];
    const char * dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &upload_database) == SQLITE_OK)
    {
        char * errMsg;
        const char * sql = "CREATE TABLE IF NOT EXISTS UPLOADTABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT, image_name TEXT, image_path TEXT, desc TEXT, time TEXT, loc TEXT, token TEXT, tag TEX, status INTEGER)";
        if (sqlite3_exec(upload_database, sql, NULL, NULL, &errMsg) != SQLITE_OK) {
            sqlite3_close(upload_database);
            NSLog(@"初始化表失败%s",errMsg);
        }
        else{
            NSLog(@"初始化表成功");
            return YES;
        }
    }
    else{
        sqlite3_close(upload_database);
        NSLog(@"数据库初始化失败");
    }
    return NO;
}

+(BOOL) insertDataWithId:(NSString *)userID ImageName:(NSString *)imageName ImagePath:(NSString *)imagePath Desc:(NSString *)desc Time:(NSData *)time Loc:(NSString *)loc Token:(NSString *)token Tag:(NSString *)tag Status:(int)status
{
    @synchronized(dbLock) {
        @autoreleasepool {
        if (!loc) {
            loc = @"";
        }
        sqlite3_stmt *statement;
        NSString * databasePath = [self getDBPath];
        const char *dbpath = [databasePath UTF8String];
    
        if (sqlite3_open(dbpath, &upload_database)==SQLITE_OK) {

            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO UPLOADTABLE (user_id,image_name,image_path,desc,time,loc,token,tag,status) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\")",userID,imageName,imagePath,desc,time,loc,token,tag,status];
            const char *insertstaement = [insertSql UTF8String];

            sqlite3_prepare_v2(upload_database, insertstaement, -1, &statement, NULL);

            if (sqlite3_step(statement)==SQLITE_DONE) {
                NSLog(@"插入数据成功");
                sqlite3_finalize(statement);
                sqlite3_close(upload_database);
                return YES;
            }
            else {
                NSLog(@"插入数据失败---%d",sqlite3_step(statement));
            }
            sqlite3_finalize(statement);
            sqlite3_close(upload_database);
        }
        else
            NSLog(@"插入数据-数据库打开失败");
        return NO;
        }
    }
}

+(NSMutableArray *) selectDataBy:(NSString *)item IsEqualto:(NSString *)value
{
    @synchronized(dbLock) {

        NSMutableArray * resultArray = [[NSMutableArray alloc] init];
        sqlite3_stmt *statement;
        NSString * databasePath = [DataBaseHelper getDBPath];
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &upload_database)==SQLITE_OK) {
            NSString *querySQL = [NSString stringWithFormat:@"SELECT user_id,image_name,image_path,desc,time,loc,token,tag,status from UPLOADTABLE where %@=\"%@\"",item, value];
    //        NSString *querySQL = [NSString stringWithFormat:@"SELECT UPLOADTABLE where %@=\"%@\"",item, value];
            const char *querystatement = [querySQL UTF8String];
            if (sqlite3_prepare_v2(upload_database, querystatement, -1, &statement, NULL)==SQLITE_OK) {
                
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
                    NSLog(@"查询成功-%@:%@=%@",result[@"name"],item,value);
                    result[@"id"] = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    result[@"name"] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
    //                //imageData
    //                const void *op = sqlite3_column_blob(statement, 2);
    //                int size = sqlite3_column_bytes(statement,2);
    //                NSData *imageData = [[NSData alloc]initWithBytes:op length:size];
    //                result[@"data"] = [[NSData alloc] initWithData:imageData];
                    result[@"path"] = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                    result[@"desc"] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                    result[@"time"] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                    result[@"loc"] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                    result[@"token"] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                    result[@"tag"] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)];
                    result[@"status"] = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)];
                    [resultArray addObject:result];
                }
            }
            sqlite3_finalize(statement);
            sqlite3_close(upload_database);
        }
        else
            NSLog(@"查询数据-数据库打开失败");
        
        return resultArray;
    }
}


+(BOOL) updateData:(NSString *)item ByValue:(NSString *)value WhereImageName:(NSString *)imageName
{
    @synchronized(dbLock) {
        sqlite3_stmt *statement;
        NSString * databasePath = [DataBaseHelper getDBPath];
        const char *dbpath = [databasePath UTF8String];

        
        if (sqlite3_open(dbpath, &upload_database)==SQLITE_OK) {
            NSString *querySQL = [NSString stringWithFormat:@"update UPLOADTABLE set %@=\"%@\" where image_name=\"%@\"",item, value, imageName];
            const char *updatestatement = [querySQL UTF8String];
          
            if (sqlite3_prepare_v2(upload_database, updatestatement, -1, &statement, NULL)!=SQLITE_OK)
            {
                NSLog(@"更新表失败");
                sqlite3_finalize(statement);
                sqlite3_close(upload_database);
                return NO;
            }
            else
            {
                if (sqlite3_step(statement)==SQLITE_DONE) {
                    NSLog(@"更新数据成功---%@", value);
                    
                    sqlite3_finalize(statement);
                    sqlite3_close(upload_database);
                    return YES;
                }
                else {
                    NSLog(@"更新数据失败---%d",sqlite3_step(statement));
                }
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(upload_database);
        return NO;

    }
}

@end
