#' Calculate the herfindahl index of the first level of geography
#' 
#' This function takes the raw output of the weight_overlap function (also part of the arealOverlapr pkg), and calculates the 
#' population overlap between two levels of geography, and the demographic information of interest from census data. 
#' @param overlap_dyad_output The outputted data frame from the overlap_dyad_creatr function
#' @param shp_atom The atomic unit of geography shpfile that will be used to calculate the spatial weights by population
#' @param id1 The ID field (chr) from the first shpfile of interest. 
#' @param id2 The ID field (chr) from the second shpfile of interest.
#' @param census_fields The string vector of other population fields of interest referring to census data that should be caclulated, 
#' which amounts to the raw weighted number of the individuals part of the demographic in question residing within the overlap of the 
#' two shpfile polygons of interest 

#' @return The data frame with the dyadic population overlap between the first and second shapefiles. The following are the values:
#'    \itemize{
#'    \item id1 = The renamed id field from the first shpfile 
#'    \item herf_index = The Herfindahl index, a measure of the diversity of shp2 units within the shp1 file. The scale ranges from 0
#'    for complete heterogeneity and division across shp2 polygons, and 1 for complete homogeneity and nestedness within a single 
#'    shp2 polygon.  
#'    \item eff_num = The effective number of shp2 polygonal units within the shp1 polygons. This is the inverse of the Herfindahl
#'    index.  
#' }
#' @export
#' @examples
#' 
#' zctas <- arealOverlapr::zctas
#' cbg_oh <- arealOverlapr::cbg_oh
#' oh_sen <- arealOverlapr::oh_sen
#' test_overlap <-weight_overlap(shp1 = zctas, shp_atom = cbg_oh, shp2 = oh_sen, pop_field = "POP2010")
#' test_output <- overlap_dyad_creatr(test_overlap, id1="ZCTA5CE10",id2="id", census_fields = c("WHITE","BLACK","MALES"))
#' test_herf <- herfindahl_new(test_output,"pop_wt",  "id1")
#'  )



herfindahl_new <- function(overlap_dyad_output, pop_field, id1){
  ##step 0: rename fields 
  colnames(overlap_dyad_output)[names(overlap_dyad_output)==pop_field] <- "pop_wt"
  colnames(overlap_dyad_output)[names(overlap_dyad_output)==id1] <- "id1"
  
  ##step 1: get pop summarized by shp1
  overlap_dyad_output <- overlap_dyad_output %>%
    group_by(id1) %>%
    mutate(pop_shp1=sum(pop_wt))
  
  ##step 2: get proportions for dyad, squared 
  overlap_dyad_output$dyad_prop_shp2 <- (overlap_dyad_output$pop_wt/overlap_dyad_output$pop_shp1)^2
  
  ##step 3: summarise and get herfindahl index by zip code 
  shp1_herfindahl <- aggregate(overlap_dyad_output$dyad_prop_shp2, list(id1=overlap_dyad_output$id1), FUN="sum")
  
  ##rename second col 
  colnames(shp1_herfindahl)[2] <- "herf_index"
  
  
  ##step 4: Get the effective number 
  shp1_herfindahl$eff_num <- 1/shp1_herfindahl$herf_index
  return(shp1_herfindahl)
  
  
}
