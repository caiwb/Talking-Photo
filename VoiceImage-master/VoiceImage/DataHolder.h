//
//  DataHolder.h
//  VoiceImage
//
//  Created by SPG on 7/6/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataHolder : NSObject{
    UIImage* defaultImage;
}

+ (DataHolder *)sharedInstance;

@property (copy) NSString* userId;

-(void) saveData;
-(void) loadData;
-(UIImage*) getDefaultImage;

@end
