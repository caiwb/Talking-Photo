//
//  APPAppDelegate.m
//  CameraApp
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPAppDelegate.h"
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
#import "NewFeatureController.h"
#import <CoreLocation/CoreLocation.h>

@interface APPAppDelegate () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, YRSideViewDeleagate ,UIAlertViewDelegate ,StartDelegate , CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, assign) BOOL isNotLoop;//LaunchScreen 持续时间，默认为NO
@property (nonatomic, assign) BOOL isFirst;
@property (strong, nonatomic) UINavigationController * mainViewController;
@property (strong, nonatomic) CameraOverlayController * cameraViewController;

@end

@implementation APPAppDelegate


/**上传数据
 每张手机中的Image代表一条数据，
 Status :  
            0--未上传
            1--已上传
            2--正在上传
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
        _isFirst = YES;
        _isNotLoop = YES;
        
    } else {
        userId = [[DataHolder sharedInstance] userId];
        [[HttpHelper sharedHttpHelper]AFNetworingForLoginWithGUID:userId];
        _isFirst = NO;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    dispatch_async(dispatch_queue_create("init_data", NULL), ^{
        [self initUser];
        //加载数据库
        [DataBaseHelper initDB];
        //数据库锁
        myLock = [[NSObject alloc] init];
        //加载相册图片 dataRetrieved:中初始化browser
        [[PhotoDataProvider sharedInstance] getAllPictures:self withSelector:@selector(dataRetrieved:)];
    });
    
    while (_isNotLoop == NO) {
        //保持LaunchScreen直到照片加载完成
    }
    
    if (_isFirst == YES) {
        self.window = [[UIWindow alloc] init];
        self.window.frame = [UIScreen mainScreen].bounds;
        NewFeatureController * newFeature = [[NewFeatureController alloc] init];
        newFeature.delegate = self;
        self.window.rootViewController = newFeature;
        [self.window makeKeyAndVisible];
    }
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", IFLY_APP_ID];
    //获取定位
    [self getLocation];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    //异步上传
    dispatch_queue_t upload_queue = dispatch_queue_create("upload_queue", NULL);
    dispatch_async(upload_queue, ^{
        NSMutableArray * uploadingArray = nil;
        uploadingArray = [DataBaseHelper selectDataBy:@"status" IsEqualto:[NSString stringWithFormat:@"%d",2]];
        for(id obj in uploadingArray) {
            
            NSString * uploadingName = obj[@"name"];
            [DataBaseHelper updateData:@"status" ByValue:0 WhereImageName:uploadingName];
        }
        while (true)
        {
 
                [self uploadDataFromDB];
                sleep(0.1);
            
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
    _isNotLoop = YES;
    
    if (_isFirst == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self showBrowser];
        });
    }
}

-(void)showBrowser
{
    _picker.cameraOverlayView = _cameraViewController.view;
    _cameraViewController.view.backgroundColor = [UIColor clearColor];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _sideViewController;
    [self.window makeKeyAndVisible];

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未检测到摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myAlertView show];
    }
}

#pragma mark - StartApp delegate

-(void)startApp
{
    [self showBrowser];
}

#pragma mark - Alert View click delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.sideViewController hideSideViewController:YES];
    [self backtoSideViewControllerAndShowRightVc:NO];
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
        [tagView.imageView setImage:chosenImage];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_sideViewController hideSideViewController:YES];
            [_mainViewController pushViewController:tagView animated:NO];
        });
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_sideViewController hideSideViewController:YES];
}

- (YRSideViewController *)backtoSideViewControllerAndShowRightVc:(BOOL)isShow
{
    UIImagePickerController * newPicker = [[UIImagePickerController alloc] init];
    newPicker.delegate = self;
    newPicker.allowsEditing = NO;
    newPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    newPicker.cameraOverlayView = _cameraViewController.view;

    _sideViewController.needSwipeShowMenu = YES;
    [_mainViewController setNavigationBarHidden:NO];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _sideViewController.rightViewController = newPicker;
        _sideViewController.rightViewShowWidth = [[UIScreen mainScreen] bounds].size.width;
        _picker = newPicker;
        if (isShow == YES) {
            [_sideViewController showRightViewController:YES];
        }
    });
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

-(void)getLocation {
    if (!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _geocoder = [[CLGeocoder alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [_locationManager requestWhenInUseAuthorization];
        
        [_locationManager startUpdatingLocation];
    }
    
}

#pragma mark - CLLocation Manager delegate methods

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"User hates you");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            
            [_locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
    
    [_locationManager stopUpdatingLocation];
    
    // Reverse Geocoding
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            _placemark = [placemarks lastObject];
            name = _placemark.name;
            if (name == nil){
                name = @"";
            }
            street = _placemark.thoroughfare;
            city = _placemark.administrativeArea;
            country = _placemark.country;
            longitude = [NSString stringWithFormat:@"%3.5f",location.coordinate.longitude];
            latitude = [NSString stringWithFormat:@"%3.5f",location.coordinate.latitude];
            loc = [NSString stringWithFormat:@"%@,%@,%@,%@",longitude,latitude,city,street];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}


@end