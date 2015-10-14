//
//  NewFeatureController.m
//  VoiceImage
//
//  Created by caiwb on 15/9/6.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "NewFeatureController.h"
#import "UIView+Extension.h"
#import "APPAppDelegate.h"
#import "DataBaseHelper.h"

#define NewfeatureCount 4

@interface NewFeatureController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UIScrollView *scrollView;


@end

@implementation NewFeatureController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    CGFloat scrollW = scrollView.width;
    CGFloat scrollH = scrollView.height;
    for (int i=0; i<NewfeatureCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.width = scrollW;
        imageView.height = scrollH;
        imageView.y = 0;
        imageView.x = i * scrollW;
 
        NSString *name = [NSString stringWithFormat:@"Dzst_splash%d", i + 1];
        imageView.image = [UIImage imageNamed:name];
        [scrollView addSubview:imageView];
        
        if (i == NewfeatureCount - 1) {
            [self setupLastImageView:imageView];
        }
    }
    
    scrollView.contentSize = CGSizeMake(NewfeatureCount * scrollW, 0);
    scrollView.bounces = NO; // 去除弹簧效果
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = NewfeatureCount;
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.centerX = scrollW * 0.5;
    pageControl.centerY = scrollH - 50;
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double page = scrollView.contentOffset.x / scrollView.width;
    // 四舍五入计算出页码
    self.pageControl.currentPage = (int)(page + 0.5);
}

- (void)setupLastImageView:(UIImageView *)imageView
{
    // 最后一页
    imageView.userInteractionEnabled = YES;
    UIButton * weixin = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton * qq = [UIButton buttonWithType:UIButtonTypeCustom];
    weixin.frame = CGRectMake(imageView.bounds.size.width*1/6, imageView.bounds.size.height*3/4, 100, 40);
    qq.frame = CGRectMake(imageView.bounds.size.width*5/6-100, imageView.bounds.size.height*3/4, 100, 40);
    [weixin setTitle:@"微信登录" forState:UIControlStateNormal];
    [weixin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [weixin.layer setMasksToBounds:YES];
    [weixin.layer setCornerRadius:10.0];
    [weixin.layer setBorderWidth:1.0];
    [weixin.layer setBorderColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), (CGFloat[]){ 225, 225, 225, 1 })];
    [qq setTitle:@"QQ登录" forState:UIControlStateNormal];
    [qq setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [qq.layer setMasksToBounds:YES];
    [qq.layer setCornerRadius:10.0];
    [qq.layer setBorderWidth:1.0];
    [qq.layer setBorderColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), (CGFloat[]){ 225, 225, 225, 1 })];
    
    [imageView addSubview:weixin];
    [imageView addSubview:qq];
    
    [weixin addTarget:self action:@selector(loginByWechat) forControlEvents:UIControlEventTouchDown];
    [qq addTarget:self action:@selector(loginByQQ) forControlEvents:UIControlEventTouchDown];

    
}

- (void)loginByWechat
{
    [self start];
}

-(void)loginByQQ
{
    [self start];
}

- (void)start
{
    if (self.delegate != nil) {
        [self.delegate startApp];
    }
}

@end
