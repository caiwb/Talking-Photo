//
//  MyLock.m
//  VoiceImage
//
//  Created by caiwb on 15/9/8.
//  Copyright (c) 2015年 SPG. All rights reserved.
//

#import "MyLock.h"

@interface MyLock()
@end

@implementation MyLock

- (id)init {
    return [super init];
}

- (void)lock {
    NSLog(@"before lock");
    [super lock];
    NSLog(@"after lock");
}

- (void)unlock {
    NSLog(@"before unlock");
    [super unlock];
    NSLog(@"after unlock");
}

@end