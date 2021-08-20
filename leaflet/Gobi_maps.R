library('leaflet')
library(magrittr)
library(readr)

#utm to long/lat
library(terra)



#READ IN THE CSV
data <- read.csv("Gobi_metadata.csv")

#data frame of camera and species at the camer, NA values included $ Na values removed
cam_species_df_full <- data[,c("Camera", "Species")]
cam_species_df <- data[!is.na(data$Species),c("Camera", "Species")]

#edited camera names
#cam_species_df_full$Camera <- parse_number(cam_species_df_full$Camera)
#cam_species_df$Camera <- parse_number(cam_species_df$Camera)

#camera, species, frequency  (includes all cameras)
cam_species_freq <- as.data.frame(table(cam_species_df_full))

#latitude and logitude of each camera
coords <- read.csv("Gobi_location_testdata.csv")
colnames(coords)[1] <- "Camera"


all_df <- merge(cam_species_freq, coords, by="Camera")


leaflet(all_df[all_df$Species=="Bird",]) %>% addTiles() %>%
        addCircles(lng = ~Longitude, lat = ~Latitude, weight = 1,
                   radius = ~sqrt(Freq) * 2000, label = ~Camera
        )

#can change colour depending on species
#can change colour depending on number of detections using legend
#can be white for 0 detections

#distance scale
#circle size scale



#UTM to lat/long
library(terra)
#file encoding so that it reads it in the correct format (other column names are a bit odd)
utm_csv <- read.csv("UTM Gobi 2019.csv", fileEncoding="UTF-8-BOM")

#coords in zone 47T
UTM_coords_47T <- utm_csv[utm_csv$UTM_Zone=="47T",c("Easting", "Northing")]
v_47T <- vect(UTM_coords_47T, crs="+proj=utm +zone=47T +datum=WGS84  +units=m", geom = c("Easting", "Northing"))
y_47T  <- project(v_47T, "+proj=longlat +datum=WGS84")

#coords in zone 46T
UTM_coords_46T <- utm_csv[utm_csv$UTM_Zone=="46T",c("Easting", "Northing")]
v_46T <- vect(UTM_coords_46T, crs="+proj=utm +zone=46T +datum=WGS84  +units=m", geom = c("Easting", "Northing"))
y_46T  <- project(v_46T, "+proj=longlat +datum=WGS84")

#combined coords 
y <- rbind(y_46T, y_47T)

#longitude and latitude 
#not in same order as utm_csv 46T at start, need to fix this!! 
lonlat <- geom(y)[, c("x", "y")]
head(lonlat, 3)

#put in same order
cam_46 <- utm_csv[utm_csv$UTM_Zone=="46T","Camera_Point"]
cam_47 <- utm_csv[utm_csv$UTM_Zone=="47T","Camera_Point"]

Points <- append(cam_46, cam_47)
point_coords <- cbind(as.data.frame(lonlat), Points)
colnames(point_coords) <- c("longitude", "latitude", "Camera_Points")


#need to match camera name with camera point.

