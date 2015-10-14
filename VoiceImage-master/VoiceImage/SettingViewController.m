
//
//  SettingViewController.m
//  VoiceImage
//
//  Created by caiwb on 15/8/26.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "SettingViewController.h"
#import "MerchantViewController.h"
#import "APPAppDelegate.h"

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnQQ;
@property (weak, nonatomic) IBOutlet UIButton *btnWechat;
@property (weak, nonatomic) IBOutlet UIButton *languageBtn;
@property (assign, nonatomic) BOOL isChooseLan;
@property (weak, nonatomic) IBOutlet UIButton *btnMerchant;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChooseLan = NO;
    [_btnQQ setImage:[UIImage imageNamed:@"Dzst_cbl_icon_QQ"] forState:UIControlStateNormal];
    [_btnWechat setImage:[UIImage imageNamed:@"Dzst_cbl_icon_Wechat"] forState:UIControlStateNormal];
    [_languageBtn setImage:[UIImage imageNamed:@"Dzst_cbl_icon_arrow_normal"] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseLanguage:(id)sender {
    if (_isChooseLan == NO) {
        [_languageBtn setImage:[UIImage imageNamed:@"Dzst_cbl_icon_arrow_normal"] forState:UIControlStateNormal];
        _isChooseLan = YES;
    }
    else {
        [_languageBtn setImage:[UIImage imageNamed:@"Dzst_cbl_icon_arrow_click"] forState:UIControlStateNormal];
        _isChooseLan = NO;
    }
}

- (IBAction)merchant:(id)sender {
    MerchantViewController * mvc = [[MerchantViewController alloc] init];
    [self presentViewController:mvc animated:YES completion:nil];
}



@end
