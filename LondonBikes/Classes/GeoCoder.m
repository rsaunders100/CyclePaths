//
//  GeoCoder.m
//  LondonBikes
//
//  Created by Robert Saunders on 21/06/2011.
//  Copyright 2011. All rights reserved.
//

#import "GeoCoder.h"
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "SBJSON.h"

@interface GeoCoder ()

// Google geo location
- (void) googleGeoCodeRequestFinished:(ASIHTTPRequest*) request;
- (void) googleGeoCodeRequestFailed:(ASIHTTPRequest*) request;

@end


@implementation GeoCoder

@synthesize delegate;


- (void)dealloc {
    [_cordRequest release];
    [super dealloc];
}

- (void) geoCodeSearchString:(NSString*) searchString {    
    
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (searchString && [searchString length] > 1) 
	{		
		NSString *searchStringFormatted = [searchString 
                                           stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		
        NSString* requestString = [NSString stringWithFormat:
                                   @"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true&region=uk",
                                   searchStringFormatted];
        
        [_cordRequest clearDelegatesAndCancel];
        [_cordRequest release];
		_cordRequest = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestString]] retain];
		
		// Log the request URL
#if LOG_GEOCODING
		NSLog(@"GOOGLE API REQUEST: %@", _cordRequest.url);
#endif
		
		_cordRequest.delegate = self;
        [_cordRequest setDidFinishSelector:@selector(googleGeoCodeRequestFinished:)];
        [_cordRequest setDidFailSelector:@selector(googleGeoCodeRequestFailed:)];
        
		[_cordRequest startAsynchronous];
	}
}


- (void) googleGeoCodeRequestFinished:(ASIHTTPRequest*) request 
{
    NSString *repsonseString = [request responseString];
	
#if LOG_GEOCODING
	NSLog(@"GOOGLE API RESPONSE: %@",repsonseString);
#endif
    
	if (repsonseString)
	{
		SBJsonParser *jParser = [[[SBJsonParser alloc] init] autorelease];
		NSDictionary *dict = [jParser objectWithString:repsonseString];
		
		if (dict)
		{
			NSArray* reuslts = [dict objectForKey:@"results"];
			
			if ([reuslts count] > 0)
			{
				NSDictionary *results = [reuslts objectAtIndex:0];
				
				if (results)
				{
                    NSDictionary* geometry = [results objectForKey:@"geometry"];
                    
                    
					NSDictionary* location = [geometry objectForKey:@"location"];
                    NSDictionary* viewport = [geometry objectForKey:@"viewport"];
                    NSDictionary* northeast = [viewport objectForKey:@"northeast"]; 
                    NSDictionary* southwest = [viewport objectForKey:@"southwest"]; 
                    
					double lat = [[location objectForKey:@"lat"] doubleValue];
					double lon = [[location objectForKey:@"lng"] doubleValue];
					
                    double northeastLat = [[northeast objectForKey:@"lat"] doubleValue];
                    double northeastLon = [[northeast objectForKey:@"lng"] doubleValue];
                    
                    double southwestLat = [[southwest objectForKey:@"lat"] doubleValue];
                    double southwestLon = [[southwest objectForKey:@"lng"] doubleValue];
                    
                    double latSpan = fabs(southwestLat - northeastLat);
                    double lonSpan = fabs(southwestLon - northeastLon);
                    
					if (lat && lon && latSpan && lonSpan)
					{   
                        CLLocationCoordinate2D foundLocation;
                        foundLocation.latitude = lat;
                        foundLocation.longitude = lon;
                        
                        MKCoordinateSpan foundSpan = MKCoordinateSpanMake(latSpan, lonSpan);
                        MKCoordinateRegion foundRegion = MKCoordinateRegionMake(foundLocation, foundSpan);
                        
						if ([self.delegate respondsToSelector:@selector(geoCoderDidReturnSearchRegion:)]) 
                        {
                            [self.delegate geoCoderDidReturnSearchRegion:foundRegion];
                        }
					}
				}
			}
		}
	}
}


- (void) googleGeoCodeRequestFailed:(ASIHTTPRequest*) request 
{
    
#if LOG_GEOCODING
	NSLog(@"GOOGLE API FAILED: %@",[request error]);
#endif
    
    // TODO check request for error type    
    if ([self.delegate respondsToSelector:@selector(geoCoderDidReturnSearchRegion:)]) 
    {
        [self.delegate geoCoderDidFail:GeoCoderFailReasonConnection];
    }
}


- (void) clearDelegatesAndCancel {
    [_cordRequest clearDelegatesAndCancel];
    self.delegate = nil;
}


@end
