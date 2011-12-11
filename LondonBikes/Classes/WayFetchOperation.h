//
//  WayOperation.h
//  LondonBikes
//
//  Created by Robert Saunders on 12/06/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class WayFetchOperation;

@protocol WayFetchOperationDelegate <NSObject>
- (void) wayFetchOperationDidFinish:(WayFetchOperation*) wayOperation;
@end


@interface WayFetchOperation : NSOperation

- (id) initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*) persistentStoreCoordinator
                       currentAnnotations:(NSArray*) currentOverlaysIn 
                              fetchRegion:(MKCoordinateRegion)fetchRegionIn
                           locationHashes:(NSArray*)locationHashesIn 
                                 allPaths:(BOOL)allPaths;


@property (nonatomic, assign) id <WayFetchOperationDelegate> delegate;

@property (nonatomic, retain) NSMutableArray* overlaysToAdd;
@property (nonatomic, retain) NSMutableArray* overlaysToRemove;

@end
