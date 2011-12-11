//
//  CoreDataTest.h
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LBModel.h"


@interface CoreDataTest : NSObject {
    
    NSManagedObjectContext* context;
}

@property (nonatomic, retain) NSManagedObjectContext* context;

- (id) initWithMOC:(NSManagedObjectContext*) moc;
- (void) preformTests;

- (void) saveContext;

@end
