//
//  Way.h
//  LondonBikes
//
//  Created by Robert Saunders on 17/11/2011.
//  Copyright (c) 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface Way : NSManagedObject

@property (nonatomic, retain) NSNumber * maxLatInt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * maxLonInt;
@property (nonatomic, retain) NSNumber * minLatInt;
@property (nonatomic, retain) NSNumber * minLonInt;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * locationHash;
@property (nonatomic, retain) NSSet *nodes;
@end

@interface Way (CoreDataGeneratedAccessors)

- (void)addNodesObject:(Node *)value;
- (void)removeNodesObject:(Node *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;
@end
