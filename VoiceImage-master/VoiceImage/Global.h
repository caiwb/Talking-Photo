//
//  global.h
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#ifndef VoiceImage_global_h
#define VoiceImage_global_h

#import <UIKit/UIKit.h>
#import <sqlite3.h>

//api key
#define AMAP_KEY @"3db808c8819de8a8c5582e8ebeaed5cc"
#define IFLY_APP_ID @"55bec317"
#define XFEI_KEY @"o1J4T4R0F1v3X7E5I7A0NcnWpelIaVDL2G7iwVgs"

//host ip
extern NSString * host;

//location
extern NSString * loc;
extern NSString * longitude;
extern NSString * latitude;

//user
extern NSString * userId;
extern NSString * token;

//sqlite
extern sqlite3 * upload_database;

//tag for search
extern NSString * searchTag;

extern NSObject * dbLock;
extern NSObject * uploadLock;

//image asset array
extern NSMutableArray * assetArray;
extern BOOL isFindAssetDone;

extern NSString * dbPath;

#define MWPHOTO_FOLD_PHOTO_NOTIFICATION @"MWPHOTO_FOLD_PHOTO_NOTIFICATION"

#endif
