//
//  PhotoDataProvider.h
//  VoiceImage
//
//  Created by SPG on 7/3/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AssetsLibrary/AssetsLibrary.h>
#import "MWPhotoBrowser.h"

@protocol PhotoDataProtocol <NSObject>

@optional
-(void)selectedModelPresented;
-(void)selectedModelHidden;
-(void)viewSinglePhoto;
-(void)viewPhotos;

-(void)startUploadOldPhoto;

@end

@interface PhotoDataProvider : NSObject<MWPhotoBrowserDelegate>{
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
}

@property (weak, nonatomic) id <PhotoDataProtocol> delegate;
@property (nonatomic, strong) NSMutableArray* selected;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSArray *thumbs;
@property (nonatomic, strong) UIViewController* parentView;
@property (assign, nonatomic) BOOL isSelectedModel;

+ (instancetype)sharedInstance;
-(void)getAllPictures:(id)object withSelector:(SEL)selector;
-(void)getPicturesByName:(id)object withSelector:(SEL)selector names:(NSArray*)names;
-(void)getPictureByName:(id)object withSelector:(SEL)selector names:(NSString*)imageName;
-(instancetype)init;
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
@end
