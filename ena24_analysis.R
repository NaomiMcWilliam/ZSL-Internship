library(jsonlite)
library(rjson)
library(tidyverse)
library(glue)

data <- fromJSON(file = "../ENA24/ena24_metadata.json")
#there are 9676 images in total in the dataset
#some of these have humans in, and have been emitted from the images
#so the metadata does not match up with the megadetector, as there are less images
#analysed by the megadetector, ones with humans in have been omitted


#MANUAL CLASSIFICATIONS

data <- fromJSON( file = "../ENA24/ena24_metadata.json")

#DATA ANNOTATIONS
#image id, category id, bounding box
data_annotations <-  as.data.frame(do.call(rbind, data$annotations))
data_annotations$id <- unlist(data_annotations$id)
data_annotations$image_id <- unlist(data_annotations$image_id)
data_annotations$category_id <- unlist(data_annotations$category_id)
#data_annotations$bbox <- unlist(data_annotations$bbox)

#DATA IMAGES
#image id, image file name, image width, image height
data_images <- as.data.frame(do.call(rbind, data$images))

#DATA CATEGORIES
#name of animal, image id
data_categories <- as.data.frame(do.call(rbind, data$categories))
colnames(data_categories)[2] <- "category_id"
colnames(data_categories)[1] <-"Classification_manual"
data_categories$Classification_manual <- unlist(data_categories$Classification_manual)
data_categories$category_id <- unlist(data_categories$category_id)

total_df <- merge(data_annotations, data_categories, by="category_id")
manual_df <- total_df[,c("image_id", "Classification_manual", "bbox")]

#issue is that it has a few rows for the same image, so in comparisons they may not be comparing the same thing ..? 
#need to look at every bounding box for each image, and see if megadetector also predicts something in roughly that box, and if it is the same thing







#MEGADETECTOR CLASSIFICATIONS
md_data <- fromJSON(file = "../ENA24/ena24.json")
#md_data_images <- as.data.frame(do.call(rbind, md_data$images))

#finding the images which have humans in so were not included in the images
md_images <- vector()
for (i in 1:length(md_data$images)){
        md_images[i] <- str_sub(md_data$images[[i]]$file, 14, str_length(md_data$images[[i]]$file)-4)    
}
notinc <- vector()
m <- 1
for (j in 1:9676){
        if (!(j %in% strtoi(md_images))){
                notinc[m] <- j
                m <- m+1
        }
}



#makes a vector containing image id's, confidence levels, category id, bounding box
#need to make sure it includes all the detections
image_id <- vector()
conf <- vector()
Category_id_md <- vector()
bbox_md <- list()
#i is index for original lists
j<-1 #index for new lists (larger than i as sometimes there are 2 birds in one image etc.)
#k is index for detections in one image
#using json file rather than the data frames


for (i in 1:length(md_images)){
                
                #empty image, no detections
                if (length(md_data$images[[i]]$detections)==0){
                        image_id[j] <- md_images[i]
                        conf[j] <- md_data$images[[i]]$max_detection_conf    #this will be 0, no confidence in any detections
                        Category_id_md[j] <- "0"                                #empty
                        bbox_md[[j]] <- c(0,0,0,0)               #empty
                        j<-j+1    #increment, not going in for loop
                        
                }else{ 
                        #increment the next detection (there is 1,2,3 etc.)
                        for (k in 1:length(md_data$images[[i]]$detections)) {
                                image_id[j] <- md_images[i]
                                #detections
                                conf[j] <- md_data$images[[i]]$detections[[k]]$conf
                                Category_id_md[j]<-md_data$images[[i]]$detections[[k]]$category
                                bbox_md[[j]] <- c(md_data$images[[i]]$detections[[k]]$bbox)
                                
                                j <- j+1     #increment to next index in new lists for new detections
                                
                        }
                        
                }
}

Category_id_md_initial <- Category_id_md  #includes category before confidence has been considered
#data frame for the images, includes confidence column and the bounding box
md_image_df_conf <- data.frame(image_id, Category_id_md_initial, conf, Category_id_md)
#add the bounding box column list
md_image_df_conf$bbox_md <- bbox_md


#only for above a certain confidence level
md_image_df <- md_image_df_conf
conf_level <- 0
for (i in 1:length(md_image_df_conf$conf)){
        if (md_image_df_conf$conf[i] <= conf_level){
              md_image_df$Category_id_md[i] <- "0"    #empty
        } 
}

#data frame for megadetector classification name and id
md_data_categories <- as.data.frame(do.call(rbind, md_data$detection_categories))
colnames(md_data_categories)[1] <- "Classification_Megadetector"
md_data_categories$Category_id_md <- rownames(md_data_categories)
md_data_categories <- rbind(md_data_categories, c("empty", "0"))

md_data_info <- md_data$info

md_animal_df <- merge(md_image_df, md_data_categories, by="Category_id_md")
md_animal_df <- md_animal_df [,c("image_id", "Classification_Megadetector", "bbox_md")]





