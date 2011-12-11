//
//  CoreDataHelper.m
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//

#import "CoreDataHelper.h"
#import "Way.h"
#import "Config.h"
#import "LocationHash.h"

@implementation CoreDataHelper


+ (NSArray*) getAllEntitiesCalled:(NSString*) entityName context:(NSManagedObjectContext*) context
{   
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest 
                                            error:&error];
    [fetchRequest release];
    
    return items;
}



+ (void) printCountForEntity:(NSString*) entityName context:(NSManagedObjectContext*) context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: [NSEntityDescription entityForName:entityName
                                    inManagedObjectContext:context]];
    
    NSError *error = nil;
    
    NSUInteger count = [context countForFetchRequest: request error: &error];
    
    if (error) {
        NSLog(@"Error in PrintCount: %@",error);
    } else {
        NSLog(@"There are %d %@ entities",count,entityName);
    }
    
    [request release];
}

//static NSLock *theLock;

// We only want the non cycle superhighways
+ (NSArray*) waysInContext:(NSManagedObjectContext*)context
               fetchRegion:(MKCoordinateRegion)region
            locationHashes:(NSArray*)locationHashes 
                  allPaths:(BOOL)allPaths
{
    double minLon = region.center.longitude - region.span.longitudeDelta * 0.5;
    double maxLon = region.center.longitude + region.span.longitudeDelta * 0.5;
    double minLat = region.center.latitude - region.span.latitudeDelta * 0.5;
    double maxLat = region.center.latitude + region.span.latitudeDelta * 0.5;
    
    // We needed a lock before because we had a static context shared beteen threads
    //if (!theLock) theLock = [[NSLock alloc] init];
    //[theLock lock];
    
    NSString* predicateString = nil;
    
    // Only cycle superhighway and national cycle paths
    if (allPaths) 
    {
        
        for (NSNumber* hash in locationHashes) 
        {
            if (!predicateString) 
            {
                predicateString = [NSString stringWithFormat:@"(locationHash == %d", 
                                   [hash intValue]];
            }
            
            predicateString = [NSString stringWithFormat:@"%@ OR locationHash == %d", 
                               predicateString, [hash intValue]];
        }
        predicateString = [NSString stringWithFormat:
                           @"%@) AND minLonInt < %d AND maxLonInt > %d AND minLatInt < %d AND maxLatInt > %d", 
                           predicateString,
                           ((int)(maxLon*kLATLON_ENCODE_FACTOR)), ((int)(minLon*kLATLON_ENCODE_FACTOR)), 
                           ((int)(maxLat*kLATLON_ENCODE_FACTOR)), ((int)(minLat*kLATLON_ENCODE_FACTOR))];
    } 
    else 
    {
        predicateString = [NSString stringWithFormat:
                           @"type != 0 AND minLonInt < %d AND maxLonInt > %d AND minLatInt < %d AND maxLatInt > %d", 
                           ((int)(maxLon*kLATLON_ENCODE_FACTOR)), ((int)(minLon*kLATLON_ENCODE_FACTOR)), 
                           ((int)(maxLat*kLATLON_ENCODE_FACTOR)), ((int)(minLat*kLATLON_ENCODE_FACTOR))];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Way" 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Pre fetching nodes since we will need them all
    NSArray* keyPaths = [NSArray arrayWithObject:@"nodes"];
    [fetchRequest setRelationshipKeyPathsForPrefetching:keyPaths];
    
    
    NSError *error = nil;
    NSArray *ways = [context executeFetchRequest:fetchRequest 
                                           error:&error];
    [fetchRequest release];
    
    //[theLock unlock];
    
    return ways;
}

+ (NSArray*) cycleSuperHighwaysInContext:(NSManagedObjectContext*)context 
{    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d",kWAY_TYPE_CYCLESUPERHIGHWAY];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Way" 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Pre fetching nodes since we will need them all
    NSArray* keyPaths = [NSArray arrayWithObject:@"nodes"];
    [fetchRequest setRelationshipKeyPathsForPrefetching:keyPaths];
    
    NSError *error;
    NSArray *ways = [context executeFetchRequest:fetchRequest 
                                           error:&error];
    [fetchRequest release];
    
    return ways;
}



+ (void) clearAllEntity:(NSString*) entityName 
            fromContext:(NSManagedObjectContext*) context 
{    
    NSLog(@"Deleting all %@ entities",entityName);

    NSArray *items = [CoreDataHelper getAllEntitiesCalled:entityName
                                                  context:context];
    NSError *error;    
    for (NSManagedObject *managedObject in items) 
    {
        [context deleteObject:managedObject];
    }
    if (![context save:&error]) 
    {
        NSLog(@"Error deleting %@ - error:%@", entityName, error);
    }
}


+ (void) printMaxSpanOfWaysfromContext:(NSManagedObjectContext*) context 
{    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Way" 
                                              inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"cycleSuperHighwayIndex == 0"];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *ways = [context executeFetchRequest:fetchRequest 
                                            error:&error];
    
    [fetchRequest release];
    
    int32_t maxLonSpan = 0;
    int32_t maxLatSpan = 0;
    
    // For each item compute the span of the lon / lat
    for (Way* way in ways) 
    {
        int32_t lonSpan = [way.maxLonInt intValue] - [way.minLonInt intValue];
        int32_t latSpan = [way.maxLatInt intValue] - [way.minLatInt intValue];
        
        if (lonSpan > maxLonSpan) maxLonSpan = lonSpan;
        if (lonSpan > maxLatSpan) maxLatSpan = latSpan;
    }
    
    NSLog(@"max lonSpan:%d maxLatSpan:%d",maxLatSpan,maxLonSpan);
}



+ (void) deleteDuplicateWaysFromContext:(NSManagedObjectContext*)context
{    
    // We sort the ways by id
    // if two adjcent ways have the same id we delete the one without a
    // cyclesuperhighway id.
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Way" 
                                              inManagedObjectContext:context];
    NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"id"
                                                                    ascending:YES] autorelease];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *ways = [context executeFetchRequest:fetchRequest 
                                           error:&error];
    [fetchRequest release];
    
    Way* oldWay = nil;
    
    for (Way* way in ways) 
    {
        if ([oldWay.id longLongValue] == [way.id longLongValue]) 
        {       
            if ([way.type shortValue] != kWAY_TYPE_NONE) 
            {    
                [context deleteObject:oldWay];           
                oldWay = way;       
            }
            else 
            {
                [context deleteObject:way];
            }
        } 
        else 
        {        
            oldWay = way;
        }
    }
}

@end






