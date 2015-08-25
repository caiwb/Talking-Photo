//
//  MWGridCell.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWGridViewController.h"
#import "PSTCollectionView.h"

extern NSTimeInterval ADLivelyDefaultDuration;
typedef NSTimeInterval (^ADLivelyTransform)(CALayer * layer, float speed);
extern ADLivelyTransform ADLivelyTransformFlip;

@interface MWGridCell : PSTCollectionViewCell {}

@property (nonatomic, weak) MWGridViewController *gridController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) id <MWPhoto> photo;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL imageLoaded;

- (void)displayImage;
-(void)showDefaultImage;
-(void)flipwithDelay:(NSTimeInterval)delay;

@end
