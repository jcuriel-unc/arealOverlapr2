#' Calculate the three-way dyadic population overlap between 2 levels of geography, with an atomic base layer
#' 
#' This function takes the spatialDataframe objects part of the sp pkg and calculates the raw output of the three-way intersection 
#' between two levels of geography of interest, overlaid ontop of an atomic shpfile layer, i.e. census blocks 
#' @param shp1 The imported first shapefile, sp object
#' @param shp_atom The atomic unit of geography shpfile that will be used to calculate the spatial weights by population
#' @param shp2 The imported second shapefile, sp object
#' @param crs1 The CRS projection for the sp object; default set to "+proj=laea +lat_0=10 +lon_0=-81 +ellps=WGS84 +units=m +no_defs"
#' @param crs1 The CRS projection for the sf object transformation; default set to "+init=epsg:2163"
#' @param pop_field The field with the population data, from the shp_atom shp file.  

#' @return The data frame with the dyadic population overlap between the first and second shapefiles. The following are the values:
#'    \itemize{
#'    \item areal_weight = A 0-1 scaled weight of how much the intersection of the three shpfiles consists of a full atomic unit 
#'    \item pop_field = The renamed population field 
#'    \item pop_wt = The Calculated population within the dyad of shp1-atom_shp-shp2 
#' }
#' @export
#' @examples
#' 
#' zctas <- arealOverlapr::zctas
#' cbg_oh <- arealOverlapr::cbg_oh
#' oh_sen <- arealOverlapr::oh_sen
#' test_overlap <-weight_overlap(shp1 = zctas, shp_atom = cbg_oh, shp2 = oh_sen, pop_field = "POP2010")
#'  )

weight_overlap <- function(shp1, shp_atom, shp2, crs1="+proj=laea +lat_0=10 +lon_0=-81 +ellps=WGS84 +units=m +no_defs",
                           crs2="+init=epsg:2163", pop_field){
  
  ##step 0: calc starting time and install missing pkgs 
  t1 <- Sys.time()
  list.of.packages <- c("sp","sf", "areal", "stringr", "rgdal", "rgeos", "raster", "tidyverse")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  ##step 1: project data, and ensure that self intersecting geographies are taken care of, for all three levels of geog. 
  shp1 <- spTransform(shp1, CRS(crs1)) %>%
    gBuffer(byid=T, width=0)
  shp_atom <- spTransform(shp_atom, CRS(crs1)) %>%
    gBuffer(byid=T, width=0)
  shp2 <- spTransform(shp2, CRS(crs1)) %>%
    gBuffer(byid=T, width=0)
  
  
  ##step 2: convert these sp objects into an sf object 
  shp1 <- st_as_sf(shp1)
  shp1 <- st_transform(shp1, crs2)
  shp_atom <- st_as_sf(shp_atom)
  shp_atom <- st_transform(shp_atom, crs2)
  shp2 <- st_as_sf(shp2)
  shp2 <- st_transform(shp2, crs2)
  
  ##step 2.5: calc area for atomic unit 
  shp_atom$area_cb <- st_area(shp_atom)
  
  
  ## step 3: find intersection between shp 1 and shp_atom
  shp1_int <- aw_intersect(shp1, shp_atom, "shp1_atom_area") 
  
  ## step 4: find intersection between shp1int data and shp 2
  shp_all_int <- aw_intersect(shp1_int, shp2, "atomic_area")
  
  ##step 5: calculate the weight 
  shp_all_int$areal_weight <- shp_all_int$atomic_area/shp_all_int$area_cb
  shp_all_int <- as.data.frame(shp_all_int)
  ##step 6: get position of pop field, call it in
  pop_position <- match(pop_field, names(shp_all_int))
  shp_all_int$pop_field <- shp_all_int[, pop_position]
  
  ##step 7: now get the pop, weighted by overlap 
  shp_all_int$pop_wt <- shp_all_int$pop_field*shp_all_int$areal_weight
  
  t2 <- Sys.time()
  print(t2-t1)
  return(shp_all_int)
  
  
}
