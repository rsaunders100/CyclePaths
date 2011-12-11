//
//  MapViewController.m
//  LondonBikes
//
//  Created by Robert Saunders on 28/05/2011.
//  Copyright 2011. All rights reserved.
//

#import "Config.h"

#import "MapViewController.h"
#import "WayPolyline.h"

#import "CoreDataHelper.h"
#import "InfoViewController.h"

#import "WayOverlayCoordinator.h"
#import "SearchCoordinator.h"

#import "MapStateHelper.h"


@interface MapViewController()

- (MKMapRect) mapRectForUpdating;

- (WayOverlayCoordinator*) wayOverlayCoordinator;
- (SearchCoordinator*) searchCoordinator;

@end


@implementation MapViewController

@synthesize topBar = _topBar;
@synthesize mapView = _mapView;
@synthesize context = _context;
@synthesize barCoordinator;

- (void)dealloc
{
    [_context release];
    [_mapView release];
    
    [_wayOverlayCoordinator release];
    [_searchCoordinator release];
    
    [_topBar release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void) loadWays:(id)sender 
{    
    [[self wayOverlayCoordinator] loadWaysIntoMapViewContext:self.context];
}


- (void) viewDidAppear:(BOOL)animated 
{    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenStartupAlert"]) 
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Welcome!"
                                                        message:@"Zoom in to see the cyclepaths.\n\nSome paths will take a little while to load." 
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:@"hasSeenStartupAlert"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void) viewDidDisappear:(BOOL)animated 
{
    
}


- (void) applicationDidEnterBackground 
{    
    // Save the current map region
    if (_mapView) 
    {
        [MapStateHelper saveMapRegionToDisk:_mapView.region];
    }
    
    // This will dump all the overlays
    [[self wayOverlayCoordinator] applicationDidEnterBackground];
}

- (void) applicationWillEnterForeground 
{    
    [NSTimer scheduledTimerWithTimeInterval:0.9 
                                     target:self 
                                   selector:@selector(loadWays:) 
                                   userInfo:nil 
                                    repeats:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.barCoordinator = [[[BarCoordinator alloc] initWithBar:self.topBar] autorelease];
    
    // Load the map region from file.
    // If we get back a good region use it,
    // otherwise zoom to an overview of the UK
    
    MKCoordinateRegion region = [MapStateHelper loadMapRegionFromDisk];
    if (region.span.latitudeDelta != 0.0) 
    {
        [self.mapView setRegion:region
                       animated:NO];
    }
    else 
    {
        // Default zoom to UK
        CLLocationCoordinate2D location;
        location.latitude = 54.81756;
        location.longitude = -3.06287;
        MKCoordinateSpan span = MKCoordinateSpanMake(10.39634, 12.53484);
        MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
        [self.mapView setRegion:region
                       animated:NO];
    }
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setTopBar:nil];
    [super viewDidUnload];
}



#pragma mark - MapViewDelegate


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
        
    WayPolyline* wayPolyLine = (WayPolyline*) overlay;
    MKPolylineView* view = [[MKPolylineView alloc] initWithPolyline:overlay];
    
    if (wayPolyLine.type == kWAY_TYPE_CYCLESUPERHIGHWAY) 
    {
        view.strokeColor = [UIColor blueColor];
        view.lineWidth = 6.4;
    }
    else if (wayPolyLine.type == kWAY_TYPE_NATIONAL_CYCLE_PATH) 
    {
        view.strokeColor = [UIColor redColor];
        view.lineWidth = 5.4;
    }
    else 
    {
        view.strokeColor = [UIColor colorWithRed:0.30 green:0.60 blue:1.0 alpha:1.0]; 
        view.lineWidth = 3.8;
    }
    
    return [view autorelease];
}


- (MKMapRect) mapRectForUpdating {
    
    double factor = 0.25;
    
    MKMapRect rect = [_mapView visibleMapRect];
    
    rect.size.width  *= (1 + 2 * factor);
    rect.size.height *= (1 + 2 * factor);
    
    rect.origin.x = rect.origin.x - (factor * rect.size.width * 0.5);
    rect.origin.y = rect.origin.y - (factor * rect.size.height * 0.5);
    
    return rect;
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated 
{    
    [[self wayOverlayCoordinator] loadWaysIntoMapViewContext:self.context];
}


#pragma mark - Button events

- (IBAction)didTapSearch:(id)sender {
    [[self searchCoordinator] showSearch];
}


- (IBAction)didTapLocateMe:(id)sender {

    if (_mapView.userLocation.location.horizontalAccuracy != 0.0 ||
        _mapView.userLocation.location.horizontalAccuracy > 4000) 
    {
        
        MKCoordinateRegion mapRegion;
		mapRegion.center = self.mapView.userLocation.location.coordinate;
		mapRegion.span.latitudeDelta = 0.014;
		mapRegion.span.longitudeDelta = 0.014;
		[self.mapView setRegion:mapRegion animated:YES];
    }    
}

- (IBAction)didSelectInfo:(id)sender {
    
    InfoViewController* infoVC = [[InfoViewController alloc] 
                                  initWithNibName:@"InfoViewController"
                                  bundle:nil];
    infoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:infoVC animated:YES];
    [infoVC release];
}

#pragma mark - GeoCoderDelegate

- (void) geoCoderDidReturnSearchRegion:(MKCoordinateRegion) region 
{    
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Helper Classes




- (WayOverlayCoordinator*) wayOverlayCoordinator {
    
    if (!_wayOverlayCoordinator) {
        _wayOverlayCoordinator = [[WayOverlayCoordinator alloc] initWithMapView:_mapView];
        _wayOverlayCoordinator.mapViewController = self;
    }
    return _wayOverlayCoordinator;
}


- (SearchCoordinator*) searchCoordinator {
    
    if (!_searchCoordinator) {
        _searchCoordinator = [[SearchCoordinator alloc] initWithView:self.view
                                                    geoCoderDelegate:self];
    }
    return _searchCoordinator;
}



@end


