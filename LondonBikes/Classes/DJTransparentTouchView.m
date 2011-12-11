//
//  DJTransparentTouchView.m
//  Havana
//
//  Created by rob on 23/02/2011.
//  Copyright 2011 Robert Saunders. All rights reserved.
//

#import "DJTransparentTouchView.h"


@implementation DJTransparentTouchView



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Only return YES if the touch is in one of the subviews 
    //   - we dont care about touches that are just in this view
    
    for (UIView* view in self.subviews) {
        
        // We need to convert the point into the recievers co-ordinate system
        // (as per the documentation on 'pointInside:withEvent')
                
        CGPoint convertedPoint = [self convertPoint:point toView:view];
        
        if ([view pointInside:convertedPoint withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

@end
