//
//  MWGridCell.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import "MWGridCell.h"
#import "MWCommon.h"
#import "MWPhotoBrowserPrivate.h"
#import "DACircularProgressView.h"
#include "../../VoiceImage/DataHolder.h"

@interface MWGridCell () {
    
    UIImageView *_imageView;
    UIImageView *_loadingError;
	DACircularProgressView *_loadingIndicator;
    UIButton *_selectedButton;
    
}

@end

@implementation MWGridCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.imageLoaded = NO;
        // Grey background
        self.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1];
        
        // Image
        _imageView = [UIImageView new];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
        
        // Selection button
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.contentMode = UIViewContentModeTopRight;
        _selectedButton.adjustsImageWhenHighlighted = NO;
        [_selectedButton setImage:nil forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/ImageSelectedSmallOff.png"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/ImageSelectedSmallOn.png"] forState:UIControlStateSelected];
        [_selectedButton addTarget:self action:@selector(selectionButtonPressed) forControlEvents:UIControlEventTouchDown];
        _selectedButton.hidden = YES;
        _selectedButton.frame = CGRectMake(0, 0, 44, 44);
        [self addSubview:_selectedButton];
    
		// Loading indicator
		_loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 40.0f)];
        _loadingIndicator.userInteractionEnabled = NO;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            _loadingIndicator.thicknessRatio = 0.1;
            _loadingIndicator.roundedCorners = NO;
        } else {
            _loadingIndicator.thicknessRatio = 0.2;
            _loadingIndicator.roundedCorners = YES;
        }
		[self addSubview:_loadingIndicator];
        
        // Listen for photo loading notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setProgressFromNotification:)
                                                     name:MWPHOTO_PROGRESS_NOTIFICATION
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                     name:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleFoldPhotoNotification:)
                                                     name:@"MWPHOTO_FOLD_PHOTO_NOTIFICATION"
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                         _loadingIndicator.frame.size.width,
                                         _loadingIndicator.frame.size.height);
    _selectedButton.frame = CGRectMake(self.bounds.size.width - _selectedButton.frame.size.width - 0,
                                       0, _selectedButton.frame.size.width, _selectedButton.frame.size.height);
}

#pragma mark - Cell

- (void)prepareForReuse {
    _photo = nil;
    _gridController = nil;
    _imageView.image = nil;
    _loadingIndicator.progress = 0;
    _selectedButton.hidden = YES;
    [self hideImageFailure];
    [super prepareForReuse];
}

#pragma mark - Image Handling

- (void)setPhoto:(id <MWPhoto>)photo {
    _photo = photo;
    if (_photo) {
        if (![_photo underlyingImage]) {
            [self showLoadingIndicator];
        } else {
            [self hideLoadingIndicator];
        }
    } else {
        [self showImageFailure];
    }
}

- (void)displayImage {
    if (self.imageLoaded == YES){
        _imageView.image = [_photo underlyingImage];
        //    self.imageLoaded = YES;
        _selectedButton.hidden = !_selectionMode;
        [self hideImageFailure];
    }
    else{
        [self flipwithDelay:0];
        
    }
}

-(void)showDefaultImage{
    _imageView.image = [[DataHolder sharedInstance] getDefaultImage];
    _selectedButton.hidden = !_selectionMode;
    [self hideImageFailure];
}

#pragma mark - Selection

- (void)setSelectionMode:(BOOL)selectionMode {
    _selectionMode = selectionMode;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _selectedButton.selected = isSelected;
}

