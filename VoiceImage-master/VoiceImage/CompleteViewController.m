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
#import "APPViewController.h"

@interface CompleteViewController ()

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
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)browseGallery:(UIButton *)sender {
    APPViewController* app = [[APPViewController alloc] init];
    [self presentViewController:app animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    TagPhotoViewController* tagView = [[TagPhotoViewController alloc] init];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    tagView.image = chosenImage;
    
    [picker presentViewController:tagView animated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
