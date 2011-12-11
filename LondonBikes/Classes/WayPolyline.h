//
//  PolyLine+initWithWay.h
//  LondonBikes
//
//  Created by Robert Saunders on 30/05/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Way;

@interface WayPolyline : MKPolyline {
    
}

@property (nonatomic, assign) int16_t type;
@property (nonatomic, assign) int64_t id;

+ (WayPolyline*) polylineWithWay:(Way*) way;

@end
