//
//  SearchCoordinator.m
//  LondonBikes
//
//  Created by Robert Saunders on 15/07/2011.
//  Copyright 2011. All rights reserved.
//

#import "SearchCoordinator.h"

@interface SearchCoordinator()
- (void) hideSearch;
@end

@implementation SearchCoordinator



- (id)initWithView:(UIView*) view geoCoderDelegate:(id <GeoCoderDelegate>)geoCoderDelegate {
    self = [super init];
    if (self) {
        _view = [view retain];
        _geoCoderDelegate = geoCoderDelegate;
    }
    return self;
}

- (void)dealloc {
    [_geoCoder release];
    [_view release];
    [_searchBar release];
    [_cancelAreaOverlay release];
    [super dealloc];
}

- (void) releaseViews {
    
    [_searchBar removeFromSuperview];
    [_searchBar release];
    _searchBar = nil;
    
    [_cancelAreaOverlay removeFromSuperview];
    [_cancelAreaOverlay release];
    _cancelAreaOverlay = nil;
}


- (void) cancelAreaOverlayWasTapped:(id)sender {    
    [self hideSearch];
}

#pragma mark - Creating views

- (UIView*) cancelAreaOverlay {
    if (!_cancelAreaOverlay) {
        _cancelAreaOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        _cancelAreaOverlay.backgroundColor = [UIColor blackColor];
        _cancelAreaOverlay.alpha = 0.0;
        
        UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self
                                         action:@selector(cancelAreaOverlayWasTapped:)];
        [_cancelAreaOverlay addGestureRecognizer:tapGR];
        [tapGR release];
        
    }
    return _cancelAreaOverlay;
}

- (UIView*) searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
        _searchBar.tintColor = [UIColor blackColor];
        _searchBar.delegate = self;
    }
    return _searchBar;
}



#pragma Show / Hide Search

- (void) showSearch {
    
    [_view addSubview:[self cancelAreaOverlay]]; 
    [_view addSubview:[self searchBar]];
    
    [_view bringSubviewToFront:[self cancelAreaOverlay]];
    [_view bringSubviewToFront:[self searchBar]];
    
    [[self searchBar] becomeFirstResponder];
    
    [UIView animateWithDuration:0.33 animations:^(void) {
        CGRect rect = [self searchBar].frame;
        rect.origin.y = 0;
        [self searchBar].frame = rect;
        
        [self cancelAreaOverlay].alpha = 0.8;
    }];
    
}


- (void) hideSearch {
    
    [[self searchBar] resignFirstResponder];
    
    [UIView animateWithDuration:0.33 animations:^(void) {
        CGRect rect = [self searchBar].frame;
        rect.origin.y = -44;
        [self searchBar].frame = rect;
        
        [self cancelAreaOverlay].alpha = 0.0;
        
    } completion:^(BOOL finished) {
        [self releaseViews];
    }];
}



#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self hideSearch];
    
    [_geoCoder release];
    _geoCoder = [[GeoCoder alloc] init];
    
    _geoCoder.delegate = _geoCoderDelegate;
    
    
    // We are only interesed in results from the UK
    NSString* appendedSearchString = [searchBar.text stringByAppendingString:@", United Kingdom"];
    
    [_geoCoder geoCodeSearchString:appendedSearchString];
}



@end
