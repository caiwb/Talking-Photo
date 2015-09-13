//
//  DataBaseHelper.h
//  VoiceImage
//
//  Created by caiwb on 15/8/19.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "global.h"

#define DBNAME @"upload_database.sqlite"

@interface DataBaseHelper : NSObject

//+ (DataBaseHelper *)sharedInstance;

+(BOOL) initDB;

+(BOOL) insertDataWithId:(NSString *)userID ImageName:(NSString *)imageName ImagePath:(NSString *)imagePath Desc:(NSString *)desc Time:(NSDate *)time Loc:(NSString *)loc Token:(NSString *)token Tag:(NSString *)tag Status:(int)status;

+(NSMutableArray *) selectDataBy:(NSString *)item IsEqualto:(NSString *)value;

+(BOOL) updateData:(NSString *)item ByValue:(NSString *)value WhereImageName:(NSString *)imageName;

@end
