#' Find the percent of the population that can be correctly identified at level 2 using only info from level 1
#' 
#' This function takes the raw output of the overlap_dyad_creatr function to calculate, first, the shp1-shp2 dyads with the highest 
#' degree of overlap in order to calculate the proportion of the shp2 polygons' populations that could be correclty identified only
#' using residency of the shp1 residency. Output is a df of each unique shp2 polygon value. 
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
#'    \item correctly_matched_pop = The numeric field of the summed estimated number of people residing between within the overlying area
#'    between the shp1 polygon and the shp2 polygon with the highest degree of overlap, to the shp2 level. 
#'    \item correct_pct = The proportion of the population that can be correctly identified using only shp1 residency.   
#' }
#' @export
#' @examples
#' 
#' zctas <- arealOverlapr::zctas
#' cbg_oh <- arealOverlapr::cbg_oh
#' oh_sen <- arealOverlapr::oh_sen
#' test_overlap <-weight_overlap(shp1 = zctas, shp_atom = cbg_oh, shp2 = oh_sen, pop_field = "POP2010")
#' test_output <- overlap_dyad_creatr(test_overlap, id1="ZCTA5CE10",id2="id", census_fields = c("WHITE","BLACK","MALES"))
#' test_correct <- correct_match_shp2(test_output, "id1", "id2")
#'  )


correct_match_shp2 <- function(overlap_dyad_output, id1, id2){
  ##install pkgs if missing 
  list.of.packages <- c("stringr", "tidyverse")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  
  # Packages loading
  invisible(lapply(list.of.packages, library, character.only = TRUE))
  
  if(("overlap1" %in% names(overlap_dyad_output))==FALSE){
    stop('The overlap1 field from the overlap_dyad_creatr is not present.')
  }
  colnames(overlap_dyad_output)[names(overlap_dyad_output)==id1] <- "id1"
  colnames(overlap_dyad_output)[names(overlap_dyad_output)==id2] <- "id2"
  if(("shp1pop" %in% names(overlap_dyad_output))==FALSE){
    stop('The overlap1 field from the overlap_dyad_creatr is not present.')
  }
  
  
  ##get the shp1 slice with the most overlap 
  matched_df <- overlap_dyad_output %>% group_by(id1) %>% slice(which.max(overlap1))
  matched_df$correctly_matched_pop <- matched_df$overlap1 * 
    matched_df$shp1pop
  pop_sum <- aggregate(matched_df$correctly_matched_pop, list(id2=matched_df$id2), 
                       sum)
  colnames(pop_sum)[2] <- "correctly_matched_pop"
  pop_sum2 <- aggregate(overlap_dyad_output$pop_wt, list(id2=overlap_dyad_output$id2), 
                        sum)
  colnames(pop_sum2)[2] <- "pop_wt"
  pop_sum <- merge(pop_sum, pop_sum2, by = id2)
  pop_sum$correct_pct <- pop_sum$correctly_matched_pop/pop_sum$pop_wt
  return(pop_sum)
  
}