#TOTAL DATA FRAMES, MANUAL & MEGADETECTOR


#the bounding boxes are formatted differently, hard to compare them.
#check bounding boxes
#for (i in data_images$id){
#    image <- all_df[all_df$image_id==i , ] 
#}


###comparing images from manual vs megadetector

#can't just merge them as images have a different number of detections

#need to check each image and compare what is inside, using loop and creating the combined data frame manually
#if megadetector more detections than manual, create a manual 'empty' row for that image
#if manual has more detections than megadetector, create a megadetector 'empty' row for that image

#loop through every image id

all_animal_df <- data.frame()   #create an empty dataframe to add information to

for (i in md_images){
        
        #progress checker
        if (strtoi(i)%%1000==0){         
                print(i)
        }
        
        #corresponding database of the current image in megadetector dataframe
        md_rows <- md_animal_df[md_animal_df$image_id==i,]
        #corresponding database of the current image in manual dataframe
        manual_rows <- manual_df[manual_df$image_id==i,]
        
        

        #megadetector more detections than manual
        while (nrow(md_rows)>nrow(manual_rows)){
                manual_rows <- rbind(manual_rows, list(i, "empty", list(c(0,0,0,0))))    
        }
        
        
        #manual more detections than megadetector
        while (nrow(manual_rows)>nrow(md_rows)){
                md_rows <- rbind(md_rows, list(i, "empty", list(c(0,0,0,0))))   
        }
        
        #cannot use merge by image_id as both rows have same image_id, so use cbind
        combined_df <- cbind(md_rows, manual_rows)
        
        all_animal_df <- rbind(all_animal_df, combined_df)
}

#with image id
animal_df_images <- all_animal_df[,c("image_id", "Classification_Megadetector", "Classification_manual")]
#just the classifications
animal_df <- all_animal_df[,c("Classification_Megadetector", "Classification_manual")]

table_animal <- table(animal_df)

#CONFUSION MATRIX

#get names of animals, and remove humans and vehicle category name, also does not include the empty category
animal_names <- data_categories[1][-c(9,10),]



cm_manual_class <- vector()
cm_md_class <- vector()
for (i in 1:length(all_animal_df$Classification_manual)){
        if (all_animal_df$Classification_manual[i] %in% animal_names){
                cm_manual_class[i] <- "positive"     
        } else{
                cm_manual_class[i] <- "negative"
        }
}
for (i in 1:length(all_animal_df$Classification_Megadetector)){
        if (all_animal_df$Classification_Megadetector[i] %in% c("animal")){
                cm_md_class[i] <- "positive"     
        } else if (all_animal_df$Classification_Megadetector[i] %in% c("empty", "person", "vehicle")){
                cm_md_class[i] <- "negative"
        } else {
                cm_md_class[i] <- "other"
        }
}

cm_df <- data.frame(cm_manual_class, cm_md_class)

#actual positive, predicted positive (actual=manual, predicted=megadetector)
apos_ppos <- cm_df[cm_df$cm_manual_class=="positive" & cm_df$cm_md_class=="positive", ]
apos_pneg <- cm_df[cm_df$cm_manual_class=="positive" & cm_df$cm_md_class=="negative", ]
aneg_ppos <- cm_df[cm_df$cm_manual_class=="negative" & cm_df$cm_md_class=="positive", ]
aneg_pneg <- cm_df[cm_df$cm_manual_class=="negative" & cm_df$cm_md_class=="negative", ]


confusion_matrix <- matrix(nrow=2, ncol=2)
rownames(confusion_matrix) <- c("Predicted Positive", "Predicted Negative")
colnames(confusion_matrix) <- c("Actual Positive", "Actual Negative")
confusion_matrix[1,1] <- nrow(apos_ppos)
confusion_matrix[1,2] <- nrow(aneg_ppos)
confusion_matrix[2,1] <- nrow(apos_pneg)
confusion_matrix[2,2] <- nrow(aneg_pneg)



#OUTPUTS
table_animal
confusion_matrix




#make a folder with these results, with the images inside
#e.g. 0.6/Camelus_ferus/positive

apos_pneg_id<- animal_df_images[animal_df_images$Classification_Megadetector %in% c("empty", "person", "vehicle")  & animal_df_images$Classification_manual %in% animal_names, "image_id"]

#warning if it already exists so can just put showWarnings as false, as it does not crash just has a warning
#path to create the folder
path <- "C:/Users/n1638/Documents/ZSL/ENA24/conf_matrix_vis/conf_0"
dir.create(path , recursive=TRUE, showWarnings = FALSE)

        
#original image paths
images_in_folder <- paste("C:/Users/n1638/Documents/ZSL/ENA24/ena24_output/anno_ena24_images~",apos_pneg_id ,".jpg",sep="")

#copy the files over
file.copy(images_in_folder, path)

#look at the images
#all_animal_df[all_animal_df$image_id=="8496",]
