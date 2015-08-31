//
//  APPAppDelegate.h
//  CameraApp
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "YRSideViewController.h"
#import "MyPhotoBrowser.h"

@class APPViewController;

@interface APPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YRSideViewController *sideViewController;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) MyPhotoBrowser *browser;

- (YRSideViewController *)backtoSideViewControllerAndShowRightVc:(BOOL)isShow;


@end
