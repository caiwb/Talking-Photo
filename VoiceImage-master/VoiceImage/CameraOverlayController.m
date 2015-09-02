//
//  CameraOverlayController.m
//  VoiceImage
//
//  Created by caiwb on 15/9/1.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "CameraOverlayController.h"

@interface CameraOverlayController ()


@end

@implementation CameraOverlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect initRect = CGRectMake(0, 0, 375, 667);
    _startImageDown.frame = initRect;
    _startImageUp.frame = initRect;
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
