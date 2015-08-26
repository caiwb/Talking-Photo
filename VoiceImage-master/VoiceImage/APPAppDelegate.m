//
//  APPAppDelegate.m
//  CameraApp
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPAppDelegate.h"

#import "APPViewController.h"
#import "IFlyFlowerCollector.h"
#import "iflyMSC/IFlyMSC.h"
#import "global.h"
#import "DataBaseHelper.h"
#import "HttpHelper.h"

#define DBNAME @"upload_data.sqlite"

@interface APPAppDelegate ()

@property (nonatomic, assign) BOOL isLoop;

@end

@implementation APPAppDelegate


/**上传数据
 每张手机中的Image代表一条数据，
 Status :  
            0--未上传
            1--已上传
 */
-(void)uploadDataFromDB
{
//    NSLog(@"THread___%@",[NSThread currentThread]);
//    NSLog(@"----upload");
    NSMutableArray * dataArray = nil;
    dataArray = [DataBaseHelper selectDataBy:@"status" IsEqualto:[NSString stringWithFormat:@"%d",0]];
    if (dataArray) {
       
        for (id obj in dataArray) {
            NSString * imageName = obj[@"name"];
//            NSLog(@"%@",imageName);
//
//            [HttpHelper AFNetworingForUploadWithUserId:obj[@"id"] ImageName:obj[@"name"] ImageData:obj[@"data"] Desc:obj[@"desc"] Tag:obj[@"tag"] Time:obj[@"time"] Loc:obj[@"loc"] Token:obj[@"token"]];
            [[HttpHelper sharedHttpHelper]AFNetworingForUploadWithUserId:obj[@"id"] ImageName:obj[@"name"] ImagePath:obj[@"path"] Desc:obj[@"desc"] Tag:obj[@"tag"] Time:obj[@"time"] Loc:obj[@"loc"] Token:obj[@"token"]];
//
        }
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sleep(1);
    _isLoop = YES;
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", IFLY_APP_ID];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    //加载数据库
    [DataBaseHelper initDB];
    
    //异步上传
    dispatch_queue_t queue = dispatch_queue_create("upload_queue", NULL);
    dispatch_async(queue, ^{
        while (_isLoop == YES)
        {
            [self uploadDataFromDB];
            sleep(5);
        }
    });
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[APPViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    return YES;
}



@end