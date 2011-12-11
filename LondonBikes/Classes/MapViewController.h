//
//  MapViewController.h
//  LondonBikes
//
//  Created by Robert Saunders on 28/05/2011.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GeoCoder.h"
#import "BarCoordinator.h"

@class DockAccess;
@class LastUpdated;
@class WayOverlayCoordinator;
@class DockAnnotationCoordinator;
@class SearchCoordinator;

@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, GeoCoderDelegate > {
    
    MKMapView* _mapView;
    NSManagedObjectContext* _context;
    
    WayOverlayCoordinator* _wayOverlayCoordinator;
    SearchCoordinator* _searchCoordinator;
}

@property (retain, nonatomic) IBOutlet UIView *topBar;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSManagedObjectContext* context;
@property (nonatomic, retain) BarCoordinator* barCoordinator;

- (IBAction)didTapSearch:(id)sender;
- (IBAction)didTapLocateMe:(id)sender;
- (IBAction)didSelectInfo:(id)sender;

- (void) applicationDidEnterBackground;
- (void) applicationWillEnterForeground;


@end

