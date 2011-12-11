//
//  BarCoordinator.m
//  LondonBikes
//
//  Created by Robert Saunders on 06/11/2011.
//  Copyright (c) 2011. All rights reserved.
//

#import "BarCoordinator.h"

@interface BarCoordinator()
@property (nonatomic, retain) UIView* bar;
@property (nonatomic, retain) UIImageView* magIcon;
@property (nonatomic, retain) UIProgressView* progBar;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, assign) BarCoordinatorProgresSpeed speed;
@property (nonatomic, assign) BOOL progressBarInUse;
- (void) hideProgressBarIfNotInUse;
@end




@implementation BarCoordinator

@synthesize bar, magIcon, progBar, timer, speed, progressBarInUse;

- (void)dealloc 
{
    [timer invalidate];
    self.timer = nil;
    self.magIcon = nil;
    self.bar = nil;
    self.progBar = nil;
    
    [super dealloc];
}

- (id)initWithBar:(UIView*) barIn;
{
    self = [super init];
    if (self) 
    {    
        self.bar = barIn;
    }
    return self;
}



- (void) startTimer 
{
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.28
                                                  target:self 
                                                selector:@selector(timerDidFire:) 
                                                userInfo:nil
                                                 repeats:YES];
    
}

- (UIProgressView*) progressBar 
{
    if (!progBar) 
    {
        self.progBar = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
        progBar.frame = CGRectMake(100, 14, 130, 33);
        progBar.alpha = 0.7;
        [bar addSubview:progBar];
    }
    
    return progBar;
}

- (UIImageView*) magnificationIcon 
{
    if (!magIcon) 
    {
        self.magIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zoom_in.png"]] autorelease];
        CGRect rect = magIcon.frame;
        rect.origin.x = 252;
        rect.origin.y = 7;
        magIcon.frame = rect;
        [bar addSubview:magIcon];
    }
    return magIcon;
}

- (void) hideMagnificationIcon 
{
    [self magnificationIcon].hidden = YES;
}

- (void) showStrongMagnificationIcon
{
    [self magnificationIcon].hidden = NO;
    [self magnificationIcon].alpha = 1.0;
}

- (void) showWeakMagnificationIcon
{
    [self magnificationIcon].hidden = NO;
    [self magnificationIcon].alpha = 0.5;
}

- (void) startProgressWithSpeed:(BarCoordinatorProgresSpeed)speedIn
{
    self.speed = speedIn;
    [self progressBar].hidden = NO;
    [self progressBar].progress = 0.0;
    [self startTimer];
    
    self.progressBarInUse = YES;
}

- (void) progressFinished
{
    [self.timer invalidate];
    
    self.progBar.progress = 1.0;
    
    self.progressBarInUse = NO;
    
    [self performSelector:@selector(hideProgressBarIfNotInUse) withObject:nil afterDelay:1.0];
}

- (void) cancelProgress 
{
    progBar.hidden = YES;
    self.progressBarInUse = NO;
}

- (void) hideProgressBarIfNotInUse 
{
    if (!progressBarInUse) 
    {
        progBar.hidden = YES;
        progressBarInUse = NO;
    }
}


- (void) timerDidFire:(id) sender 
{
    float currentProgress = [self progressBar].progress;
    
    //    float factor;
    //    
    //    switch (speed) 
    //    {
    //        case BarCoordinatorProgresSpeedSlow:
    //            factor = 0.040;
    //            break;
    //        case BarCoordinatorProgresSpeedMedium:
    //            factor = 0.110;
    //            break;
    //        case BarCoordinatorProgresSpeedFast:
    //            factor = 0.140;
    //            break;
    //        default:
    //            factor = 0.090;
    //            break;
    //    }
    
    float newProgress = currentProgress + (1.0 - currentProgress) * 0.09;
    
    if (newProgress > 0.80) 
    {
        [self.timer invalidate];
    }
    
    [self progressBar].progress = newProgress;
}



@end
