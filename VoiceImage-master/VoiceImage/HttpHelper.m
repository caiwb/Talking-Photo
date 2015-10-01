//
//  HttpHelper.m
//  VoiceImage
//
//  Created by SPG on 7/6/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "HttpHelper.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#include <AssetsLibrary/AssetsLibrary.h>
#import "global.h"
#include "AFNetworking.h"
#include "DataHolder.h"
#include "DataBaseHelper.h"
#import "MyPhotoBrowser.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "PhotoDataProvider.h"
#import "SVProgressHUD.h"

@interface HttpHelper () <MAMapViewDelegate, AMapSearchDelegate>
{
    AMapSearchAPI * _search;
}

@property (nonatomic, strong) AFHTTPRequestOperationManager * uploadMgr;
@property (nonatomic, assign) BOOL isUploading;
@end

static id _instance;

@implementation HttpHelper

-(AFHTTPRequestOperationManager *)uploadMgr
{
    if (_uploadMgr == nil) {
        _uploadMgr = [[AFHTTPRequestOperationManager alloc] init];
        _uploadMgr.operationQueue = [[NSOperationQueue alloc] init];
        [_uploadMgr.operationQueue setMaxConcurrentOperationCount:1];
        _isUploading = NO;
    }
    return _uploadMgr;
}

+(instancetype) sharedHttpHelper
{
    if (_instance == nil) {
        @synchronized(self) {
            if (_instance == nil) {
                _instance = [[self alloc] init];
            }
        }
    }
    return _instance;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    if (_instance == nil) {
        @synchronized(self) {
            if (_instance == nil) {
                _instance = [super allocWithZone:zone];
            }
        }
    }
    return _instance;
}


- (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void)AFNetworingForRegistry
{
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    NSString * guid = [self GetUUID];
//    NSString * guid = @"f9006832-426d-4a0a-aab5-02e6ab9daf76";
    params[@"user_id"] = guid;
    params[@"user_name"] = guid;
    params[@"password"] = @"123";
    params[@"lang"] = @"zh-cn";
//    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [mgr POST:[NSString stringWithFormat:@"http://%@/register",host] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        
        BOOL isOK = NO;
        NSLog(@"注册请求成功：%@",responseObject);
        BOOL suc = responseObject[@"status"];
        if (suc) {
            NSDictionary* userid = responseObject[@"user"];
            userId = userid[@"user_id"];
            NSLog(@"");
            [[DataHolder sharedInstance] setUserId: userId];
            [[DataHolder sharedInstance] saveData];
            token = responseObject[@"token"];
            if (!token) {
                token = @"";
            }
            [self.delegate startUploadOldPhoto];
            isOK = YES;
        }
        if (!isOK) {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [myAlertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"注册请求失败：%@",error);
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myAlertView show];
    }];
}

-(void) AFNetworingForLoginWithGUID:(NSString *)guid
{
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[@"user_name"] = guid;
    params[@"password"] = @"123";
    
    [mgr POST:[NSString stringWithFormat:@"http://%@/login",host] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         BOOL isOK = NO;
         NSLog(@"登录请求成功：%@",responseObject);
         BOOL suc = responseObject[@"status"];
         if (suc) {
             token = responseObject[@"token"];
             if (!token) {
                 token = @"";
             }
             [self.delegate startUploadOldPhoto];
             isOK = YES;
         }
         if (!isOK) {
             UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
             [myAlertView show];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"登录请求失败：%@",error);
         UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
         [myAlertView show];
     }];

}

