library('leaflet')
library(magrittr)
library(readr)
#utm to long/lat
library(terra)


#READING IN STATION POINTS AND LOCATION IN UTM
#Converting UTM to lat/long

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

#point_coords is a data frame of long, lat, station
point_coords <- cbind(as.data.frame(lonlat), Points)
colnames(point_coords) <- c("longitude", "latitude", "Station")




#READING IN DATA SET CONTAINING CLASSIFICATIONS, STATION, CAMERA ETC.

gobi_animal_md <- read.csv("Gobi_animal_data.csv", fileEncoding="UTF-8-BOM")

#remove the 'R' from station name.. (current format for station name is "R88", change to "88")
gobi_animal_md$Station <- parse_number(gobi_animal_md$Station)

#optional
#change some of the names of the classifications so that they fit into the other categories instead
gobi_animal_md[gobi_animal_md$Species=="Camel?","Species"] <- "unknown animal"
gobi_animal_md[gobi_animal_md$Species=="Camel & Human","Species"] <- "domestic camel"
gobi_animal_md[gobi_animal_md$Species=="Sheep & Goat","Species"] <- "Goat"



#MERGED data frame with everything + latitude and longitude of station/camera
total_df <- merge(point_coords, gobi_animal_md, by="Station")
        

#total_df but not including species/Count entries with a "-"
temp_total_df <- total_df[total_df$Count!="-" & total_df$Species!="-",]
#change entries that are 10+ to 10
temp_total_df[temp_total_df$Count=="10+","Count"] <- "10"

#data frame with just station and species, not including entries with a "-" , and has repeats for where count of an animal>1
station_species_df <- as.data.frame(lapply(temp_total_df[,c("Station", "Species")], rep, temp_total_df$Count))

#data frame with station, species, and freqeuency of the species at that station 
station_species_freq_df <- as.data.frame(table(station_species_df))

#data frame with station, species, long/lat of station, freq of species
all_df <- merge(station_species_freq_df, point_coords, by="Station")



#PLOTTING ON MAP WITH LEAFLET


#Species & colour palette
species <- c("bat", "Bird", "Butterfly", "Camelus bactrianus", "Chukar", "Corvus corax", "domestic camel", "Equus hemionus", "Gazella subgutturosa", "Goat", "Hymenoptera", "Ovis ammon", "SmallBird")
#colour palette
pal <- colorFactor(
        palette = c('red', 'blue', 'green', 'purple', '#FF8A33', 'yellow', 'cyan', 'magenta', 'pink', '#B8B37B', 'lightblue', '#83BD41', '#83E3C3'),
        domain = species
)

#make map
map <- leaflet() %>%
        #basemap
        addProviderTiles(providers$Esri.DeLorme) %>%
        
        #EMPTY CAMERAS
        addCircles(data = point_coords, 
                   weight=2,
                   color = "#000",
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
        )  %>%
        
        
        #SPECIES
        #only draw circle if freq>0 (animal present there)
        #circle raius is sqrt(Freq)*1500
        
        #bat
        addCircles(data = all_df[all_df$Species=="bat" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500), group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #bird
        addCircles(data = all_df[all_df$Species=="Bird" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #butterfly
        addCircles(data = all_df[all_df$Species=="Butterfly" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #camelus bactrianus
        addCircles(data = all_df[all_df$Species=="Camelus bactrianus" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
        
        )%>%
        #chukar
        addCircles(data = all_df[all_df$Species=="Chukar" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #corvus corax
        addCircles(data = all_df[all_df$Species=="Corvus corax" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #domestic camel
        addCircles(data = all_df[all_df$Species=="domestic camel" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #Equus hemionus
        addCircles(data = all_df[all_df$Species=="Equus hemionus" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #Gazella subgutturosa
        addCircles(data = all_df[all_df$Species=="Gazella subgutturosa" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #Goat
        addCircles(data = all_df[all_df$Species=="Goat" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #Hymenoptera
        addCircles(data = all_df[all_df$Species=="Hymenoptera" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #Ovis ammon
        addCircles(data = all_df[all_df$Species=="Ovis ammon" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )%>%
        #SmallBird
        addCircles(data = all_df[all_df$Species=="SmallBird" & all_df$Freq>0,],weight = 3,
                   color = ~pal(Species), radius = (~sqrt(Freq) * 1500),group=~Species,
                   label = ~Station, labelOptions = labelOptions(noHide=T,direction='right', textOnly = T)
                   
        )
        
        
        

#LEGEND, colour coding

map %>% addLegend( data = all_df[all_df$Species %in% species & all_df$Freq>0,],
                "topright", pal=pal, values = ~species
        ) %>%
        
        #CHECK BOX for display or not display the animal circles
        addLayersControl(
                overlayGroups = species,
                options = layersControlOptions(collapsed = FALSE)
        ) %>%
        
        #SCALE BAR for distance, in imperial and metric
        addScaleBar(
                position = "bottomleft",
                options = scaleBarOptions(  maxWidth = 300,
                                            metric = TRUE,
                                            imperial = TRUE,
                                            updateWhenIdle = TRUE)
        )



