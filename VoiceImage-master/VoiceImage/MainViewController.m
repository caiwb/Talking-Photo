//
//  MainViewController.m
//  VoiceImage
//
//  Created by caiwb on 15/8/27.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "PhotoDataProvider.h"
#import "TagPhotoViewController.h"
#import "MyPhotoBrowser.h"


@interface MainViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) MyPhotoBrowser *browser;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PhotoDataProvider sharedInstance] getAllPictures:self withSelector:@selector(dataRetrieved:)];
    _browser = [[MyPhotoBrowser alloc] init];
    self.rootViewController = [[UINavigationController alloc] initWithRootViewController:_browser];
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    SettingViewController * setting = [[SettingViewController alloc] init];
    
    self.rightViewController = imagePicker;
    self.leftViewController = setting;
    
    self.rightViewShowWidth = [[UIScreen mainScreen] bounds].size.width;
    self.leftViewShowWidth = 250;
    self.needSwipeShowMenu = true;//默认开启的可滑动展示
    
    // Do any additional setup after loading the view.
}

- (void)dataRetrieved:(id)sender {
    // Create browser
    _browser = [[MyPhotoBrowser alloc] initWithDelegate:[PhotoDataProvider sharedInstance]];
    _browser.displayActionButton = NO;
    _browser.displayNavArrows = NO;
    _browser.displaySelectionButtons = NO;
    _browser.alwaysShowControls = YES;
    _browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    _browser.wantsFullScreenLayout = YES;
#endif
    _browser.enableGrid = YES;
    _browser.startOnGrid = YES;
    _browser.enableSwipeToDismiss = NO;
    
    [_browser setCurrentPhotoIndex:0];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有找到摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myAlertView show];
        
    }
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    TagPhotoViewController* tagView = [[TagPhotoViewController alloc] init];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    tagView.image = chosenImage;
    
    [picker presentViewController:tagView animated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
