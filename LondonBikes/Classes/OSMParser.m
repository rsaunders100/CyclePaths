//
//  OSMParser.m
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//

#import "OSMParser.h"
#import "TBXML.h"
#import "TempNode.h"
#import "LBModel.h"
#import "Config.h"
#import "CoreDataHelper.h"



@interface OSMParser()
- (void) loadNodeFromNodeElement:(TBXMLElement*)nodeElement intoDictionary:(NSMutableDictionary*) nodeDict;
- (void) createWayEntityFromWayElement:(TBXMLElement*)wayElement 
                   usingNodeDictionary:(NSMutableDictionary*) nodeDict
                               wayType:(int16_t)wayType;
@end


@implementation OSMParser

@synthesize context;

- (id) initWithMOC:(NSManagedObjectContext*) moc {
    self = [super init];
    if (self) {
        self.context = moc;
    }
    return self;
}


- (void) parseXML:(NSString*)xmlString wayType:(int16_t)wayType 
{
    TBXML* tbxml = [TBXML tbxmlWithXMLString:xmlString];
    
    TBXMLElement* element = tbxml.rootXMLElement->firstChild;
    
    int wayCount = 0;
    int nodeCount = 0;
    
    NSMutableDictionary* nodeDict = [NSMutableDictionary dictionaryWithCapacity:1000];
    
    m_foundNodes = 0;
    m_notFoundNodes = 0;
    
    do {
        
        if ([[TBXML elementName:element] isEqualToString:@"node"]) {
            nodeCount++;
            
            [self loadNodeFromNodeElement:element
                           intoDictionary:nodeDict];
        }
        
        if ([[TBXML elementName:element] isEqualToString:@"way"]) {
            wayCount++;
            
            [self createWayEntityFromWayElement:element
                            usingNodeDictionary:nodeDict 
                                        wayType:wayType];
        }
        
    } while ((element = element->nextSibling));
    
    NSLog(@"there are %d ways",wayCount);
    NSLog(@"there are %d nodes",nodeCount);
    
    NSLog(@"dictCount:%d",[nodeDict count]);
}


- (void) loadNodeFromNodeElement:(TBXMLElement*)nodeElement
                  intoDictionary:(NSMutableDictionary*) nodeDict {
    
    TempNode* node = [[TempNode alloc] init];
    
    TBXMLAttribute * attribute = nodeElement->firstAttribute;
    
    while (attribute) {
        
        if ([[TBXML attributeName:attribute] isEqualToString:@"id"]) {              
            node.id = [[TBXML attributeValue:attribute] intValue];
        }
        
        if ([[TBXML attributeName:attribute] isEqualToString:@"lat"]) {              
            node.lat = [[TBXML attributeValue:attribute] doubleValue];
        }
        
        if ([[TBXML attributeName:attribute] isEqualToString:@"lon"]) {              
            node.lon = [[TBXML attributeValue:attribute] doubleValue];
        }
        
        // Obtain the next attribute
        attribute = attribute->next;
    }
    
    [nodeDict setObject:node forKey:[NSString stringWithFormat:@"%d",node.id]];
    [node release];
    
}


- (void) createWayEntityFromWayElement:(TBXMLElement*)wayElement 
                   usingNodeDictionary:(NSMutableDictionary*) nodeDict
                               wayType:(int16_t)wayType  
{    
    TBXMLAttribute * wayAttribute = wayElement->firstAttribute;
    NSString* wayId = nil;
    
    while (wayAttribute) {
        
        if ([[TBXML attributeName:wayAttribute] isEqualToString:@"id"]) {              
            
            wayId = [TBXML attributeValue:wayAttribute];
        }
        
        // Obtain the next attribute
        wayAttribute = wayAttribute->next;
    }
    
    wayElement = wayElement->firstChild;

    NSMutableArray* nodesArray = [NSMutableArray arrayWithCapacity:40];
    
    do {
        
        if ([[TBXML elementName:wayElement] isEqualToString:@"nd"]) {
        
            TBXMLAttribute * attribute = wayElement->firstAttribute;
            
            while (attribute) {
                
                if ([[TBXML attributeName:attribute] isEqualToString:@"ref"]) {              
                    
                    NSString* idString = [TBXML attributeValue:attribute];
                    id obj = [nodeDict objectForKey:idString];
                    if (obj) {
                        m_foundNodes++;
                        [nodesArray addObject:[nodeDict objectForKey:idString]];
                    } else {
                        m_notFoundNodes ++;
                    }
                    
                }
                
                // Obtain the next attribute
                attribute = attribute->next;
            }
        }
        
    } while ((wayElement = wayElement->nextSibling));
    
    double minLon = 10000.0;
    double minLat = 10000.0;
    double maxLon = -10000.0;
    double maxLat = -10000.0;
    
    Way* way = [NSEntityDescription insertNewObjectForEntityForName:@"Way" 
                                             inManagedObjectContext:context];
    
    short i = 0;
    for (TempNode* tempNode in nodesArray) 
    {
        Node* node = [NSEntityDescription insertNewObjectForEntityForName:@"Node" 
                                                   inManagedObjectContext:context];
        
        if (tempNode.lat > maxLat) 
        {
            maxLat = tempNode.lat;
        }
        if (tempNode.lon > maxLon) 
        {
            maxLon = tempNode.lon;
        }
        if (tempNode.lat < minLat) 
        {
            minLat = tempNode.lat;
        }
        if (tempNode.lon < minLon) 
        {
            minLon = tempNode.lon;
        }
        
        int32_t encodeLat = (int32_t)(tempNode.lat * kLATLON_ENCODE_FACTOR);
        int32_t encodeLon = (int32_t)(tempNode.lon * kLATLON_ENCODE_FACTOR);
        
        node.latInt = [NSNumber numberWithInt:encodeLat];
        node.lonInt = [NSNumber numberWithInt:encodeLon];
        
        node.order = [NSNumber numberWithShort:i];
        node.way = way;
        
        i++;
    }
    
    way.id = [NSNumber numberWithLongLong:[wayId longLongValue]];
    
    way.type = [NSNumber numberWithInt:wayType];
    
    way.maxLatInt = [NSNumber numberWithInt:(int32_t)(maxLat * kLATLON_ENCODE_FACTOR)];
    way.minLatInt = [NSNumber numberWithInt:(int32_t)(minLat * kLATLON_ENCODE_FACTOR)];
    way.maxLonInt = [NSNumber numberWithInt:(int32_t)(maxLon * kLATLON_ENCODE_FACTOR)];
    way.minLonInt = [NSNumber numberWithInt:(int32_t)(minLon * kLATLON_ENCODE_FACTOR)];
}



- (void)dealloc 
{
    [context release];
    [super dealloc];
}


- (float) proportionNotFoundNodes 
{    
    if (m_foundNodes + m_notFoundNodes != 0) 
    {
        return (float)m_notFoundNodes / (float)(m_notFoundNodes + m_foundNodes);
    }
    else 
    {
        return 0;
    }
}





@end
