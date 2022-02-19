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

The first step in order to run the script is to create a three-way dyadic 
