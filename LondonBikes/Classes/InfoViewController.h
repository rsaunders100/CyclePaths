//
//  InfoViewController.h
//  LondonBikes
//
//  Created by Robert Saunders on 25/06/2011.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfoViewController : UIViewController 


@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *keyView;
@property (retain, nonatomic) IBOutlet UIView *aboutView;

- (IBAction) segmentChanged:(id)sender;
- (IBAction) didTapDone:(id)sender;

@end
