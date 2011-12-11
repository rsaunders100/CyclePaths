//
//  LondonBikesAppDelegate.m
//  LondonBikes
//
//  Created by Robert Saunders on 28/05/2011.
//  Copyright 2011. All rights reserved.
//

#import "LondonBikesAppDelegate.h"
#import "MapViewController.h"
#import "CoreDataTest.h"
#import "CoreDataHelper.h"
#import "OSMParser.h"
#import "Config.h"
#import "LocationHash.h"

@implementation LondonBikesAppDelegate


@synthesize window=_window;
@synthesize mapViewController=_mapViewController;

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    UIViewController* defaultGenVC = [[UIViewController alloc] initWithNibName:@"DefaultGen" bundle:nil];
//    self.window.rootViewController = defaultGenVC;
    
    self.window.rootViewController = self.mapViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.mapViewController applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application 
{
    [self.mapViewController applicationWillEnterForeground];
}

- (void)dealloc
{
    [_window release];
    [_mapViewController release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)awakeFromNib
{
    
    
#if TEST_COREDATA
    CoreDataTest* tester = [[CoreDataTest alloc] initWithMOC:self.managedObjectContext];
    [tester preformTests];
    [tester release];
#endif
    
#if PARSE_OSM_XML
    
    [CoreDataHelper printCountForEntity:@"Node" context:self.managedObjectContext];
    [CoreDataHelper printCountForEntity:@"Way" context:self.managedObjectContext];
    
    NSLog(@"Starting Parse");
    
    NSURL *xmlURL = nil;
    NSString* xmlString = nil;
    OSMParser* osmParser = [[OSMParser alloc] initWithMOC:self.managedObjectContext];
    
    xmlURL = [[NSBundle mainBundle] URLForResource:@"cs.osm"
                                     withExtension:@"xml"];
    xmlString = [NSString stringWithContentsOfURL:xmlURL
                                         encoding:NSStringEncodingConversionAllowLossy
                                            error:nil];    
    [osmParser parseXML:xmlString wayType:kWAY_TYPE_CYCLESUPERHIGHWAY];
    NSLog(@"Nodes not found = %0.1f%%",(osmParser.proportionNotFoundNodes * 100.0));
    
    
    xmlURL = [[NSBundle mainBundle] URLForResource:@"ncn.osm"
                                     withExtension:@"xml"];
    xmlString = [NSString stringWithContentsOfURL:xmlURL
                                         encoding:NSStringEncodingConversionAllowLossy
                                            error:nil];    
    [osmParser parseXML:xmlString wayType:kWAY_TYPE_NATIONAL_CYCLE_PATH];
    NSLog(@"Nodes not found = %0.1f%%",(osmParser.proportionNotFoundNodes * 100.0));
    
    
    xmlURL = [[NSBundle mainBundle] URLForResource:@"bikePaths.osm"
                                     withExtension:@"xml"];
    xmlString = [NSString stringWithContentsOfURL:xmlURL
                                         encoding:NSStringEncodingConversionAllowLossy
                                            error:nil];    
    [osmParser parseXML:xmlString wayType:kWAY_TYPE_NONE];
    NSLog(@"Nodes not found = %0.1f%%",(osmParser.proportionNotFoundNodes * 100.0));    
    
    
    [CoreDataHelper printCountForEntity:@"Node" context:self.managedObjectContext];
    [CoreDataHelper printCountForEntity:@"Way" context:self.managedObjectContext];    
    NSLog(@"Deleting duplicates");
    [CoreDataHelper deleteDuplicateWaysFromContext:self.managedObjectContext];
    [CoreDataHelper printCountForEntity:@"Node" context:self.managedObjectContext];
    [CoreDataHelper printCountForEntity:@"Way" context:self.managedObjectContext];    
    
    NSLog(@"Hashing Locations");
    [LocationHash hashAllWaysInContext:self.managedObjectContext];  
    
    [osmParser release];    
    
    [self saveContext];
    
#endif
    
    self.mapViewController.context = self.managedObjectContext;

}


#pragma mark - Core Data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LBCoreDataModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    
    // Use the bundle as the store location (dont copy it over)
    // we will never need to write to it
    NSURL* storeURL = [[NSBundle mainBundle] URLForResource:@"LBCoreData"
                                              withExtension:@"sqlite"];
    
    
#if PARSE_OSM_XML
    // If we are creating the store from scratch, 
    // we should create it in the document directory.
    // otherwise (in the bundle) we wont be albe to write to it
    storeURL = [[self applicationDocumentsDirectory] 
                    URLByAppendingPathComponent:@"LBCoreData.sqlite"];
#endif
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                    initWithManagedObjectModel:[self managedObjectModel]];
                                       
#if PARSE_OSM_XML
   NSDictionary* optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      NSFileProtectionNone,         NSFileProtectionKey,
                                      nil];
#else
   NSDictionary* optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      NSFileProtectionNone,         NSFileProtectionKey,
                                      [NSNumber numberWithBool:1],  NSReadOnlyPersistentStoreOption,
                                      nil];                                                                    
#endif                                       

    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                    configuration:nil
                                                              URL:storeURL
                                                          options:optionsDictionary
                                                            error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}




@end
