//
//  OSMParser.h
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//
//  Parses the OSM XML file to CoreData
//

#import <Foundation/Foundation.h>

@interface OSMParser : NSObject {

    NSManagedObjectContext* context;
    
    int m_foundNodes;
    int m_notFoundNodes;
}

- (id) initWithMOC:(NSManagedObjectContext*) moc;
- (void) parseXML:(NSString*)xmlString wayType:(int16_t)wayType;


@property (nonatomic, retain) NSManagedObjectContext* context;


@property (readonly) float proportionNotFoundNodes;

@end
