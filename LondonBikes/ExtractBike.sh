#!/bin/bash
echo " "
echo "======================================="
echo "Extract bike started"
echo "======================================="
echo " "

# http://download.geofabrik.de/osm/europe/

# Scrit take aprox 110s
# Intermediate files are saved as biniary file (.pbf) because its quicker
# The finial output is an XML file (bikePaths.osm.xml)


# For multi-line comments
# (Usefull to comment out code if you want ot do this in steps)
comment1 ()
{
  comments go here
}


echo " "
echo "Filtering route = bicycle"
echo "======================================="
# Filter all the relations that have route = bicycle 
sh osmosis \
  --rb british_isles.osm.pbf \
  --tf accept-relations route=bicycle \
  --used-way \
  --used-node \
  --sort \
  --wb output/relation.osm.pbf \


echo " "
echo "Filtering local cycle network tag"
echo "======================================="
# Filter all the ways that have a local cycle network tag
sh osmosis \
  --rb british_isles.osm.pbf \
  --tf reject-relations \
  --tf accept-ways lcn_ref=* \
  --used-node \
  --sort \
  --wb output/lcn.osm.pbf


echo " "
echo "Filtering national cycle network tag"
echo "======================================="
# Filter all the ways that have a regional cycle network tag
# (Save as new result)
sh osmosis \
  --rb british_isles.osm.pbf \
  --tf reject-relations \
  --tf accept-ways ncn_ref=* \
  --used-node \
  --sort \
  --wx output/ncn.osm.xml


echo " "
echo "Filtering cycleway tag"
echo "======================================="
# Filter all the ways that have a cycleway tag that dosnt equal no
sh osmosis \
  --rb british_isles.osm.pbf \
  --tf reject-relations \
  --tf accept-ways cycleway=*  \
  --tf reject-ways cycleway=no \
  --used-node \
  --sort \
  --wb output/cycleway.osm.pbf


echo " "
echo "Merging results"
echo "======================================="
# Merge the results
sh osmosis \
  --rb output/lcn.osm.pbf \
  --rb output/cycleway.osm.pbf \
  --merge \
  --rb output/relation.osm.pbf \
  --merge \
  --wx output/bikePaths.osm.xml


echo " "
echo "Filtering CS 2 tags"
echo "======================================="
# Filter the cycle super highways from the relations file
sh osmosis \
--rb output/relation.osm.pbf \
--tf accept-relations ref=CS2 \
--used-way \
--used-node \
--sort \
--wb output/cs2.osm.pbf \


echo " "
echo "Filtering CS 3 tags"
echo "======================================="
# Filter the cycle super highways from the relations file
sh osmosis \
--rb output/relation.osm.pbf \
--tf accept-relations ref=CS3 \
--used-way \
--used-node \
--sort \
--wb output/cs3.osm.pbf \


echo " "
echo "Filtering CS 7 tags"
echo "======================================="
# Filter the cycle super highways from the relations file
sh osmosis \
--rb output/relation.osm.pbf \
--tf accept-relations ref=CS7 \
--used-way \
--used-node \
--sort \
--wb output/cs7.osm.pbf \


echo " "
echo "Filtering CS 8 tags"
echo "======================================="
# Filter the cycle super highways from the relations file
sh osmosis \
--rb output/relation.osm.pbf \
--tf accept-relations ref=CS8 \
--used-way \
--used-node \
--sort \
--wb output/cs8.osm.pbf \


echo " "
echo "Merging cycle superhighway Tags"
echo "======================================="
# Merge the cycle superhighway results
sh osmosis \
  --rb output/cs2.osm.pbf \
  --rb output/cs3.osm.pbf \
  --merge \
  --rb output/cs7.osm.pbf \
  --merge \
  --rb output/cs8.osm.pbf \
  --merge \
  --wx output/cs.osm.xml
  


echo " "
echo "======================================="
echo "NOTE: CHECK FOR ADDITIONAL CS TAGS"
echo "======================================="

  
echo " "
echo "======================================="
echo "Extract bike finished"
echo "======================================="
echo " "
