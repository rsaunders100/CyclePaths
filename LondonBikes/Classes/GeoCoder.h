//
//  GeoCoder.h
//  LondonBikes
//
//  Created by Robert Saunders on 21/06/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <MapKit/MapKit.h>

typedef enum {
    GeoCoderFailReasonConnection,
    GeoCoderFailReasonCouldNotFindLocation,
    GeoCoderFailReasonUnknown
} GeoCoderFailReason;


@protocol GeoCoderDelegate <NSObject>
@optional
- (void) geoCoderDidReturnSearchRegion:(MKCoordinateRegion) region;
- (void) geoCoderDidFail:(GeoCoderFailReason)reason;
@end

@class ASIHTTPRequest;

@interface GeoCoder : NSObject {
    ASIHTTPRequest* _cordRequest;
}

@property (nonatomic, assign) id<GeoCoderDelegate> delegate;

- (void) geoCodeSearchString:(NSString*) searchString;
- (void) clearDelegatesAndCancel;


@end
