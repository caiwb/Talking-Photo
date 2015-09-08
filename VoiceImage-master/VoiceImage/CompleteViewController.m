//
//  CompleteViewController.m
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "CompleteViewController.h"
#import "TagPhotoViewController.h"
#import "PhotoDataProvider.h"
#import "MyPhotoBrowser.h"
#import "APPAppDelegate.h"

@interface CompleteViewController ()

@property (strong, nonatomic) YRSideViewController *sideViewController;

@end

@implementation CompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)takePhotoClicked:(UIButton *)sender {
    APPAppDelegate *delegate = (APPAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate backtoSideViewControllerAndShowRightVc:YES];
    [[PhotoDataProvider sharedInstance] getAllPictures:delegate.browser withSelector:@selector(imagesRetrieved:)];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)browseGallery:(UIButton *)sender {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    
//    APPAppDelegate *delegate = (APPAppDelegate*)[[UIApplication sharedApplication]delegate];
//    YRSideViewController *sideViewController = [delegate sideViewController];
//    [sideViewController hideSideViewController:YES];
    
    APPAppDelegate *delegate = (APPAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate backtoSideViewControllerAndShowRightVc:NO];
    [[PhotoDataProvider sharedInstance] getAllPictures:delegate.browser withSelector:@selector(imagesRetrieved:)];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    TagPhotoViewController* tagView = [[TagPhotoViewController alloc] init];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    tagView.image = chosenImage;
    
    [picker pushViewController:tagView animated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
//    [self.navigationController popToRootViewControllerAnimated:YES];
    APPAppDelegate *delegate = (APPAppDelegate*)[[UIApplication sharedApplication]delegate];
    YRSideViewController *sideViewController = [delegate sideViewController];
    [picker pushViewController:sideViewController animated:YES];
//    [sideViewController hideSideViewController:YES];
//    [picker dismissViewControllerAnimated:YES completion:NULL];
}


@end
