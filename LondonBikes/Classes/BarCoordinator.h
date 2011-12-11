//
//  BarCoordinator.h
//  LondonBikes
//
//  Created by Robert Saunders on 06/11/2011.
//  Copyright (c) 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum 
{
    BarCoordinatorProgresSpeedSlow,
    BarCoordinatorProgresSpeedMedium,
    BarCoordinatorProgresSpeedFast
    
} BarCoordinatorProgresSpeed;

@interface BarCoordinator : NSObject 

- (id)initWithBar:(UIView*) bar;


- (void) hideMagnificationIcon;
- (void) showStrongMagnificationIcon;
- (void) showWeakMagnificationIcon;

- (void) startProgressWithSpeed:(BarCoordinatorProgresSpeed)speed;
- (void) progressFinished;
- (void) cancelProgress;


@end
