//
//  CoreDataHelper.h
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface CoreDataHelper : NSObject {
    
}

+ (void) printCountForEntity:(NSString*) entityName context:(NSManagedObjectContext*) context;

+ (NSArray*) cycleSuperHighwaysInContext:(NSManagedObjectContext*)context;

+ (void) clearAllEntity:(NSString*) entityName 
            fromContext:(NSManagedObjectContext*) context;

+ (NSArray*) waysInContext:(NSManagedObjectContext*)context
               fetchRegion:(MKCoordinateRegion)region
            locationHashes:(NSArray*)locationHashes 
                  allPaths:(BOOL)allPaths;

+ (void) printMaxSpanOfWaysfromContext:(NSManagedObjectContext*)context;

+ (NSArray*) getAllEntitiesCalled:(NSString*) entityName
                          context:(NSManagedObjectContext*)context;

+ (void) deleteDuplicateWaysFromContext:(NSManagedObjectContext*)context;

@end
