# arealOverlapr

The arealOverlapr package is designed to read in shapefiles and find their population weighted overlap. To use, please use the following code: 

## Install 

devtools::install_github("https://github.com/jcuriel-unc/arealOverlapr2",subdir="arealOverlapr")
library(arealOverlapr)

## Requirements 

In order to run the package, three shapefiles are necessary. Two of these shapefiles consist of the goegraphies that the user is interested in finding the overlap between. The third consists of the atomic level Census geography. This should consist of a precise level of geography on par with Census blocks or block groups within the U.S. These shall act as a grid that informs the overlay between two actual shapefiles of interest. 

![Example](pop_overlap_example.png)

In the Figure above, we see how these shapefiles work together. Where the atomic file acts as a grid with weights associated with each grid unit, G1i reflects a polygon from the first shapefile, and G2i a polygon from the second shapefile. When a grid unit from the atomic file is not completely nested within the intersecting area between the two shapefiles of interest, only then is geographic overlap used to allocate the population information. The arealOverlapr process works by minimizing the degree to which geographic overlap and associated assumptions are employed to find the degree of similarity between two shapefiles. 

## Creating the spatial dyadic matrix 

The first step in order to run the script is to create a three-way dyadic overlap between the three shapefiles of interest. Within the package, this is done via the "weight_overlap" command. The command accepts the following arguments of shp1, shp_atom, shp2, crs1, crs2, and pop_field.

weight_overlap(
  shp1,
  shp_atom,
  shp2,
  crs1 = "+proj=laea +lat_0=10 +lon_0=-81 +ellps=WGS84 +units=m +no_defs",
  crs2 = "+init=epsg:2163",
  pop_field
)

shp1: Shapefile 1, of a SpatialPolygonsDataFrame object (sp)
shp2: Shapefile 2, of a SpatialPolygonsDataFrame object (sp)
shp_atom: Atomic grid shapefile, usually (and recommended) to be Census in origin; SpatialPolygonsDataFrame object (sp)
crs1: The projection for the files to be transformed into. Defaults if no user change made. 
crs2: To be added in; projection modification if need arises; currently not implemented. 
pop_field: The name of the field within the atomic spatail dataframe reflecting the population of each unit; must be in quotation marks. 

Example: 

zctas <- arealOverlapr::zctas #shapefile 1
cbg_oh <- arealOverlapr::cbg_oh#atomic level shapefile to act as grid 
oh_sen <- arealOverlapr::oh_sen#shapefile 2
test_overlap <-weight_overlap(shp1 = zctas, shp_atom = cbg_oh, shp2 = oh_sen, pop_field = "POP2010")
)

Upon running the weight_overlap command, the user will have a raw output of data frames from all three spatial dataframes merged together, in addition to the three-way intersection calculated. This output takes the form of a base R data frame. To clean the rest, the user must make use of the overlap_dyad_creatr, which cleans up the output of the previous command. The output of this command shall be the dyadic overlap and associated information between the first and second shapefiles alone. 

overlap_dyad_creatr(weight_output, id1, id2, census_fields)

weight_output: The output of the weight_overlap command, data.frame class. 
id1: The unique string/character ID from shapefile 1. 
id2: The unique string/character ID from shapefile 2. 
census_fields: Census fields from the atomic shapefile that should be aggregated to the level of shp1-shp2 dyads. 

Example: 
test_output <- overlap_dyad_creatr(test_overlap, id1="ZCTA5CE10",id2="id", census_fields = c("WHITE","BLACK","MALES"))
)

The outputted data frame is below. 


![Example2](example_overlap_output.jpg)
