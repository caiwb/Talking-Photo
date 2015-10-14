//
//  MerchantViewController.m
//  VoiceImage
//
//  Created by caiwb on 15/10/13.
//  Copyright © 2015年 SPG. All rights reserved.
//

#import "MerchantViewController.h"
#import "IAPHelper.h"
#import "IAPShare.h"
#import <StoreKit/StoreKit.h>

@interface MerchantViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnMerchant1;
@property (weak, nonatomic) IBOutlet UIButton *btnMerchant2;

@end

/*  com.voiceimage.test
 */

@implementation MerchantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:self completion:nil];
}

- (IBAction)merchant1:(id)sender {
    if(![IAPShare sharedHelper].iap) {
        
        NSSet* dataSet = [[NSSet alloc] initWithObjects:@"com.voiceimage.test", nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
        [IAPShare sharedHelper].iap.production = NO;
        [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
         {
             //response
             NSArray *myProduct = response.products;
             NSLog(@"Product ID:%@\n",response.invalidProductIdentifiers);
             NSLog(@"Product count: %ld\n", [myProduct count]);
             // populate UI
             for(SKProduct *product in myProduct){
                 NSLog(@"Detail product info\n");
                 NSLog(@"SKProduct description: %@\n", [product description]);
                 NSLog(@"Product localized title: %@\n" , product.localizedTitle);
                 NSLog(@"Product localized descitption: %@\n" , product.localizedDescription);
                 NSLog(@"Product price: %@\n" , product.price);
                 NSLog(@"Product identifier: %@\n" , product.productIdentifier);
                 
                 [[IAPShare sharedHelper].iap buyProduct:product
                                            onCompletion:^(SKPaymentTransaction* trans){
                                            
                                            }];
             }
             
         }];
    }
}


- (IBAction)merchant2:(id)sender {
    if ([SKPaymentQueue canMakePayments]) {

    } else {
        NSLog(@"失败，用户禁止应用内付费购买.");
    }
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
