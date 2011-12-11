//
//  InfoViewController.m
//  LondonBikes
//
//  Created by Robert Saunders on 25/06/2011.
//  Copyright 2011. All rights reserved.
//

#import "InfoViewController.h"


@implementation InfoViewController
@synthesize scrollView;
@synthesize keyView;
@synthesize aboutView;


- (void)dealloc
{
    [scrollView release];
    [keyView release];
    [aboutView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void) showView:(UIView*)view 
{
    for (UIView* subView in scrollView.subviews) 
    {
        [subView removeFromSuperview];
    }
    
    [scrollView addSubview:view];
    [scrollView setContentSize:view.frame.size];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showView:keyView];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setKeyView:nil];
    [self setAboutView:nil];
    [super viewDidUnload];
}

- (IBAction) didTapDone:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) segmentChanged:(id)sender 
{
    UISegmentedControl* control = (UISegmentedControl*) sender;
    
    if (control.selectedSegmentIndex == 0) 
    {   
        [self showView:keyView];
    }
    else 
    {
        [self showView:aboutView];
    }
}



@end
