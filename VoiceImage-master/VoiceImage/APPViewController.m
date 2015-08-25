//
//  APPViewController.m
//  CameraApp
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPViewController.h"
#import "TagPhotoViewController.h"
#import "global.h"
#import "ImageInfo.h"
#import "MyPhotoBrowser.h"
#import "PhotoDataProvider.h"
#import "DataHolder.h"
#import "HttpHelper.h"
#import "AFNetworking.h"

@interface APPViewController ()

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;


@end

@implementation APPViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
        
    }
    
    [[DataHolder sharedInstance] loadData];
    if ([[DataHolder sharedInstance] userId] == nil) {
        [HttpHelper AFNetworingForRegistry];
        
    } else {
        userId = [[DataHolder sharedInstance] userId];
        [HttpHelper AFNetworingForLoginWithGUID:userId];
    }
    
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

//-(void)applyResponse:(NSData*) data {
//    BOOL isOK = NO;
//    NSError *error2;
//    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
//    NSLog(@"%@", jsonDict);
//    
//    BOOL suc = [[jsonDict valueForKey:@"status"] boolValue];
//    if (suc) {
//        NSString* userid = (NSString*)[jsonDict valueForKey:@"userId"];
//        userId = userid;
//        [[DataHolder sharedInstance] setUserId: userId];
//        [[DataHolder sharedInstance] saveData];
//        isOK = YES;
//    }
//    
//    if (!isOK) {
//        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                              message:@"Cannot create user."
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"OK"
//                                                    otherButtonTitles: nil];
//        
//        [myAlertView show];
//    }
//    
//}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)selectPhoto:(UIButton *)sender {
    [[PhotoDataProvider sharedInstance] setParentView:self];
    [[PhotoDataProvider sharedInstance] getAllPictures:self withSelector:@selector(dataRetrieved:)];

}

- (void)dataRetrieved:(id)sender {
    // Create browser
    MyPhotoBrowser * browser = [[MyPhotoBrowser alloc] initWithDelegate:[PhotoDataProvider sharedInstance]];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = YES;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = YES;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = NO;
    
    [browser setCurrentPhotoIndex:0];
    
    // Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    TagPhotoViewController* tagView = [[TagPhotoViewController alloc] init];
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    tagView.image = chosenImage;
    
    [picker presentViewController:tagView animated:YES completion:NULL];
    
}

- (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
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
//    NSLog(@"Resolving the Address");
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            _placemark = [placemarks lastObject];
            //            NSLog(@"name: %@", placemark.name);
            //            NSLog(@"thoroughfare: %@", placemark.thoroughfare);
            //            NSLog(@"subThoroughfare: %@", placemark.subThoroughfare);
            //            NSLog(@"locality: %@", placemark.locality);
            //            NSLog(@"subLocality: %@", placemark.subLocality);
            //            NSLog(@"administrativeArea: %@", placemark.administrativeArea);
            //            NSLog(@"subAdministrativeArea: %@", placemark.subAdministrativeArea);
            //            NSLog(@"areasOfInterest: %@", placemark.areasOfInterest);
        
            name = _placemark.name;
            if (name == nil){
                name = @"";
            }
            street = _placemark.thoroughfare;
            city = _placemark.administrativeArea;
            country = _placemark.country;
            longitude = [NSString stringWithFormat:@"%3.5f",location.coordinate.longitude];
            latitude = [NSString stringWithFormat:@"%3.5f",location.coordinate.latitude];
            loc = [NSString stringWithFormat:@"%@,%@",longitude,latitude];
//            NSLog(@"%@, %@, %@, %@, %@",longitude, latitude, street, city, country);
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}


@end
