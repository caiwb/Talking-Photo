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

@interface PhotoDataProvider : NSObject<MWPhotoBrowserDelegate>{
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
    NSMutableArray* selected;
}
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSArray *thumbs;
@property (nonatomic, strong) UIViewController* parentView;

+ (instancetype)sharedInstance;
-(void)getAllPictures:(id)object withSelector:(SEL)selector;
-(void)getPicturesByName:(id)object withSelector:(SEL)selector names:(NSArray*)names;
-(instancetype)init;
@end
