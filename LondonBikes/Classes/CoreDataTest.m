//
//  CoreDataTest.m
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//

#import "CoreDataTest.h"
#import "CoreDataHelper.h"
#import "LocationHash.h"
#import "Config.h"

@implementation CoreDataTest

@synthesize context;

- (id) initWithMOC:(NSManagedObjectContext*) moc {
    self = [super init];
    if (self) {
        self.context = moc;
    }
    return self;
}

- (void)dealloc {
    [context release];
    [super dealloc];
}


- (void) preformTests 
{    
    NSLog(@"TESTS STARTED");
    
    [CoreDataHelper printCountForEntity:@"Node" context:context];
    [CoreDataHelper printCountForEntity:@"Way" context:context];
    
    Node* node = [NSEntityDescription insertNewObjectForEntityForName:@"Node" 
                                               inManagedObjectContext:context];
    
    node.latInt = [NSNumber numberWithInt:1 * kLATLON_ENCODE_FACTOR];
    node.lonInt = [NSNumber numberWithInt:1 * kLATLON_ENCODE_FACTOR];
    node.order = [NSNumber numberWithShort:1];
    
    Way* way = [NSEntityDescription insertNewObjectForEntityForName:@"Way" 
                                               inManagedObjectContext:context];
    
    way.minLatInt = [NSNumber numberWithInt:(int32_t)(1.0 * kLATLON_ENCODE_FACTOR)];
    way.minLonInt = [NSNumber numberWithInt:(int32_t)(1.0 * kLATLON_ENCODE_FACTOR)];
    way.maxLatInt = [NSNumber numberWithInt:(int32_t)(10.0 * kLATLON_ENCODE_FACTOR)];
    way.maxLonInt = [NSNumber numberWithInt:(int32_t)(10.0 * kLATLON_ENCODE_FACTOR)];
    
    way.id = [NSNumber numberWithLong:1000000000l];
    
    way.nodes = [NSSet setWithObject:node];
    
    Node* node2 = [NSEntityDescription insertNewObjectForEntityForName:@"Node" 
                                               inManagedObjectContext:context];
    
    node2.latInt = [NSNumber numberWithInt:10 * kLATLON_ENCODE_FACTOR];
    node2.lonInt = [NSNumber numberWithInt:10 * kLATLON_ENCODE_FACTOR];
    node2.order = [NSNumber numberWithShort:1];
    
    Way* way2 = [NSEntityDescription insertNewObjectForEntityForName:@"Way" 
                                             inManagedObjectContext:context];
    
    way2.minLatInt = [NSNumber numberWithInt:(int32_t)(10.0 * kLATLON_ENCODE_FACTOR)];
    way2.minLonInt = [NSNumber numberWithInt:(int32_t)(10.0 * kLATLON_ENCODE_FACTOR)];
    way2.maxLatInt = [NSNumber numberWithInt:(int32_t)(100.0 * kLATLON_ENCODE_FACTOR)];
    way2.maxLonInt = [NSNumber numberWithInt:(int32_t)(100.0 * kLATLON_ENCODE_FACTOR)];
    way2.type = [NSNumber numberWithShort:1];
    way2.id = [NSNumber numberWithLong:1000000000l];
    
    way2.nodes = [NSSet setWithObject:node2];
    
    [LocationHash hashAllWaysInContext:context];
    
    NSLog(@"Created Node: %@",node);
    NSLog(@"Created Way: %@",way);
    NSLog(@"Created Node2: %@",node2);
    NSLog(@"Created Way2: %@",way2);
    
    [CoreDataHelper printCountForEntity:@"Node" context:context];
    [CoreDataHelper printCountForEntity:@"Way" context:context];
    
    [self saveContext];
    
    NSLog(@"Deleting duplicates");
    
    [CoreDataHelper deleteDuplicateWaysFromContext:context];
    
    [CoreDataHelper printCountForEntity:@"Node" context:context];
    [CoreDataHelper printCountForEntity:@"Way" context:context];
    
    NSLog(@"Removing created objects");
    
    [context deleteObject:node];
    [context deleteObject:way];
    [context deleteObject:node2];
    [context deleteObject:way2];
    
    [CoreDataHelper printCountForEntity:@"Node" context:context];
    [CoreDataHelper printCountForEntity:@"Way" context:context];
    
    [self saveContext];
    
    NSLog(@"TESTS DONE");
}


- (void) saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.context;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Error saving context %@, %@", error, [error userInfo]);
        } else {
            NSLog(@"Saved context");
        }
    }
}


@end
