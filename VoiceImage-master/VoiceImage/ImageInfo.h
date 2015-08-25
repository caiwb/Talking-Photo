//
//  ImageInfo.h
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#ifndef VoiceImage_ImageInfo_h
#define VoiceImage_ImageInfo_h

#import <UIKit/UIKit.h>

@interface ImageInfo : NSObject{
}

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) UIImage* image;
@property (nonatomic,strong) NSURL* fullImageUrl;

@end


#endif
