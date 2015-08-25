//
//  APPViewController.h
//  CameraApp
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#include <AssetsLibrary/AssetsLibrary.h>
#import "MyPhotoBrowser.h"

@interface APPViewController : UIViewController <CLLocationManagerDelegate>

- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;

@end
