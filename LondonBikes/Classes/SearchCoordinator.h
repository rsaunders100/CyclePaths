//
//  SearchCoordinator.h
//  LondonBikes
//
//  Created by Robert Saunders on 15/07/2011.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoCoder.h"

@interface SearchCoordinator : NSObject <UISearchBarDelegate> {

    UIView* _view;
    id <GeoCoderDelegate> _geoCoderDelegate;
    
    UISearchBar* _searchBar;
    UIView* _cancelAreaOverlay;
    GeoCoder* _geoCoder;
}

- (id)initWithView:(UIView*) view geoCoderDelegate:(id <GeoCoderDelegate>)geoCoderDelegate;

- (void) showSearch;

@end
