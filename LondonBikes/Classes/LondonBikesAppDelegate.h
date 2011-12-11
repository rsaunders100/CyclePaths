//
//  LondonBikesAppDelegate.h
//  LondonBikes
//
//  Created by Robert Saunders on 28/05/2011.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;

@interface LondonBikesAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MapViewController *mapViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