-(void) AFNetworingForUploadWithUserId:(NSString *)guid ImageName:(NSString *)imageName ImagePath:(NSString *)imagePath Desc:(NSString *)desc Tag:(NSString *)tag Time:(NSString *)time Loc:(NSString *)loc Token:(NSString *)mToken
{
    if(_isUploading == YES)
        return;
    _isUploading = YES;
    [DataBaseHelper updateData:@"status" ByValue:@"2" WhereImageName:imageName];
//        AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    self.uploadMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.uploadMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
    
    params[@"user_id"] = guid;
    params[@"token"] = token;
    params[@"desc"] = desc;
    params[@"tag"] = tag;
    params[@"image_name"] = imageName;
    if ([imagePath isEqualToString:@""] == NO) { //upload
        
        params[@"func"] = @"UPLOAD";
        params[@"loc"] = loc;
        params[@"time"] = time;

        //url -> img ->data
        [lib assetForURL:[NSURL URLWithString:imagePath] resultBlock:^(ALAsset *asset)
         {
             // 使用asset来获取本地图片
             //http request
             [self.uploadMgr POST:[NSString stringWithFormat:@"http://%@/upload",host] parameters:params constructingBodyWithBlock:^(__weak id<AFMultipartFormData> formData) {
                 //参数name为服务器接收文件数据所用参数
//                 UIImage * image = [self fullResolutionImageFromALAsset:asset];
//                 NSData * imageData = UIImageJPEGRepresentation(image, 0);
                [formData appendPartWithFileData:UIImageJPEGRepresentation([self fullResolutionImageFromALAsset:asset], 0) name:@"image" fileName:imageName mimeType:@"image"];
                 
             } success:^(AFHTTPRequestOperation * operation, id responseObject) {
                 //请求成功后将数据库中该条数据status置为1
                 @autoreleasepool {
                     NSLog(@"上传请求成功：%@",responseObject);
                     _isUploading = NO;
                     [DataBaseHelper updateData:@"status" ByValue:@"1" WhereImageName:imageName];
                 }
             } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                 @autoreleasepool {
                     _isUploading = NO;
                     NSLog(@"上传请求失败：%@",error);
                 }
             }];
         }
            failureBlock:^(NSError *error)
         {
             NSLog(@"%@",error);
         }];
    }
    else { //update re-tag
        params[@"func"] = @"UPDATE";
        params[@"loc"] = @"";
        params[@"time"] = @"";
        [self.uploadMgr POST:[NSString stringWithFormat:@"http://%@/upload",host] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"更新请求成功：%@",responseObject);
             //请求成功后将数据库中该条数据status置为1
             [DataBaseHelper updateData:@"status" ByValue:@"1" WhereImageName:imageName];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"更新请求失败：%@",error);
             
         }];
    }
}

-(void) AFNetworingForSearchWithUserId:(NSString *)guid Desc:(NSString *)desc Tag:(NSString *)tag Loc:(NSString *)loc Token:(NSString *)token RefreshObject:(id)object
{
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
//    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
//    mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
   
    params[@"user_id"] = guid;
    params[@"loc"] = loc;
    params[@"token"] = token;
    params[@"desc"] = desc;
    params[@"tag"] = tag;
    
    [mgr POST:[NSString stringWithFormat:@"http://%@/search",host] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"查询请求成功：%@",responseObject);
         NSArray * imageArray = responseObject[@"image"];
         //服务器返回的null为NSNULL类型，不能直接判断是否为空
         if (self.delegate) {
             if ([imageArray count] == 0) {
                 [self.delegate isSearchDone:NO];
             }
             else
                 [self.delegate isSearchDone:YES];
         }
         if([imageArray isEqual:[NSNull null]] == NO) {
            
            [[PhotoDataProvider sharedInstance] getPicturesByName:object withSelector:@selector(imagesRetrieved:) names:imageArray];
             
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (self.delegate) {
             [self.delegate isSearchDone:NO];
         }
         NSLog(@"查询请求失败：%@",error);
     }];
}

-(void) AFNetworingForFaceDetectWithImage:(UIImage *)image imageName:(NSString *)imageName
{
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[@"user_id"] = userId;
    params[@"token"] = token;
    //http request
    [mgr POST:[NSString stringWithFormat:@"http://%@/face",host] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //参数name为服务器接收文件数据所用参数
        NSData * imageData = UIImageJPEGRepresentation(image, 0);
        [formData appendPartWithFileData:imageData name:@"image" fileName:imageName mimeType:@"image"];
        imageData = nil;
    }
      success:^(AFHTTPRequestOperation * operation, id responseObject) {
        NSLog(@"查脸请求成功");
        BOOL status = responseObject[@"status"];
        if (status == YES) {
            [self.delegate isFaceDetectDone:YES faceList:responseObject[@"face"]];
        }
        else {
            [self.delegate isFaceDetectDone:NO faceList:nil];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        
        NSLog(@"查脸请求失败：%@",error);
        [self.delegate isFaceDetectDone:NO faceList:nil];
    }];

}


