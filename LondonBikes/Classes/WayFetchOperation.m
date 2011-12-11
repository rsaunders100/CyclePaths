//
//  WayOperation.m
//  LondonBikes
//
//  Created by Robert Saunders on 12/06/2011.
//  Copyright 2011. All rights reserved.
//

#import "WayFetchOperation.h"
#import "CoreDataHelper.h"
#import "Way.h"
#import "WayPolyline.h"
#import "Config.h"

    
@interface WayFetchOperation()
@property (nonatomic, assign) MKCoordinateRegion fetchRegion;
@property (nonatomic, copy) NSArray* locationHashes;
@property (nonatomic, retain) NSPersistentStoreCoordinator* psc;
@property (nonatomic, copy) NSArray* currentOverlays;
@property (nonatomic, retain) NSManagedObjectContext* context;
@property (nonatomic, assign) BOOL allPaths;
@end




@implementation WayFetchOperation

@synthesize fetchRegion, locationHashes, psc, currentOverlays, allPaths;
@synthesize delegate;
@synthesize overlaysToAdd, overlaysToRemove;
@synthesize context;




- (id) initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*) persistentStoreCoordinator
                       currentAnnotations:(NSArray*) currentOverlaysIn 
                              fetchRegion:(MKCoordinateRegion)fetchRegionIn
                           locationHashes:(NSArray*)locationHashesIn 
                                 allPaths:(BOOL)allPathsIn

{
    self = [super init];
    if (self) 
    {
        self.fetchRegion = fetchRegionIn;
        self.locationHashes = locationHashesIn;
        self.psc = persistentStoreCoordinator;
        self.currentOverlays = currentOverlaysIn;
        self.allPaths = allPathsIn;
    }
    return self;
}
                                   

- (void)dealloc 
{
    self.context = nil;
    self.psc = nil;
    self.currentOverlays = nil;
    self.locationHashes = nil;
    
    self.overlaysToAdd = nil;
    self.overlaysToRemove = nil;

    [super dealloc];
}

- (void) main 
{
    // If we are cancled, stop now
    if ([self isCancelled]) return;
    
    @autoreleasepool 
    {
        // Create a new context
        self.context = [[[NSManagedObjectContext alloc] init] autorelease];
        context.persistentStoreCoordinator = psc;
        
        // Fetch the ways in the given region
        NSArray* ways = nil;
        
        ways = [CoreDataHelper waysInContext:context 
                                 fetchRegion:fetchRegion
                              locationHashes:locationHashes 
                                    allPaths:allPaths];
        
        // If we are cancled, stop now
        if (![self isCancelled]) 
        {
            // If a new ways donsnt exist in the old ways add it to the list of ways to add to the map
            self.overlaysToAdd    = [NSMutableArray arrayWithCapacity:700];
            
            // Create a dictionary out of the old ways so we can look them up quicker
            NSMutableDictionary* oldWayPolyLineDict =
                [NSMutableDictionary dictionaryWithCapacity:[currentOverlays count]];
                 
            for (WayPolyline* wayPolyLine in currentOverlays) 
            {
                [oldWayPolyLineDict setObject:wayPolyLine 
                                       forKey:[NSNumber numberWithLong:wayPolyLine.id]];
            }
            
            // If we are cancled, stop now
            if (![self isCancelled]) 
            {
                for (Way* way in ways) 
                {    
                    WayPolyline* identicalPolyLine = [oldWayPolyLineDict objectForKey:way.id];
                    if (!identicalPolyLine) 
                    {    
                        // No existing polyline,
                        // so create the line and add it to the list of new polylines
                        WayPolyline* polyLine = [WayPolyline polylineWithWay:way];
                        [self.overlaysToAdd addObject:polyLine];
                    }
                }
                
                // If we are cancled, stop now
                if (![self isCancelled]) 
                {
                    // If an old way dosnt exist in the new new ways add it to the list to purge
                    self.overlaysToRemove = [NSMutableArray arrayWithCapacity:700];
                    
                    // Create a dictionary out of the old ways so we can look them up quicker
                    NSMutableDictionary* newWayPolyLineDict =
                        [NSMutableDictionary dictionaryWithCapacity:[currentOverlays count]];
                    
                    for (Way* way in ways) 
                    {
                        [newWayPolyLineDict setObject:way 
                                               forKey:way.id];
                    }
                    
                    // If we are cancled, stop now
                    if (![self isCancelled]) 
                    {
                        for (WayPolyline* oldWayPolyLine in currentOverlays) 
                        {    
                            Way* identicalWay = 
                                [newWayPolyLineDict objectForKey:
                                    [NSNumber numberWithLong:oldWayPolyLine.id]];
                            
                            if (!identicalWay) 
                            {    
                                // No identical way in the new set 
                                // if this is not a cycle super highway 
                                // add it to the list of lines to delete
                                if (oldWayPolyLine.type != kWAY_TYPE_CYCLESUPERHIGHWAY) {
                                    [self.overlaysToRemove addObject:oldWayPolyLine];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Tell the delegate we have finished
    if (![self isCancelled] && self.delegate) {
        [self.delegate wayFetchOperationDidFinish:self];
    }
}




@end
