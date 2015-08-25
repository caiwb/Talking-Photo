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

#define IFLY_APP_ID @"55bec317"

//host ip
extern NSString* host;

//upload data
extern NSString* city;
extern NSString* name;
extern NSString* country;
extern NSString* street;

//经纬度
extern NSString* longitude;
extern NSString* latitude;

//location
extern NSString* loc;

extern NSString* userId;
extern NSString* token;
//sqlite
extern sqlite3 * upload_database;

#define MWPHOTO_FOLD_PHOTO_NOTIFICATION @"MWPHOTO_FOLD_PHOTO_NOTIFICATION"

#endif
