//
//  DJTransparentTouchView.h
//  Havana
//
//  Created by rob on 23/02/2011.
//  Copyright 2011 Robert Saunders. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 
 This class defines a very small amendment to UIView
 
 
 The idea behind this is that the view itself should not recieve touches 
 unless one of the subviews want it.
 
 This means we should pretend that points are not inside this view unless 
 they are in one of its subviews.  That way the hit test will not land in 
 this view and touches will ge a chance to land in anouther view on the 
 same hirichaical level in a lower z-order.
 
 */

@interface DJTransparentTouchView : UIView {
    
}

@end
