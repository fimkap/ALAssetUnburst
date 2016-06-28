//
//  ALAsset+Unburst.m
//  CellewiseHandset
//
//  Created by Efim Polevoi on 16/06/2016.
//
//

#import "ALAsset+Unburst.h"
#import <Photos/Photos.h>

/*
 *  Key for Apple metadata.
 */
static NSString * const kMakerApple = @"{MakerApple}";
/*
 *  Key for metadata which indicates the photo is taken by Burst Mode.
 */
static NSString * const kGUIDKey = @"11";

@implementation ALAsset (Unburst)

/*
 * iOS Camera sets Apple specific dictionary for key{MakerApple} into the metadata of photo. 
 * Burst Mode on iPhone sets value for key 11 into the Apple specific dictionary. 
 */
- (BOOL)representsBurst
{
    // We don't support unburst before iOS 8 support for Photos Framework
    if ([PHPhotoLibrary class])
    {
        NSDictionary *metadata = self.defaultRepresentation.metadata;

        NSDictionary *makerApple = metadata[kMakerApple];

        if (makerApple)
        {
            return makerApple[kGUIDKey];
        }
    }

    return NO;
}

- (NSString*)burstIdentifier
{
    if (![PHPhotoLibrary class]) {
        return nil;
    }

    // Convert ALAsset to PHAsset
    NSURL *url = [self valueForProperty:ALAssetPropertyAssetURL];
    PHFetchResult *assets = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    PHAsset *asset = assets[0];

    return asset.burstIdentifier;
}

- (void)fetchBurstAssets:(NSString*)burstID library:(ALAssetsLibrary*)library withHandler:(void (^)(ALAsset *asset))handler
{
    if (![PHPhotoLibrary class]) {
        return;
    }

    PHFetchOptions *options = [PHFetchOptions new];
    options.includeAllBurstAssets = YES;
    PHFetchResult *burstAssets = [PHAsset fetchAssetsWithBurstIdentifier:burstID options:options];
    [options release];

    dispatch_semaphore_t burstSemaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(burstSemaphore);

    for (PHAsset *burstAsset in burstAssets) {
        dispatch_semaphore_wait(burstSemaphore, DISPATCH_TIME_FOREVER);

        CBCustomLogger(CB_LOG_TYPE_DEBUG, @"Add burst asset");

        NSString *burstURLStr = [NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&ext=JPG",
                                                           [burstAsset.localIdentifier substringToIndex:36]];
        NSURL *burstURL = [NSURL URLWithString:burstURLStr];
        [library assetForURL:burstURL
            resultBlock:^(ALAsset *asset) {
                handler(asset);
                dispatch_semaphore_signal(burstSemaphore);
            }
            failureBlock:^(NSError *error) {
                dispatch_semaphore_signal(burstSemaphore);
                CBCustomLogger(CB_LOG_TYPE_DEBUG, @"Request image for asset failed: %@", error.description);
            }];
    }

    dispatch_semaphore_wait(burstSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(burstSemaphore);

    CBCustomLogger(CB_LOG_TYPE_DEBUG, @"Return from fetchBurstAssetsWithHandler");
    return;
}

@end
