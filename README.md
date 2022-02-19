# arealOverlapr

The arealOverlapr package is designed to read in shapefiles and find their population weighted overlap. To use, please use the following code: 

## Install 

devtools::install_github("https://github.com/jcuriel-unc/arealOverlapr2",subdir="arealOverlapr")
library(arealOverlapr)

## Requirements 

In order to run the package, three shapefiles are necessary. Two of these shapefiles consist of the goegraphies that the user is interested in finding the overlap between. The third consists of the atomic level Census geography. This should consist of a precise level of geography on par with Census blocks or block groups within the U.S. These shall act as a grid that informs the overlay between two actual shapefiles of interest.  

## Creating the spatial dyadic matrix 

The first step in order to run the script is to create a three-way dyadic 
