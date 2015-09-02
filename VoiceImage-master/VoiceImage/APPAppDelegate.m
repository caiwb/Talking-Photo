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
#import "CameraOverlayController.h"

@interface APPAppDelegate () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, YRSideViewDeleagate ,UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isLoop;
@property (strong, nonatomic) UINavigationController * mainViewController;
@property (strong, nonatomic) CameraOverlayController * cameraViewController;

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
            [[HttpHelper sharedHttpHelper] AFNetworingForUploadWithUserId:obj[@"id"] ImageName:obj[@"name"] ImagePath:obj[@"path"] Desc:obj[@"desc"] Tag:obj[@"tag"] Time:obj[@"time"] Loc:obj[@"loc"] Token:obj[@"token"]];
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
    dispatch_async(dispatch_queue_create("init_data", NULL), ^{
        [self initUser];
        //加载数据库
        [DataBaseHelper initDB];
        //加载相册图片 dataRetrieved:中初始化browser
        [[PhotoDataProvider sharedInstance] getAllPictures:self withSelector:@selector(dataRetrieved:)];
    });
    //保持LaunchScreen 等待照片数据加载完成
    sleep(2);

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未检测到摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myAlertView show];
        
    }
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", IFLY_APP_ID];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    //异步上传
    dispatch_queue_t upload_queue = dispatch_queue_create("upload_queue", NULL);
    dispatch_async(upload_queue, ^{
        while (true)
        {
            [self uploadDataFromDB];
            sleep(5);
        }
    });
    return YES;
}

- (void)dataRetrieved:(id)sender {
    NSLog(@"3--------------%@",[NSThread currentThread]);
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
    
    _mainViewController = [[UINavigationController alloc] initWithRootViewController:_browser];
    SettingViewController * leftViewController = [[SettingViewController alloc] init];
    
    //picker
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.allowsEditing = NO;
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  
    _cameraViewController = [[CameraOverlayController alloc] init];
    
    //side main view controller
    _sideViewController = [[YRSideViewController alloc]initWithNibName:nil bundle:nil];
    _sideViewController.delegate = self;
    _sideViewController.rootViewController = _mainViewController;
    _sideViewController.rightViewController = _picker;
    _sideViewController.leftViewController = leftViewController;
    
    _sideViewController.rightViewShowWidth = [[UIScreen mainScreen] bounds].size.width;
    _sideViewController.leftViewShowWidth = 260;
    _sideViewController.needSwipeShowMenu = true;//默认开启的可滑动展示
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        _picker.cameraOverlayView = _cameraViewController.view;
        _cameraViewController.view.backgroundColor = [UIColor clearColor];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = _sideViewController;
        [self.window makeKeyAndVisible];
    });
}

#pragma mark - Alert View click delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    [self backtoSideViewControllerAndShowRightVc:NO];
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
    _picker.cameraOverlayView = _cameraViewController.view;
    _sideViewController.rightViewController = _picker;
    _sideViewController.rightViewShowWidth = [[UIScreen mainScreen] bounds].size.width;
    _sideViewController.needSwipeShowMenu = YES;
    [_mainViewController setNavigationBarHidden:NO];
    if (isShow == YES) {
        [_sideViewController showRightViewController:YES];
    }
    return _sideViewController;
}

#pragma sideVc delegate methods

- (void)whenShowRightVc
{
    [self cameraOpenAnimation];
}

- (void)whenHideSideVc
{
 
}

- (void)cameraOpenAnimation
{
    _cameraViewController.view.hidden = NO;
    CGRect initRect = _cameraViewController.startImageUp.frame;
    
    initRect.origin.x = 0;
    initRect.origin.y = 0;
    
    _cameraViewController.startImageUp.frame = initRect;
    _cameraViewController.startImageDown.frame = initRect;
//    NSLog(@"up-----%f-----%f",_cameraViewController.startImageUp.frame.size.height,_cameraViewController.startImageDown.frame.size.width);
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{

            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.6];
            
            CGRect rectImageUp = _cameraViewController.startImageUp.frame;
            CGRect rectImageDown = _cameraViewController.startImageDown.frame;
            
            rectImageUp.origin.x -= 250;
            rectImageUp.origin.y -= 250;
            rectImageDown.origin.x += 320;
            rectImageDown.origin.y += 320;
            
            _cameraViewController.startImageUp.frame = rectImageUp;
            _cameraViewController.startImageDown.frame = rectImageDown;
            
            [UIView commitAnimations];
        });
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _cameraViewController.view.hidden = YES;
    });
}


@end