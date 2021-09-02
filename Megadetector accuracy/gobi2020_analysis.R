#creating a confusion matrix
#human predictions are the accurate ones, and megadetector are predicted ones


#install.packages("tidyverse")
#install.packages("rjson")
#install.packages("reshape2")


library(tidyverse)
library(glue)

#READ IN THE CSV
data <- read.csv("Gobi_metadata.csv")

#need the directory, file name (not unique, can be the same for different cameras), species
directory_csv <- data[,"Directory"]
#remove the things before
directory_csv <- str_sub(directory_csv,20,str_length(directory_csv))
filename_csv <- data[,"FileName"]
species_csv <- data[,"Species"]

directory_csv_full <- vector()
for (i in 1:length(directory_csv)){
        directory_csv_full[i] <- paste(directory_csv[i], filename_csv[i], sep="/") 
}

#display all the different species
table(species_csv, useNA = "ifany")
#i will count everything that is not NA or human as an animal

conf_level="0.01"

#get directories of all the images in a folder
directory_md_full <- list.files(path=glue("../GobiOutput/Gobi_images_separation_{conf_level}_conf"), full.names=TRUE, recursive=TRUE)
directory_md_split <- strsplit(directory_md_full, "/")

fold_num  <- 3    #number of folders till the classification

#get just the classification
classification_list <- sapply(directory_md_split, function(classify) classify[fold_num + 1 ])


#first item is path to image, second item is the classification
images <- vector()
count<-1
for (i in directory_md_split){
        if (is.na(i[fold_num + 7])){
                combined <- paste(i[fold_num + 3],i[fold_num + 4],i[fold_num + 5],i[fold_num + 6],sep="/")
                
        } else {
                combined <- paste(i[fold_num + 3],i[fold_num + 4],i[fold_num + 5],i[fold_num + 6],i[fold_num + 7],sep="/")
                
        }

        #images <- append(images, list(list(combined, i[2])))
        #images <- append(images, combined)
        images[count] <- combined
        count <- count + 1
}

#make the columns either animal or not animal 
animal_list <- c("Bird", "Camelus ferus", "Domestic Camel", "Equus heminous", "Gazelle subgutturosa", "Goats", "Lepus tolai", "Ovis ammon","Unknown", "Vulpes vulpes")
animal_md_list <- c("animals", "animal_person", "animal_person_vehicle", "animal_vehicle")
species_csv_new<- vector()
classification_list_new <- vector()
for (i in 1:length(species_csv)){
        if (species_csv[i] %in% animal_list){
                species_csv_new[i] <- "positive"     
        } else{
                species_csv_new[i] <- "negative"
        }
        
}

for (i in 1:length(classification_list)){
        if (classification_list[i] %in% animal_md_list){
                classification_list_new[i]<-"positive"
        } else{
                classification_list_new[i]<-"negative"
        }
}


#create a data frame for the images that have been sorted by the megadetector
md_df <- data.frame(Directory=images, Megadetector_Classification=classification_list)
actual_df <- data.frame(Directory=directory_csv_full, Manual_Classification=species_csv)

#create a data frame with the image name, megadetector classification and human classification
total_df <- merge(md_df, actual_df, by="Directory")

#data frame with image name, and positive or negative animal detection for megadetector and manual 
md_df_new <- data.frame(Directory=images, Megadetector_Classification=classification_list_new)
actual_df_new <- data.frame(Directory=directory_csv_full, Manual_Classification=species_csv_new)
animal_df <- merge(md_df_new, actual_df_new, by="Directory")

#actual positive, predicted positive (actual=manual, predicted=megadetector)
apos_ppos <- animal_df[animal_df$Manual_Classification=="positive" & animal_df$Megadetector_Classification=="positive", ]
apos_pneg <- animal_df[animal_df$Manual_Classification=="positive" & animal_df$Megadetector_Classification=="negative", ]
aneg_ppos <- animal_df[animal_df$Manual_Classification=="negative" & animal_df$Megadetector_Classification=="positive", ]
aneg_pneg <- animal_df[animal_df$Manual_Classification=="negative" & animal_df$Megadetector_Classification=="negative", ]


confusion_matrix <- matrix(nrow=2, ncol=2)
rownames(confusion_matrix) <- c("Predicted Positive", "Predicted Negative")
colnames(confusion_matrix) <- c("Actual Positive", "Actual Negative")
confusion_matrix[1,1] <- nrow(apos_ppos)
confusion_matrix[1,2] <- nrow(aneg_ppos)
confusion_matrix[2,1] <- nrow(apos_pneg)
confusion_matrix[2,2] <- nrow(aneg_pneg)

#find out more about what animals it is missing etc
#apos_pneg_df <- total_df[total_df$Directory %in% apos_pneg$Directory, c("Megadetector_Classification","Manual_Classification")]

#images with camelus ferus
#total_df[total_df$Manual_Classification=="Camelus ferus" & !is.na(total_df$Manual_Classification),]

animal_class_df <- merge(md_df_new, actual_df, by="Directory")

#species in my data set
table(total_df[,c("Megadetector_Classification", "Manual_Classification")])


#make a folder with these results, with the images inside
#e.g. 0.6/Camelus_ferus/positive

conf_level_options <- c("0.1","0.2","0.4","0.6","0.725","0.9")
animals <- names(table(animal_class_df[,"Manual_Classification"]))
md_class <- names(table(animal_class_df[,"Megadetector_Classification"]))



original_images <- list.files(path="../Gobi2020Sample", full.names=TRUE, recursive=TRUE)

for(j in animals){
        for(k in md_class){
                #warning if it already exists so can just put showWarnings as false, as it does not crash just has a warning
                path <- glue("C:/Users/Naomi/Desktop/ZSL/GobiOutput/Classified/{conf_level}/{j}/{k}")
                dir.create(path , recursive=TRUE, showWarnings = FALSE)
                image_path_names <- animal_class_df[animal_class_df$Manual_Classification==j & !is.na(total_df$Manual_Classification) & animal_class_df$Megadetector_Classification==k,"Directory"]
                images_in_folder <- paste("C:/Users/Naomi/Desktop/ZSL/Gobi2020Sample/",image_path_names, sep="")
                #print(image_path_names)
                #print(images_in_folder)
                file.copy(images_in_folder, path)
                
        }
}


