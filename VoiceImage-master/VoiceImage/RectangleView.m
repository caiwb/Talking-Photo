//
//  RectangleView.m
//  VoiceImage
//
//  Created by Rocky on 15/9/11.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "RectangleView.h"

@implementation RectangleView


- (void)drawRect:(CGRect)rect {
    
    _clickTag = 0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置矩形填充颜色
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0);
    //填充矩形
    CGContextFillRect(context, rect);
    //设置画笔颜色
    CGContextSetRGBStrokeColor(context, 250.0, 128.0, 0.0, 1.0);
    //设置画笔线条粗细
    CGContextSetLineWidth(context, 5.0);
    //画矩形边框
    CGContextAddRect(context,rect);
    //执行绘画
    CGContextStrokePath(context);
}


@end
