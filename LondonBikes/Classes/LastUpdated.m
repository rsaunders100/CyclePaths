//
//  LastUpdated.m
//  LondonBikes
//
//  Created by Robert Saunders on 03/07/2011.
//  Copyright 2011. All rights reserved.
//

#import "LastUpdated.h"


@implementation LastUpdated

- (id)initWithDate:(NSDate*) date {
    self = [super init];
    if (self) {
        _date = [date retain];
    }
    return self;
}

- (NSString*) generateMessage {
    
    NSTimeInterval secondsSinceUpdate = -[_date timeIntervalSinceNow];
    
    if (secondsSinceUpdate < 75) {
        return nil;
    } else {
        
        int mins = (int) floor(secondsSinceUpdate / 60.0);
        
        if (mins == 1) {
            return @"as of 1 min ago";
        } else {
            return [NSString stringWithFormat:@"as of %d mins ago",mins];
        }
    }
}


- (void)dealloc {
    [_date release];
    [super dealloc];
}

@end