//key: o1J4T4R0F1v3X7E5I7A0NcnWpelIaVDL2G7iwVgs
-(void) AFNetworkingForVoiceTag:(NSString *)desc forInserting:(NSDictionary *)insert orSearching:(id) object
{
    //避免分词报错
    if ([desc isEqualToString:@""] || desc == nil) {
        desc = @"。";
        
    }
    __block NSString * result;
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[@"api_key"] = @"o1J4T4R0F1v3X7E5I7A0NcnWpelIaVDL2G7iwVgs";
    params[@"text"] = desc;
    params[@"pattern"] = @"pos";
    params[@"format"] = @"plain";
    
    NSString * urlString = [NSString stringWithFormat:@"http://ltpapi.voicecloud.cn/analysis/?api_key=%@&text=%@&pattern=pos&format=plain",XFEI_KEY,desc];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [mgr GET:urlString parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"分词成功————%@",result);
         //分词用于upload
         if (object == nil && insert != nil)
         {
             NSLog(@"%@",loc);
             
             [DataBaseHelper insertDataWithId:userId ImageName:insert[@"imageName"] ImagePath:insert[@"imagePath"] Desc:insert[@"desc"] Time:[NSDate date] Loc:loc Token:token Tag:result Status:0];
         }
         //分词用于search
         else if(object != nil && insert == nil)
         {
             if ([desc isEqualToString:@"。"]) {
                 return ;
             }
             //分词结果中取出地点名词
             searchTag = result;
             NSString * address = [self divideForLocationByDesc:desc Tag:result];
             NSLog(@"查找地址:%@",address);
             //将地点名词转换为经纬度坐标
             if ([address isEqualToString:@""] == NO) {
                 _search = [[AMapSearchAPI alloc] initWithSearchKey:AMAP_KEY Delegate:object];
                 //构造 AMapGeocodeSearchRequest 对象,address 为必选项,city 为可选项
                 AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
                 geoRequest.searchType = AMapSearchType_Geocode;
                 geoRequest.address = address;
                 //    city可选
                 //    geoRequest.city = @[@"beijing"];
                 //    请求的回调在MyPhotoBrowser中
                 [_search AMapGeocodeSearch: geoRequest];
                 
             }
             else
             {
                 
             }
             //将经纬度坐标作为参数向服务器发送Search请求
             //---在高德经纬度转换回调方法中实现
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         result = desc;
         NSLog(@"分词失败————%@",error);
     }];
    
}




//asset to img
- (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset
{
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    CGImageRef imgRef = [assetRep fullResolutionImage];
    UIImage *img = [UIImage imageWithCGImage:imgRef
                                       scale:assetRep.scale
                                 orientation:(UIImageOrientation)assetRep.orientation];
    return img;
}

-(NSString *)divideForLocationByDesc:(NSString *)desc Tag:(NSString *)tag
{
    //example:
    //tag = @"我_r 想_v 找_v 去年_nt 夏天_nt 在_p 南昌_ns 八一_nt 广场_ns 拍_v 的_u 照片_n"
    //desc = 我想找去年夏天在南昌八一广场拍的照片
    tag = [NSString stringWithFormat:@" %@",tag];
    NSString * address = desc;
    NSRange range = [tag rangeOfString:@"_ns"];
    if (range.length > 0)
    {
        int ns = (int)range.location;
        int i;
        for (i=ns-1; i>0; i--) {
            char c = [tag characterAtIndex:i];
            if (c == ' ') {
                break;
            }
        }
        range = NSMakeRange(i+1, ns-i-1);
        //range = (27,3)
        //ns_String = 南昌
        NSString * ns_String = [tag substringWithRange:range];
        range = [desc rangeOfString:ns_String];
        if (range.length > 0)
        {
            ns = (int)range.location;
            address = [desc substringFromIndex:ns];
        }
        //南昌八一广场拍的照片
    }
    return address;
}

@end
