//
//  LocationHash.h
//  LondonBikes
//
//  Created by Robert Saunders on 29/10/2011.
//  Copyright (c) 2011. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LocationHash : MKAnnotationView


+ (int32_t) hashFromHash:(int32_t)hash withRowOffset:(int)rowOffset clmOffset:(int)clmOffset;

+ (int32_t) locationHashForRegionWithMinLon:(double)minLon
                                     minLat:(double)minLat
                                     maxLon:(double)maxLon
                                     maxLat:(double)maxLat;

+ (int32_t) locationHashForCoordinate:(CLLocationCoordinate2D)coordinate;

+ (void) hashAllWaysInContext:(NSManagedObjectContext*)context;

@end
