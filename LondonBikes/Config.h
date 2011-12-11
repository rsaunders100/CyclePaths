//
//  Config.h
//  LondonBikes
//
//  Created by Robert Saunders on 28/05/2011.
//  Copyright 2011. All rights reserved.
//

// If true will run some test to check core data functionaity on startup
#define TEST_COREDATA               FALSE

// If ture will pase the given XML files on startup and save the result in core data.
#define PARSE_OSM_XML               FALSE

// Loging
#define LOG_BIKEAPI             FALSE
#define LOG_MAP_ROUTE_MANAGMENT FALSE
#define LOG_GEOCODING           FALSE
#define LOG_LOCATION            FALSE

// Enumerations
#define kWAY_TYPE_NONE                 0
#define kWAY_TYPE_CYCLESUPERHIGHWAY    1
#define kWAY_TYPE_NATIONAL_CYCLE_PATH  2

// Scale factors for stroing latitude and longitude as intergers
#define kLATLON_ENCODE_FACTOR ( ((double)0x7FFFFFFF) / 180.0)
#define kLATLON_DECODE_FACTOR (180.0 / ((double)0x7FFFFFFF) )

// Factor used for tile hashing
#define TWO_POW_Z 4096


// Zoom Levels for different behaviour
// e.g. for more detailed paths to show up 
#define kZOOM_LEVEL_LAT_DELTA_MIN_REGIONAL_PATHS   0.42
#define kZOOM_LEVEL_LAT_DELTA_MIN_ALL_PATHS        0.12
#define kZOOM_LEVEL_LAT_DELTA_MIN_SHORT_TIMER      0.07
#define kZOOM_LEVEL_LAT_DELTA_MIN_NO_TIMER         0.03





