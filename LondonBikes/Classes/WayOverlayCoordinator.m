//
//  WayOverlayCoordinator.m
//  LondonBikes
//
//  Created by Robert Saunders on 10/07/2011.
//  Copyright 2011. All rights reserved.
//

#import "WayOverlayCoordinator.h"
#import "Config.h"
#import "WayPolyline.h"
#import "CoreDataHelper.h"
#import "LocationHash.h"
#import "MapViewController.h"
#import "BarCoordinator.h"

@interface WayOverlayCoordinator() 
@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) NSOperationQueue* operationQueue;
@end


@implementation WayOverlayCoordinator

@synthesize mapView = _mapView;
@synthesize operationQueue;
@synthesize mapViewController;

- (id)initWithMapView:(MKMapView*) mapView {
    self = [super init];
    if (self) 
    {    
        self.mapView = mapView;
    }
    return self;
}



- (void) wayFetchOperationDidFinish:(WayFetchOperation*) wayOperation 
{    
    if ([wayOperation isCancelled]) return;
    
    if ([NSThread isMainThread]) 
    {
        
#if LOG_MAP_ROUTE_MANAGMENT
        NSLog(@"Number of paths to add    :%d",[wayOperation.overlaysToAdd count]);
        NSLog(@"Number of paths to delete :%d",[wayOperation.overlaysToRemove count]);
        NSLog(@"#### finished path operation ####");
#endif
        
        [_mapView addOverlays:wayOperation.overlaysToAdd];
        [_mapView removeOverlays:wayOperation.overlaysToRemove];   
        
        [mapViewController.barCoordinator progressFinished];
    } 
    else 
    {    
        [self performSelectorOnMainThread:@selector(wayFetchOperationDidFinish:) 
                               withObject:wayOperation
                            waitUntilDone:NO];
    }
    
}

- (void) applicationDidEnterBackground 
{    
    [self.operationQueue cancelAllOperations];
    
    [_mapView removeOverlays:_mapView.overlays];
}

- (void) applicationWillEnterForeground { 
    
}


- (void) requestPathsInContext:(NSManagedObjectContext*) context allPaths:(BOOL)allPaths 
{    
    if (!self.operationQueue) 
    {
        self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
        [self.operationQueue setMaxConcurrentOperationCount:2];
    }
    else 
    {
        [self.operationQueue cancelAllOperations];
    }
    
    NSArray* locationHashes = nil;
    
    if (allPaths) 
    {
        int32_t centerHash = [LocationHash locationHashForCoordinate:_mapView.region.center];
        locationHashes = [NSArray arrayWithObjects:
                          [NSNumber numberWithInt:centerHash],                       
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:-1 clmOffset:-1]],
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:-1 clmOffset:0]],                       
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:-1 clmOffset:1]],
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:0  clmOffset:-1]],                       
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:0  clmOffset:1]],                       
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:1  clmOffset:-1]],
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:1  clmOffset:0]],                      
                          [NSNumber numberWithInt:[LocationHash hashFromHash:centerHash withRowOffset:1  clmOffset:1]],                       
                          nil];
    } 
    
    WayFetchOperation* wayFetchOperation = 
    [[WayFetchOperation alloc] 
     initWithPersistentStoreCoordinator:[context persistentStoreCoordinator] 
     currentAnnotations:_mapView.overlays 
     fetchRegion:_mapView.region
     locationHashes:locationHashes 
     allPaths:allPaths];
    
#if LOG_MAP_ROUTE_MANAGMENT
    NSLog(@"--- start path operation ---");
    NSLog(@"Paths of map at start     :%d",[_mapView.overlays count]);
#endif
    
    wayFetchOperation.delegate = self;
    
    [self.operationQueue addOperation:wayFetchOperation];
    [wayFetchOperation release];
}


- (void) loadWaysIntoMapViewContext:(NSManagedObjectContext*) context 
{
    
#if LOG_LOCATION
    NSLog(@"lat: %f lon:%f",_mapView.region.center.latitude,_mapView.region.center.longitude);
    NSLog(@"spanlat: %f spanlon:%f",_mapView.region.span.latitudeDelta,_mapView.region.span.latitudeDelta);
    NSLog(@"---------------------");
#endif
    
    // If we are zoomed out above the min threshold, hide everything
    if (_mapView.region.span.latitudeDelta >= kZOOM_LEVEL_LAT_DELTA_MIN_REGIONAL_PATHS) 
    {
        [self.operationQueue cancelAllOperations];
        [_mapView removeOverlays:_mapView.overlays];
        [mapViewController.barCoordinator showStrongMagnificationIcon];
        [mapViewController.barCoordinator cancelProgress];
    } 
    
    // Otherwise if we are zoomed to below the min all paths threshold,
    // hide everyting but cycle superhighways and National cycle paths.
    // we should also request paths that are cycle superhighways or National cycle paths
    else if (_mapView.region.span.latitudeDelta >= kZOOM_LEVEL_LAT_DELTA_MIN_ALL_PATHS) 
    {   
        [mapViewController.barCoordinator showWeakMagnificationIcon];
        
        if (_shouldRemoveDetailCyclePaths) 
        {            
            NSMutableArray* overlaysToRemove = [[NSMutableArray alloc] initWithCapacity:1000];
            for (WayPolyline* wayPolyline in _mapView.overlays)
            {
                // If its not an interesting path remove it at this zoom level
                if (wayPolyline.type == kWAY_TYPE_NONE) 
                {
                    [overlaysToRemove addObject:wayPolyline];
                }
            }
            [_mapView removeOverlays:overlaysToRemove];
            [overlaysToRemove release];
            _shouldRemoveDetailCyclePaths = NO;
        }
        
        [mapViewController.barCoordinator startProgressWithSpeed:BarCoordinatorProgresSpeedMedium];
        [self requestPathsInContext:context allPaths:NO];            
    }
    
    // Otherwise request everything
    else  
    {
        _shouldRemoveDetailCyclePaths = YES;
        
        if (_mapView.region.span.latitudeDelta >= kZOOM_LEVEL_LAT_DELTA_MIN_SHORT_TIMER) 
        {
            [mapViewController.barCoordinator startProgressWithSpeed:BarCoordinatorProgresSpeedSlow];
        }
        else if (_mapView.region.span.latitudeDelta >= kZOOM_LEVEL_LAT_DELTA_MIN_NO_TIMER) 
        {
            [mapViewController.barCoordinator startProgressWithSpeed:BarCoordinatorProgresSpeedMedium];
        }
        else 
        {
            [mapViewController.barCoordinator cancelProgress];
        }
        
        [mapViewController.barCoordinator hideMagnificationIcon];
        [self requestPathsInContext:context allPaths:YES];
    }
}


- (void)dealloc {
    [_mapView release];
    [operationQueue cancelAllOperations];
    [operationQueue release];
    [super dealloc];
}


@end
