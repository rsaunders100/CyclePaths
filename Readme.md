Cycle paths
===========

![App screenshot](http://a4.mzstatic.com/us/r1000/110/Purple/d0/cf/33/mzl.pnbiqhlr.320x480-75.jpg)


Displayes cycle paths overlayed on a MKMapView.  The data is from [OpenStreetMaps](http://www.openstreetmap.org/).  Availiable on the [app store](http://itunes.apple.com/gb/app/cycle-paths-for-british-isles/id448049851?mt=8)


Updating Cycle data
--------

To update the cycle path data in the applicaiton 

1. Download british_isles.osm.pbf from [Geofabrik](http://download.geofabrik.de/osm/europe/). ~400MB

2. Get [Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis) - a tool for parsing open map data.

3. Run the script 'ExtracBikes.sh' To cut down the large pbf binary file into XML files containg just cycle data.  Takes aprox 1 hour.

4. Set `TEST_COREDATA` to true in the config.h file:

        #define TEST_COREDATA               TRUE
    
5. Run the app in the simulator.  Takes aprox 1 hour.

6. Copy the generated `LBCoreData.sqlite` file from the Simulator's documents folder to the bundle and change `TEST_COREDATA` back to false.



TODO
----

* Find a faster method of fatching paths from core data, try...
    * Use better hashing.
    * Split request into many subrequests. Update on the fly
    * Split up database.
    * Find a better way to store the data.

* Remore theb magnifinign glass icon or replace with text, e.g. "Zoom in to see more paths".  Some users thought it was a button.

* Implement a system to update cycle path databse from S3.

---------------

*Note: Previously this app was called London bikes, some files are yet to be re-named.*