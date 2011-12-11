//
//  LocationHash.m
//  LondonBikes
//
//  Created by Robert Saunders on 29/10/2011.
//  Copyright (c) 2011. All rights reserved.
//

#import "LocationHash.h"
#import "CoreDataHelper.h"
#import "LBModel.h"
#import "Config.h"



int32_t locationHashFromLatLon(double lat, double lon) 
{
    // (lon + 180) / 360 * 2^z
    int tileX = (int)(floor((lon + 180.0) / 360.0 * TWO_POW_Z)); 
    
    // ((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * 2^z)
    int tileY = (int)(floor((1.0 - log( tan(lat * 0.0174532925) + 1.0 / cos(lat * 0.0174532925)) / M_PI) / 2.0 * TWO_POW_Z)); 
    
    return tileX + TWO_POW_Z *  tileY;
}



@implementation LocationHash

+ (int32_t) hashFromHash:(int32_t)hash withRowOffset:(int)rowOffset clmOffset:(int)clmOffset 
{
    return hash + TWO_POW_Z * clmOffset + rowOffset;
}


+ (int32_t) locationHashForCoordinate:(CLLocationCoordinate2D)coordinate 
{
    return locationHashFromLatLon(coordinate.latitude, coordinate.longitude);
}

+ (int32_t) locationHashForRegionWithMinLon:(double)minLon
                                     minLat:(double)minLat
                                     maxLon:(double)maxLon
                                     maxLat:(double)maxLat 
{    
    // Calculate the midpoint
    double midLat = minLat + (maxLat - minLat) / 2;
    double midLon = minLon + (maxLon - minLon) / 2;
    
    // Now return the hash.
    
    
    
    return locationHashFromLatLon(midLat, midLon);
}


+ (void) hashWay:(Way*)way 
         context:(NSManagedObjectContext*)context 
{
    // Compute the location hash
    int32_t hash = [LocationHash locationHashForRegionWithMinLon:((double)[way.minLonInt intValue]) * kLATLON_DECODE_FACTOR
                                                          minLat:((double)[way.minLatInt intValue]) * kLATLON_DECODE_FACTOR
                                                          maxLon:((double)[way.maxLonInt intValue]) * kLATLON_DECODE_FACTOR
                                                          maxLat:((double)[way.maxLatInt intValue]) * kLATLON_DECODE_FACTOR];
    
    // Set it on the way
    NSNumber* hashNumber = [NSNumber numberWithInt:hash];
    way.locationHash = hashNumber;
}

+ (void) hashAllWaysInContext:(NSManagedObjectContext*)context 
{
    NSArray* allWays = [CoreDataHelper getAllEntitiesCalled:@"Way" context:context];
    
    int count = [allWays count];
    
    int i = 0;
    
    for (Way* way in allWays) 
    {
        [self hashWay:way context:context];
        
        if ((++i) % 5000 == 0) 
        {
            NSLog(@"done %d of %d",i,count);
        }
    }
}



@end
