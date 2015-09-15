//
//  PhotoDataProvider.m
//  VoiceImage
//
//  Created by SPG on 7/3/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "PhotoDataProvider.h"
#import "ImageInfo.h"
#import "MyPhotoBrowser.h"
#import "DataBaseHelper.h"

@interface PhotoDataProvider()

@end

@implementation PhotoDataProvider

-(void)getAllPictures:(id)object withSelector:(SEL)selector
{
//    [assetArray removeAllObjects];
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
                    info.assetTime = [result valueForProperty:ALAssetPropertyDate];
                    info.assetLoc = [NSString stringWithFormat:@"%@",[result valueForProperty:ALAssetPropertyLocation]];
                
                    if (isFindAssetDone == NO) {
                        [assetArray addObject:info];
                    }
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
            
            if (isFindAssetDone == NO) {
                [self.delegate startUploadOldPhoto];
                
            }
            isFindAssetDone = YES;
            
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
    NSMutableArray * photoInfoBySort = [[NSMutableArray alloc] init];
    
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
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            NSMutableArray *thumbs = [[NSMutableArray alloc] init];
            MWPhoto *photo;
            
            //将查找按返回顺序排序的照片按返回顺序排序
            NSMutableArray * imageNameBySort = [NSMutableArray array];
            for(ImageInfo * info in mutableArray)
            {
                [imageNameBySort addObject:info.name];
            }
#pragma ----待优化……
            for (NSString * imageName in names) {
                if ([imageNameBySort containsObject:imageName]) {
                    for (ImageInfo * info in mutableArray) {
                        if ([info.name isEqualToString:imageName]) {
                            [photoInfoBySort addObject:info];
                        }
                    }
                }
            }
            
            for (ImageInfo *imgInfo in photoInfoBySort) {
                photo = [MWPhoto photoWithURL:imgInfo.fullImageUrl];
                photo.caption = imgInfo.name;
                [photos addObject:photo];
                
                photo = [MWPhoto photoWithImage: imgInfo.image];
                [thumbs addObject:photo];
            }
            
            
            self.photos = [[photos objectEnumerator] allObjects];
            self.thumbs = [[thumbs objectEnumerator] allObjects];
            
            [object performSelector:selector withObject:object];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error--%@",error);}];
    
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
    _selected = [[NSMutableArray alloc] init];
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
//    return captionView;
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    [self.delegate viewSinglePhoto];
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {

    return [_selected containsObject:[NSNumber numberWithInteger:index]];
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    //view single photo
    if([self.delegate respondsToSelector:@selector(viewSinglePhoto)]) {
        [self.delegate viewSinglePhoto];
    }
    return [NSString stringWithFormat:@"第 %lu 张照片", (unsigned long)index+1];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoBrowser:(unsigned long)numberOfPhotos
{
    if([self.delegate respondsToSelector:@selector(viewPhotos)]) {
        [self.delegate viewPhotos];
    }
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)sel {
    
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, sel ? @"YES" : @"NO");
    if (sel) {
        [_selected addObject:[NSNumber numberWithInteger:index]];
    }
    else {
        [_selected removeObject:[NSNumber numberWithInteger:index]];
    }
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser isSelectedModel:(BOOL)selected{
    // If we subscribe to this method we must dismiss the view controller ourselves
    [_selected removeAllObjects];
    _isSelectedModel = selected;
    if (_isSelectedModel == NO) {
        NSLog(@"Did finish modal presentation ,selected model:YES");
        [self.delegate selectedModelPresented];
    }
    else {
        NSLog(@"Did finish modal presentation ,selected model:NO");
        [self.delegate selectedModelHidden];
    }
    [self.parentView dismissViewControllerAnimated:YES completion:nil];
}

@end
