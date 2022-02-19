#' Find the crosswalk between the shp1 and shp2 polygons based on highest overlap. 
#' 
#' This function takes the raw output of the overlap_dyad_creatr function (also part of the arealOverlapr pkg), and calculates slices the 
#' data to single unique values for the shp1 file. Observations are cut to the unique shp1 values for where the overlap between the 
#' two is maximized for a given grouping of dyadic data. 
#' 
#' @param overlap_dyad_output The outputted data frame from the overlap_dyad_creatr function
#' @param id1 The ID field (chr) from the first shpfile of interest. 
#' @param id2 The ID field (chr) from the second shpfile of interest.
#' @param census_fields The string vector of other population fields of interest referring to census data that should be caclulated, 
#' which amounts to the raw weighted number of the individuals part of the demographic in question residing within the overlap of the 
#' two shpfile polygons of interest 

#' @return The data frame with the dyadic population overlap between the first and second shapefiles. The following are the values:
#'    \itemize{
#'    \item id1 = The renamed id field from the first shpfile 
#'    \item id2 = The renamed id field from the second shpfile 
#'    \item correctly_matched_pop = The numeric field of the estimated number of people residing between within the overlying area
#'    between the shp1 polygon and the shp2 polygon with the highest degree of overlap.  
#' }
#' @export
#' @examples
#' 
#' zctas <- arealOverlapr::zctas
#' cbg_oh <- arealOverlapr::cbg_oh
#' oh_sen <- arealOverlapr::oh_sen
#' test_overlap <-weight_overlap(shp1 = zctas, shp_atom = cbg_oh, shp2 = oh_sen, pop_field = "POP2010")
#' test_output <- overlap_dyad_creatr(test_overlap, id1="ZCTA5CE10",id2="id", census_fields = c("WHITE","BLACK","MALES"))
#' test_best <- best_match_new(test_output, "id1")
#'  )


best_match_new <- function(overlap_dyad_output, id1){
  ##install pkgs if missing 
  list.of.packages <- c("stringr", "tidyverse")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  # Packages loading
  invisible(lapply(list.of.packages, library, character.only = TRUE))
  ##check if fields present 
  if(("overlap1" %in% names(overlap_dyad_output))==FALSE){
    stop('The overlap1 field from the overlap_dyad_creatr is not present.')
  }
  
  ##rename field 
  colnames(overlap_dyad_output)[names(overlap_dyad_output)=="id1"] <- "id1"
  matched_df <- overlap_dyad_output %>%
    group_by(id1) %>%
    slice(which.max(overlap1))
  matched_df <- as.data.frame(matched_df)
  matched_df$correctly_matched_pop <- matched_df$overlap1*matched_df$shp1pop
  return(matched_df)
  
}
