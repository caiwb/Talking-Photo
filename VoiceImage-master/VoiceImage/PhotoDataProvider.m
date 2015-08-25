//
//  PhotoDataProvider.m
//  VoiceImage
//
//  Created by SPG on 7/3/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "PhotoDataProvider.h"
#import "ImageInfo.h"

@implementation PhotoDataProvider

-(void)getAllPictures:(id)object withSelector:(SEL)selector
{
    imageArray=[[NSArray alloc] init];
    mutableArray =[[NSMutableArray alloc]init];
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                CGImageRef iref = [result thumbnail];
                if (iref) {
                    
                    UIImage *theThumbnail = [UIImage imageWithCGImage:iref];
                    ImageInfo* info = [[ImageInfo alloc] init];
                    info.image = theThumbnail;
                    info.fullImageUrl = result.defaultRepresentation.url;
                    NSString* name = [[result defaultRepresentation] filename];
                    info.name = name;
                    [mutableArray addObject:info];
                }
                
            }
            
        }
        
    };
    
    
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
        }
        else{
            imageArray=[[NSArray alloc] initWithArray:mutableArray];
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            NSMutableArray *thumbs = [[NSMutableArray alloc] init];
            MWPhoto *photo;
            
            for (ImageInfo *imgInfo in mutableArray) {
                photo = [MWPhoto photoWithURL:imgInfo.fullImageUrl];
                photo.caption = imgInfo.name;
                [photos addObject:photo];
                
                photo = [MWPhoto photoWithImage: imgInfo.image];
                [thumbs addObject:photo];
            }
            
            
            /* Uncomment this block to use nib-based cells */
            //UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
            //[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
            /* end of nib-based cells block */
            
            self.photos = [[photos reverseObjectEnumerator] allObjects];
            self.thumbs = [[thumbs reverseObjectEnumerator] allObjects];;
            
            [object performSelector:selector withObject:object];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
    
    
}

-(void)getPicturesByName:(id)object withSelector:(SEL)selector names:(NSArray*)names {
    imageArray=[[NSArray alloc] init];
    mutableArray =[[NSMutableArray alloc]init];
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
//                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                CGImageRef iref = [result thumbnail];
                if (iref) {
                    NSString* name = [[result defaultRepresentation] filename];
                    if ([names containsObject:name]) {
                        UIImage *theThumbnail = [UIImage imageWithCGImage:iref];
                        ImageInfo* info = [[ImageInfo alloc] init];
                        info.image = theThumbnail;
                        info.fullImageUrl = result.defaultRepresentation.url;
                        
                        info.name = name;
                        [mutableArray addObject:info];
                    }
                    
                }
                
            }
            
        }
        else {
            
        }
        
    };
    
    
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
        }
        else{
            imageArray=[[NSArray alloc] initWithArray:mutableArray];
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            NSMutableArray *thumbs = [[NSMutableArray alloc] init];
            MWPhoto *photo;
            
            for (ImageInfo *imgInfo in mutableArray) {
                photo = [MWPhoto photoWithURL:imgInfo.fullImageUrl];
                photo.caption = imgInfo.name;
                [photos addObject:photo];
                
                photo = [MWPhoto photoWithImage: imgInfo.image];
                [thumbs addObject:photo];
            }
            
            
            self.photos = [[photos reverseObjectEnumerator] allObjects];
            self.thumbs = [[thumbs reverseObjectEnumerator] allObjects];
            
            [object performSelector:selector withObject:object];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

+ (instancetype)sharedInstance
{
    static PhotoDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PhotoDataProvider alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    selected = [[NSMutableArray alloc] init];
    return self;
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [selected containsObject:@(index)];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)sel {
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
    if (sel) {
        [selected addObject:@(index)];
    }
    else {
        [selected removeObject:@(index)];
    }
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self.parentView dismissViewControllerAnimated:YES completion:nil];
}

@end
