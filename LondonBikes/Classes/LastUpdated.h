//
//  LastUpdated.h
//  LondonBikes
//
//  Created by Robert Saunders on 03/07/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LastUpdated : NSObject {
    NSDate* _date;
}

- (NSString*) generateMessage;

- (id)initWithDate:(NSDate*) date;

@end
