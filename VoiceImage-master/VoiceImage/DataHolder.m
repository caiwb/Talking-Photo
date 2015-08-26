//
//  DataHolder.m
//  VoiceImage
//
//  Created by SPG on 7/6/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "DataHolder.h"

NSString * const kuserId = @"userId";

@interface DataHolder ()

@end

@implementation DataHolder

- (id) init
{
    self = [super init];
    if (self)
    {
        self.userId = 0;
        defaultImage = [UIImage imageNamed:@"photo_bg1.png"];
    }
    return self;
}

+ (DataHolder *)sharedInstance
{
    static DataHolder *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      _sharedInstance = [[self alloc] init];
                  });
    
    return _sharedInstance;
}

//in this example you are saving data to NSUserDefault's
//you could save it also to a file or to some more complex
//data structure: depends on what you need, really

-(void)saveData
{
    [[NSUserDefaults standardUserDefaults]
     setObject:self.userId forKey:kuserId];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loadData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kuserId])
    {
        self.userId = (NSString*)[[NSUserDefaults standardUserDefaults]
                                   objectForKey:kuserId];
    }
    else
    {
        self.userId = nil;
    } 
}

-(UIImage*) getDefaultImage{
    return defaultImage;
}




@end
