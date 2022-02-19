#' Summarise the dyadic population overlap between 2 levels of geography
#' 
#' This function takes the raw output of the weight_overlap function (also part of the arealOverlapr pkg), and calculates the 
#' population overlap between two levels of geography, and the demographic information of interest from census data. 
#' @param weight_output The outputted data frame from the weight_overlap function
#' @param shp_atom The atomic unit of geography shpfile that will be used to calculate the spatial weights by population
#' @param id1 The ID field (chr) from the first shpfile of interest. 
#' @param id2 The ID field (chr) from the second shpfile of interest.
#' @param census_fields The string vector of other population fields of interest referring to census data that should be caclulated, 
#' which amounts to the raw weighted number of the individuals part of the demographic in question residing within the overlap of the 
#' two shpfile polygons of interest 

#' @return The data frame with the dyadic population overlap between the first and second shapefiles. The following are the values:
#'    \itemize{
#'    \item id1 = The renamed id field from the first shpfile 
#'    \item id2 = The renamed id field from the second shpfile 
#'    \item pop_wt = The summed weighted population estimated to reside between the two shpfiles of interest 
#'    \item census_fields_wt = The vector of census fields with "_wt" pasted to reflect the population estimated from the chosen 
#'    census fields. 
#'    \item shp1pop = The total estimated population residing within the first level of geography
#'    \item overlap1 = The degree of nestedness of the first level of geography within the second level, 0 - 1.  
#' }
#' @export
#' @examples
#' 
#' zctas <- arealOverlapr::zctas
#' cbg_oh <- arealOverlapr::cbg_oh
#' oh_sen <- arealOverlapr::oh_sen
#' test_overlap <-weight_overlap(shp1 = zctas, shp_atom = cbg_oh, shp2 = oh_sen, pop_field = "POP2010")
#' test_output <- overlap_dyad_creatr(test_overlap, id1="ZCTA5CE10",id2="id", census_fields = c("WHITE","BLACK","MALES"))
#'  )



overlap_dyad_creatr <- function(weight_output, id1, id2, census_fields){
  ##install pkgs if missing 
  list.of.packages <- c("stringr", "tidyverse")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  
  # Packages loading
  invisible(lapply(list.of.packages, library, character.only = TRUE))
  
  ##Step 1; calculate and weight the census fields of interest 
  if (missing(census_fields) == FALSE) {
    temp_var_name <- paste(census_fields, "wt", sep = "_")
    var_position <- match(census_fields, names(weight_output))
    for (i in 1:length(census_fields)) {
      weight_output$temp_name <- weight_output[, var_position[i]] * 
        weight_output$areal_weight
      colnames(weight_output)[colnames(weight_output) == "temp_name"] <- temp_var_name[i]
    }
    var_position2 <- match(temp_var_name, names(weight_output))
    print(temp_var_name)
  }
  ##step 2: subset the data by relevant fields 
  weight_output <- weight_output[,c(id1,id2,"pop_wt",temp_var_name)]
  
  ##step 2.5: rename id fields 
  
  colnames(weight_output)[names(weight_output)==id1] <- "id1"
  colnames(weight_output)[names(weight_output)==id2] <- "id2"
  
  ##step3: get dyad field 
  weight_output$dyad_id <- paste0(weight_output$id1,sep="_",weight_output$id2)
  
  ##step 3: aggregate the data to dyad level 
  overlap_dyad <- aggregate(.~id1+id2+dyad_id,weight_output, sum )
  
  ##step4: get overlap 
  overlap_dyad <- overlap_dyad %>%
    group_by(id1) %>%
    mutate(shp1pop=sum(pop_wt))
  
  overlap_dyad$overlap1 <- overlap_dyad$pop_wt/overlap_dyad$shp1pop
  overlap_dyad <- as.data.frame(overlap_dyad)
  ##get second shp pop
  overlap_dyad <- overlap_dyad %>%
    group_by(id2) %>%
    mutate(shp2pop=sum(pop_wt))
  overlap_dyad <- as.data.frame(overlap_dyad)
  
  
  return(overlap_dyad)
  
}
