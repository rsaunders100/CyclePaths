//
//  MapStateHelper.m
//  LondonBikes
//
//  Created by Robert Saunders on 25/09/2011.
//  Copyright 2011. All rights reserved.
//

#import "MapStateHelper.h"

#define ZERO_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(0.0, 0.0), MKCoordinateSpanMake(0.0, 0.0));

#define SAVED_REGION_CACHE_TIME_HOURS 10000.0  // loads

@implementation MapStateHelper

+ (void) saveMapRegionToDisk:(MKCoordinateRegion) region 
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setDouble:region.span.latitudeDelta  forKey:@"region.span.lat"];
    [userDefaults setDouble:region.span.longitudeDelta forKey:@"region.span.lon"];
    [userDefaults setDouble:region.center.latitude     forKey:@"region.center.lat"];
    [userDefaults setDouble:region.center.longitude    forKey:@"region.center.lon"];
        
    // We save the date because we would like to ignore the 
    // data if its too old.
    [userDefaults setObject:[NSDate date] forKey:@"region.date"];
    
    [userDefaults synchronize];
}

+ (MKCoordinateRegion) loadMapRegionFromDisk 
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    // If we dont have any data return null data
    NSDate* lastTimeRegionWasSaved = [userDefaults objectForKey:@"region.date"];
    if (!lastTimeRegionWasSaved) return ZERO_REGION;
    
    // If the data has expired reutrn null data
    NSDate* expiryTime = [lastTimeRegionWasSaved dateByAddingTimeInterval:SAVED_REGION_CACHE_TIME_HOURS * 3600];

    NSDate* now = [NSDate date];
    if ([now laterDate:expiryTime] == now) return ZERO_REGION;
    
    // The data is good so pull it out
    MKCoordinateSpan span;
    span.latitudeDelta = [userDefaults doubleForKey:@"region.span.lat"];
    span.longitudeDelta = [userDefaults doubleForKey:@"region.span.lon"];
    CLLocationCoordinate2D coord;
    coord.latitude = [userDefaults doubleForKey:@"region.center.lat"];
    coord.longitude = [userDefaults doubleForKey:@"region.center.lon"];
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
    
    return region;
}

@end
