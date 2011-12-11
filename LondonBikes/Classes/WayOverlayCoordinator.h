//
//  WayOverlayCoordinator.h
//  LondonBikes
//
//  Created by Robert Saunders on 10/07/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "WayFetchOperation.h"

@class MapViewController;


@interface WayOverlayCoordinator : NSObject <WayFetchOperationDelegate> {
    
    MKMapView* _mapView;
    
    BOOL _shouldRemoveDetailCyclePaths;
}

@property (nonatomic, assign) MapViewController* mapViewController;

- (id)initWithMapView:(MKMapView*) mapView;

- (void) applicationDidEnterBackground;
- (void) applicationWillEnterForeground;

- (void) loadWaysIntoMapViewContext:(NSManagedObjectContext*) context;

@end
