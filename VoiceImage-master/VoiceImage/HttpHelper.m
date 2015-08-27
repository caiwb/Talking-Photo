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

@interface HttpHelper () <MAMapViewDelegate, AMapSearchDelegate>
{
    AMapSearchAPI * _search;
}
@end

static id _instance;

@implementation HttpHelper

//static NSString* host = @"vophoto.chinacloudapp.cn";
static NSString * host1 = @"10.172.88.75:8888";

+(instancetype) sharedHttpHelper
{
    if (_instance == nil) { //防止频繁加锁
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

//+(void)applyForAccount:(id)object withSelector:(SEL)selector {
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/register",host]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    NSString* guid = [HttpHelper GetUUID];
//    NSString* messageBody = [NSString stringWithFormat:@"{'Lang':'zh-CN', 'Name':'', 'Id':'%@'}}", guid];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPShouldHandleCookies:NO];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setHTTPBody:[messageBody dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                    queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
////                               [self doSomethingWithData:data];
////                               outstandingRequests--;
////                               if (outstandingRequests == 0) {
////                                   [self doSomethingElse];
////                               }
//                               
//                               [object performSelector:selector withObject:data];
//                           }];
//    
//    
//}

//-(void)uploadPhoto:(id)object withSelector:(SEL)selector imageName:(NSArray*)nameList imageData:(NSData*)imgData voicePath:(NSString*)voicePath date:(NSDate*)date location:(NSString*)location {
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/upload",host]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    
//    NSString *boundary = @"01212123234347564653452345326372377546546564";
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
//    
//    NSMutableData *body = [NSMutableData data];
//    
//    if (userId == nil) {
//        return;
//    }
//    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userid\"\r\n\r\n%@", userId] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    for (NSString* name in nameList) {
//        if (name != nil) {
//            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imgName\"\r\n\r\n%@", name] dataUsingEncoding:NSUTF8StringEncoding]];
//        }
//    }
//    
//    if (location != nil) {
//        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location\"\r\n\r\n%@", location] dataUsingEncoding:NSUTF8StringEncoding]];
//    }
//    if (date != nil) {
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"yyyy-MM-dd"];
//        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"date\"\r\n\r\n%@", [formatter stringFromDate:date]] dataUsingEncoding:NSUTF8StringEncoding]];
//    }
//    if (imgData != nil) {
//        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", [nameList objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:imgData];
//    }
//    if (voicePath != nil) {
//        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"voice\"; filename=\"%@\"\r\n", [NSString stringWithFormat:@"%@.wav",[[HttpHelper sharedHttpHelper] GetUUID]]] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        NSData *data = [[NSFileManager defaultManager] contentsAtPath:voicePath];
//        [body appendData:[NSData dataWithData:data]];
//    }
//    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [request setHTTPBody:body];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               //                               [self doSomethingWithData:data];
//                               //                               outstandingRequests--;
//                               //                               if (outstandingRequests == 0) {
//                               //                                   [self doSomethingElse];
//                               //                               }
//                               [object performSelector:selector withObject:data];
//                           }];
//}

//-(void)search:(id)object withSelector:(SEL)selector voicePath:(NSString*)voicePath tags:(NSArray*)tags{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/search",host]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    
//    NSString *boundary = @"01212123234347564653452345326372377546546564";
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
//    
//    NSMutableData *body = [NSMutableData data];
//    
//    if (userId == nil) {
//        return;
//    }
//    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userid\"\r\n\r\n%@", userId] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    if (tags != nil) {
//        for (NSString* tag in tags) {
//            if (tag != nil) {
//                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"tags\"\r\n\r\n%@", tag] dataUsingEncoding:NSUTF8StringEncoding]];
//            }
//        }
//    }
//    
//    if (voicePath != nil) {
//        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"search\"; filename=\"%@\"\r\n", @"search.wav"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        NSData *data = [[NSFileManager defaultManager] contentsAtPath:voicePath];
//        [body appendData:[NSData dataWithData:data]];
//    }
//    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [request setHTTPBody:body];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               [object performSelector:selector withObject:data];
//                           }];
//}

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
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString * guid = [self GetUUID];
    params[@"user_id"] = guid;
    params[@"user_name"] = guid;
    params[@"password"] = @"123";
    params[@"lang"] = @"zh-cn";
//    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
//
//    [mgr.requestSerializer setAuthorizationHeaderFieldWithUsername:@"XYZ" password:@"xyzzzz"];
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
            isOK = YES;
        }
        if (!isOK) {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot create user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [myAlertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"注册请求失败：%@",error);
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot create user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
    }];
}

