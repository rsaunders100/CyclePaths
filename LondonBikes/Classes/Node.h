//
//  Node.h
//  LondonBikes
//
//  Created by Robert Saunders on 31/10/2011.
//  Copyright (c) 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Way;

@interface Node : NSManagedObject

@property (nonatomic, retain) NSNumber * latInt;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * lonInt;
@property (nonatomic, retain) Way *way;

@end
