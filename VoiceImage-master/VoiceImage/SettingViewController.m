
//
//  SettingViewController.m
//  VoiceImage
//
//  Created by caiwb on 15/8/26.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnQQ;
@property (weak, nonatomic) IBOutlet UIButton *btnWechat;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_btnQQ setImage:[UIImage imageNamed:@"Dzst_cbl_icon_QQ"] forState:UIControlStateNormal];
    [_btnWechat setImage:[UIImage imageNamed:@"Dzst_cbl_icon_Wechat"] forState:UIControlStateNormal];
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

@end
