//
//  ALAsset+Unburst.h
//  CellewiseHandset
//
//  Created by Efim Polevoi on 16/06/2016.
//
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Unburst)

- (BOOL)representsBurst;
- (NSString*)burstIdentifier;
- (void)fetchBurstAssets:(NSString*)burstID library:(ALAssetsLibrary*)library withHandler:(void (^)(ALAsset *asset))handler;

@end
