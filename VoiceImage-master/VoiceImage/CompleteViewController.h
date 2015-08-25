//
//  CompleteViewController.h
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompleteViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)takePhotoClicked:(UIButton *)sender;
- (IBAction)browseGallery:(UIButton *)sender;

@end