- (void)selectionButtonPressed {
    _selectedButton.selected = !_selectedButton.selected;
    [_gridController.browser setPhotoSelected:_selectedButton.selected atIndex:_index];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 0.6;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark Indicators

- (void)hideLoadingIndicator {
    _loadingIndicator.hidden = YES;
}

- (void)showLoadingIndicator {
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
    [self hideImageFailure];
}

- (void)showImageFailure {
    if (!_loadingError) {
        _loadingError = [UIImageView new];
        _loadingError.image = [UIImage imageNamed:@"MWPhotoBrowser.bundle/images/ImageError.png"];
        _loadingError.userInteractionEnabled = NO;
        [_loadingError sizeToFit];
        [self addSubview:_loadingError];
    }
    [self hideLoadingIndicator];
    _imageView.image = nil;
    _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                     floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                     _loadingError.frame.size.width,
                                     _loadingError.frame.size.height);
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

#pragma mark - Notifications

- (void)setProgressFromNotification:(NSNotification *)notification {
    NSDictionary *dict = [notification object];
    id <MWPhoto> photoWithProgress = [dict objectForKey:@"photo"];
    if (photoWithProgress == _photo) {
        //        NSLog(@"%f", [[dict valueForKey:@"progress"] floatValue]);
        float progress = [[dict valueForKey:@"progress"] floatValue];
        _loadingIndicator.progress = MAX(MIN(1, progress), 0);
    }
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <MWPhoto> photo = [notification object];
    if (photo == _photo) {
        if ([photo underlyingImage]) {
            // Successful load
            [self displayImage];
            
        } else {
            // Failed to load
            [self showImageFailure];
        }
        [self hideLoadingIndicator];
    }
}

NSTimeInterval ADLivelyDefaultDuration = 0.2;
CGFloat CGFloatSign(CGFloat value) {
    if (value < 0) {
        return -1.0f;
    }
    return 1.0f;
}

-(void)foldToDefaultBackground{
    float speed = 0;
    UIImage* img = [[DataHolder sharedInstance] getDefaultImage];
    _imageView.image = img;
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/self.bounds.size.width;
    transform = CATransform3DRotate(transform, -CGFloatSign(speed) * M_PI/2, 0.0f, 1.0f, 0.0f);
    self.layer.transform = transform;
    
//    CATransform3D transform = self.layer.transform;
//    transform.m34 = -1.0/self.bounds.size.width;
//    self.layer.transform = transform;
    
    [UIView animateWithDuration:0.2f animations:^(void){
        CATransform3D transform = CATransform3DIdentity;
        transform = self.layer.transform;
        transform = CATransform3DRotate(transform, CGFloatSign(speed) * M_PI/2, 0.0f, 1.0f, 0.0f);
        self.layer.transform = transform;
        //self.layer.opacity = 1.0f - fabs(speed);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)foldwithDelay:(NSTimeInterval)delay{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/self.bounds.size.width;
    self.layer.transform = transform;
    float speed = 0.5;
    
    [UIView animateWithDuration:0.2f delay:delay options: UIViewAnimationOptionTransitionNone
    animations:^(void){
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, 0.0f, CGFloatSign(speed) * self.layer.bounds.size.height/2.0f, 0.0f);
        transform = CATransform3DRotate(transform, CGFloatSign(speed) * M_PI/2, 0.0f, 1.0f, 0.0f);
        self.layer.transform = CATransform3DTranslate(transform, 0.0f, -CGFloatSign(speed) * self.layer.bounds.size.height/2.0f, 0.0f);
        //self.layer.opacity = 1.0f - fabs(speed);
    } completion:^(BOOL finished) {
        if (finished){
            [self performSelectorOnMainThread:@selector(foldToDefaultBackground) withObject:nil waitUntilDone:NO];
        }
    }];

}

-(void)flipwithDelay:(NSTimeInterval)delay {
    UIImage* img = [[DataHolder sharedInstance] getDefaultImage];
    _imageView.image = img;
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/self.bounds.size.width;
    self.layer.transform = transform;
    float speed = 0.5;
    
    [UIView animateWithDuration:0.2f delay:delay options:UIViewAnimationOptionTransitionNone animations:^(void){
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, 0.0f, CGFloatSign(speed) * self.layer.bounds.size.height/2.0f, 0.0f);
        transform = CATransform3DRotate(transform, CGFloatSign(speed) * M_PI/2, 0.0f, 1.0f, 0.0f);
        self.layer.transform = CATransform3DTranslate(transform, 0.0f, -CGFloatSign(speed) * self.layer.bounds.size.height/2.0f, 0.0f);
        //self.layer.opacity = 1.0f - fabs(speed);
    } completion:^(BOOL finished) {
        if (finished){
            [self performSelectorOnMainThread:@selector(flipToImage) withObject:nil waitUntilDone:NO];
        }
        
    }];
}

-(void)flipToImage{
    float speed = 0;
    _imageView.image = [_photo underlyingImage];
    _selectedButton.hidden = !_selectionMode;
    [self hideImageFailure];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/self.bounds.size.width;
    transform = CATransform3DRotate(transform, -CGFloatSign(speed) * M_PI/2, 0.0f, 1.0f, 0.0f);
    self.layer.transform = transform;
    
    //    CATransform3D transform = self.layer.transform;
    //    transform.m34 = -1.0/self.bounds.size.width;
    //    self.layer.transform = transform;
    
    [UIView animateWithDuration:0.2f animations:^(void){
        CATransform3D transform = CATransform3DIdentity;
        transform = self.layer.transform;
        transform = CATransform3DRotate(transform, CGFloatSign(speed) * M_PI/2, 0.0f, 1.0f, 0.0f);
        self.layer.transform = transform;
        //self.layer.opacity = 1.0f - fabs(speed);
    } completion:^(BOOL finished) {
        if (finished){
            self.imageLoaded = YES;
        }
    }];
}

- (void)handleFoldPhotoNotification:(NSNotification *)notification {
    
    [self foldwithDelay:0];
    
}


@end
