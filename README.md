# ALAssetUnburst
Fetch all assets from the burst sequence from iOS 8. It can be helpful if you still support iOS < 8.0 and
Photos Framework is not available but for devices with higher iOS versions you need to support burst. 
You'll want to implement a cache for already unbursted IDs so that not to take the sequence again for favorites.
The handler for assets from the bursts is called synchronously so fetchBurstAssets will not return until all the assets are handled.

Example:

static ALAssetsLibrary *library = nil;
static NSMutableDictionary *burstIDsCache = nil;

[group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {

    BOOL isBurst = [asset representsBurst];
    if (isBurst) {
            NSString *burstID = [asset burstIdentifier];
            // avoid adding the same bursts on favorites
            if (![burstIDsCache objectForKey:burstID]) {
                [burstIDsCache setObject:[NSNumber numberWithBool:YES] forKey:burstID];

                [asset fetchBurstAssets:burstID
                                  library:library
                              withHandler:^(ALAsset *burstAsset) {
                                  // Do whatever you like with the burst sequence assets here
                                  ALAssetRepresentation *representation = [burstAsset defaultRepresentation];
                }];
        }
    }
}];

