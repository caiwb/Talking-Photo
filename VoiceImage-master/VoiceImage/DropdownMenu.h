//
//  DropdownMenu.h
//  VoiceImage
//
//  Created by caiwb on 15/9/7.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropdownMenu;

@protocol DropdownMenuDelegate <NSObject>

@optional
- (void)dropdownMenuDidDismiss:(DropdownMenu *)menu;
- (void)dropdownMenuDidShow:(DropdownMenu *)menu;

@end

@interface DropdownMenu : UIView

@property (nonatomic, weak) id<DropdownMenuDelegate> delegate;
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UIViewController *contentController;

+ (instancetype)menu;

- (void)showFrom:(UIView *)from;

//- (void)dismiss;


@end

