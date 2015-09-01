//
//  CameraOverlayController.h
//  VoiceImage
//
//  Created by caiwb on 15/9/1.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraOverlayController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *startImageUp;
@property (weak, nonatomic) IBOutlet UIImageView *startImageDown;

@property (strong, nonatomic) UIImagePickerController * picker;

@end
