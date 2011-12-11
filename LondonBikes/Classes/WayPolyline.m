//
//  PolyLine+initWithWay.m
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//

#import "WayPolyline.h"
#import "LBModel.h"
#import "Config.h"

@implementation WayPolyline

@synthesize type, id;

+ (WayPolyline*) polylineWithWay:(Way*) way 
{    
    int numberOfNodes = [way.nodes count];
  
    CLLocationCoordinate2D* locations;
    locations = malloc(sizeof(CLLocationCoordinate2D) * numberOfNodes);
    
    for (Node* node in way.nodes) 
    {    
        short index = [node.order shortValue];
        CLLocationCoordinate2D location;
        
        location.latitude = (((double)[node.latInt intValue]) * kLATLON_DECODE_FACTOR);
        location.longitude = (((double)[node.lonInt intValue]) * kLATLON_DECODE_FACTOR);        
        
        locations[index] = location;
    }
    
    WayPolyline* returnLine = (WayPolyline*) [WayPolyline polylineWithCoordinates:locations
                                                                            count:numberOfNodes];
    returnLine.type = [way.type shortValue];
    returnLine.id   = [way.id longLongValue];
    
    free(locations);

    return returnLine;
}


@end
