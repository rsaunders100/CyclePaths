//
//  MapStateHelper.h
//  LondonBikes
//
//  Created by Robert Saunders on 25/09/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/* 
 
 Save the state of the map (location and zoom)
   (with an expiry date)
 
 When loading the map state
 it will check the expiry date,
 if we have passed the date it will return a zero region - {0,0} {0,0} 
 
 */


@interface MapStateHelper : NSObject {
    
}

+ (void) saveMapRegionToDisk:(MKCoordinateRegion) region;
+ (MKCoordinateRegion) loadMapRegionFromDisk;


@end