-(void) AFNetworingForLoginWithGUID:(NSString *)guid
{
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"user_name"] = guid;
    params[@"password"] = @"123";
    
    [mgr POST:[NSString stringWithFormat:@"http://%@/login",host] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         BOOL isOK = NO;
         NSLog(@"登录请求成功：%@",responseObject);
         BOOL suc = responseObject[@"status"];
         if (suc) {
             token = responseObject[@"token"];
             isOK = YES;
         }
         if (!isOK) {
             UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [myAlertView show];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"登录请求失败：%@",error);
         UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
         [myAlertView show];
     }];

}

-(void) AFNetworingForUploadWithUserId:(NSString *)guid ImageName:(NSString *)imageName ImagePath:(NSString *)imagePath Desc:(NSString *)desc Tag:(NSString *)tag Time:(NSString *)time Loc:(NSString *)loc Token:(NSString *)token
{
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
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
             UIImage * image = [self fullResolutionImageFromALAsset:asset];
             NSData * imageData = UIImageJPEGRepresentation(image, 1);
             //http request
             [mgr POST:[NSString stringWithFormat:@"http://%@/upload",host] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 //参数name为服务器接收文件数据所用参数
                 [formData appendPartWithFileData:imageData name:@"image" fileName:imageName mimeType:@"image"];
             } success:^(AFHTTPRequestOperation * operation, id responseObject) {
                 NSLog(@"上传请求成功：%@",responseObject);
                 //请求成功后将数据库中该条数据status置为1
                 [DataBaseHelper updateData:@"status" ByValue:1 WhereImageName:imageName];
                 
             } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                 NSLog(@"上传请求失败：%@",error);
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
        [mgr POST:[NSString stringWithFormat:@"http://%@/upload",host] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"上传请求成功：%@",responseObject);
             //请求成功后将数据库中该条数据status置为1
             [DataBaseHelper updateData:@"status" ByValue:1 WhereImageName:imageName];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"上传请求失败：%@",error);
             
         }];

    }

}

-(void) AFNetworingForSearchWithUserId:(NSString *)guid Desc:(NSString *)desc Tag:(NSString *)tag Loc:(NSString *)loc Token:(NSString *)token RefreshObject:(id)object
{
    
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
//    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
//    mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
   
    params[@"user_id"] = guid;
    params[@"loc"] = loc;
    params[@"token"] = token;
    params[@"desc"] = desc;
    params[@"tag"] = tag;
    
    [mgr POST:[NSString stringWithFormat:@"http://%@/search",host] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"查询请求成功：%@",responseObject);
         NSArray * imageArray = responseObject[@"image"];
         
         [[PhotoDataProvider sharedInstance] getPicturesByName:object withSelector:@selector(imagesRetrieved:) names:imageArray];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"查询请求失败：%@",error);
         
     }];
}

-(void)imagesRetrieved:(id)object
{
    [object reloadData];
    [object reloadGridView];
}

//key: o1J4T4R0F1v3X7E5I7A0NcnWpelIaVDL2G7iwVgs
-(void) AFNetworkingForVoiceTag:(NSString *)desc forInserting:(NSDictionary *)insert orSearching:(id) object
{
    
    __block NSString * result;
    AFHTTPRequestOperationManager * mgr = [AFHTTPRequestOperationManager manager];
    mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
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
         NSLog(@"分次失败————%@",error);
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
