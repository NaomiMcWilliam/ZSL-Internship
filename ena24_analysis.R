library(jsonlite)
library(rjson)
library(tidyverse)
library(glue)

data <- fromJSON(file = "../ENA24/ena24_metadata.json")

#image id, category id, bounding box
data_annotations <-  data$annotations

#image id, image file name, image width, image height
data_images <- data$images

#name of animal, photo id
data_categories <- data$categories
colnames(data_categories)[2] <- "category_id"

animal_df <- merge(data_annotations, data_categories, by="category_id")

md_data <- fromJSON(file = "../ENA24/ena24.json")
md_data_images <- md_data$images

md_id <- vector()
md_category_id <- vector()
for (i in 1:length(md_data_images)){
       md_id[i] <- str_sub(md_data_images[[i]]$file, 14, str_length(md_data_images[[i]]$file))
       md_category_id[i] <- md_data_images[[i]]$detections[[1]]$category
       tryCatch({md_category_id[i] <- md_data_images[[i]]$detections[[1]]$category}
                , error = function(e) {md_category_id[[i]]<-"0"} )
}

md_data_categories <- md_data$detection_categories
md_data_info <- md_data$info



dataB <- dataA[, c("P1", "xyz", "acdc")]


directory_csv <- str_sub(directory_csv,20,str_length(directory_csv))