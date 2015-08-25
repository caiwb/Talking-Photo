//
//  global.m
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "global.h"

NSString* host = @"10.172.88.75:8888";

NSString* city = @"";
NSString* name = @"";
NSString* street = @"";
NSString* country = @"";
NSString* userId = nil;
NSString* token = @"";
NSString* latitude = @"";
NSString* longitude = @"";
NSString* loc = @"";

sqlite3* upload_database = nil;
//const char * dbpath;