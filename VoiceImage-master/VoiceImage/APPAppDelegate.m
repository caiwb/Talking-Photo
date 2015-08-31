//
//  APPAppDelegate.m
//  CameraApp
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPAppDelegate.h"
#import "APPViewController.h"
#import "IFlyFlowerCollector.h"
#import "iflyMSC/IFlyMSC.h"
#import "global.h"
#import "DataBaseHelper.h"
#import "HttpHelper.h"
#import "SettingViewController.h"
#import "PhotoDataProvider.h"
#import "TagPhotoViewController.h"
#import "DataHolder.h"

@interface APPAppDelegate () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, YRSideViewDeleagate ,UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isLoop;

@property (strong, nonatomic) MyPhotoBrowser *browser;
@property (strong, nonatomic) UINavigationController *mainViewController;

@end

@implementation APPAppDelegate


/**上传数据
 每张手机中的Image代表一条数据，
 Status :  
            0--未上传
            1--已上传
 */
-(void)uploadDataFromDB
{
    NSMutableArray * dataArray = nil;
    dataArray = [DataBaseHelper selectDataBy:@"status" IsEqualto:[NSString stringWithFormat:@"%d",0]];
    if (dataArray) {
        for (id obj in dataArray) {
//            NSString * imageName = obj[@"name"];
            [[HttpHelper sharedHttpHelper]AFNetworingForUploadWithUserId:obj[@"id"] ImageName:obj[@"name"] ImagePath:obj[@"path"] Desc:obj[@"desc"] Tag:obj[@"tag"] Time:obj[@"time"] Loc:obj[@"loc"] Token:obj[@"token"]];
        }
    }
}

-(void)initUser
{
    [[DataHolder sharedInstance] loadData];
    if ([[DataHolder sharedInstance] userId] == nil) {
        [[HttpHelper sharedHttpHelper]AFNetworingForRegistry];
        
    } else {
        userId = [[DataHolder sharedInstance] userId];
        [[HttpHelper sharedHttpHelper]AFNetworingForLoginWithGUID:userId];
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initUser];
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.rootViewController = [[MyPhotoBrowser alloc] init];
//    [self.window makeKeyAndVisible];
    
    [[PhotoDataProvider sharedInstance] getAllPictures:self withSelector:@selector(dataRetrieved:)];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未检测到摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myAlertView show];
        
    }

    
    _isLoop = YES;
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", IFLY_APP_ID];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    //加载数据库
    [DataBaseHelper initDB];
    
    //异步上传
    dispatch_queue_t queue = dispatch_queue_create("upload_queue", NULL);
    dispatch_async(queue, ^{
        while (_isLoop == YES)
        {
            [self uploadDataFromDB];
            sleep(5);
        }
    });
    
    return YES;
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
    
    // Modal
    _mainViewController = [[UINavigationController alloc] initWithRootViewController:_browser];
    SettingViewController * leftViewController = [[SettingViewController alloc] init];
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.allowsEditing = NO;
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    _sideViewController = [[YRSideViewController alloc]initWithNibName:nil bundle:nil];
    _sideViewController.delegate = self;
    _sideViewController.rootViewController = _mainViewController;
    _sideViewController.rightViewController = _picker;
    _sideViewController.leftViewController = leftViewController;
    
    _sideViewController.rightViewShowWidth = [[UIScreen mainScreen] bounds].size.width;
    _sideViewController.leftViewShowWidth = 250;
    _sideViewController.needSwipeShowMenu = true;//默认开启的可滑动展示
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _sideViewController;
    [self.window makeKeyAndVisible];
}

#pragma mark - Alert View click delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if (chosenImage == nil) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请重新拍照" delegate:self cancelButtonTitle:nil otherButtonTitles: @"确定", nil];
        [myAlertView show];
    }
    else
    {
        _sideViewController.needSwipeShowMenu = NO;
        TagPhotoViewController* tagView = [[TagPhotoViewController alloc] init];
        tagView.image = chosenImage;
        [_sideViewController hideSideViewController:NO];
        [_mainViewController pushViewController:tagView animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_sideViewController hideSideViewController:YES];
}

- (YRSideViewController *)backtoSideViewControllerAndShowRightVc:(BOOL)isShow
{
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.allowsEditing = NO;
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _sideViewController.rightViewController = _picker;
    _sideViewController.rightViewShowWidth = [[UIScreen mainScreen] bounds].size.width;
    _sideViewController.needSwipeShowMenu = YES;
    [_mainViewController setNavigationBarHidden:NO];
    if (isShow == YES) {
        [_sideViewController showRightViewController:YES];
    }
    return _sideViewController;
}



@end