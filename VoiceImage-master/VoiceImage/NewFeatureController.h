//
//  NewFeatureController.h
//  VoiceImage
//
//  Created by caiwb on 15/9/6.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartDelegate <NSObject>

-(void)startApp;

@end

@interface NewFeatureController : UIViewController

@property (nonatomic, weak) id<StartDelegate> delegate;

@end
