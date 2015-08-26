//
//  HttpHelper.h
//  VoiceImage
//
//  Created by SPG on 7/6/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface HttpHelper : NSObject

+(instancetype) sharedHttpHelper;

//+(void)applyForAccount:(id)object withSelector:(SEL)selector;
//-(void)uploadPhoto:(id)object withSelector:(SEL)selector imageName:(NSArray*)nameList imageData:(NSData*)imgData voicePath:(NSString*)voicePath date:(NSDate*)date location:(NSString*)location;
-(void)search:(id)object withSelector:(SEL)selector voicePath:(NSString*)voicePath tags:(NSArray*)tags;

-(void) AFNetworingForRegistry;
-(void) AFNetworingForLoginWithGUID:(NSString *)guid;
-(void) AFNetworingForUploadWithUserId:(NSString *)guid ImageName:(NSString *)imageName ImagePath:(NSString *)imagePath Desc:(NSString *)desc Tag:(NSString *)tag Time:(NSString *)time Loc:(NSString *)loc Token:(NSString *)token;

//分词
-(void) AFNetworkingForVoiceTag:(NSString *)desc forInserting:(NSDictionary *)insert orSearching:(id) object;

//imagePath -> asset -> image
-(UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset;

@end
