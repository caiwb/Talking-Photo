//
//  global.m
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

//NSString* host = @"10.172.88.75:8888";
//NSString* host = @"10.172.88.78:8888";
NSString* host = @"192.168.191.1:8888";
//NSString* host = @"vophoto-test.chinacloudapp.cn:8888";

NSString* userId = @"";
NSString* token = @"";
NSString* latitude = @"";
NSString* longitude = @"";
NSString* loc = @"";

NSString* searchTag = @"";

sqlite3* upload_database = nil;

NSObject * dbLock = nil;

NSMutableArray * assetArray = nil;
BOOL isFindAssetDone = NO;