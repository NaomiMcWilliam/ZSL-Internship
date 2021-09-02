#install.packages('rgeos')      #for polygons
#install.packages('maps')

library('leaflet')
library(magrittr)
library(sp)
library(maps)

#create a map widget
leaflet()

m <- leaflet()
m <- addTiles(m)  # Add default OpenStreetMap map tiles
#m<- addMarkers(m, lng=105, lat=42.8, popup="Gobi desert")
m<- addMarkers(m, lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map

#could also write the above like this, using %>% from magrittr package
map <- leaflet() %>%
        addTiles() %>%
        addMarkers(lng=174.768, lat=-36.852, popup = "Birthplace of R") %>%
        print

#Initializing map options
leaflet(options= leafletOptions(minZoom=0, maxZoom=18))

#add some circles to a map
#automatically finds lat/latitude or long/longitude from dataframe
df <- data.frame(Lat=1:10, Long=rnorm(10))
leaflet(df) %>%
        addCircles() %>%
        #specify lat and long columns from the dataframe
        # ~x means the variable x in the data object (df)
        addCircles(lng=~Long, lat=~Lat)

#may use a different data object to override data provided in leaflet()
leaflet() %>% addCircles(data=df)
leaflet() %>% addCircles(data=df, lat=~Lat, lng=~Long)



#Using SP


#filled in polygons
Sr1 = Polygon(cbind(c(2, 4, 4, 1, 2), c(2, 3, 5, 4, 2)))
Sr2 = Polygon(cbind(c(5, 4, 2, 5), c(2, 3, 2, 2)))
Sr3 = Polygon(cbind(c(4, 4, 5, 10, 4), c(5, 3, 2, 5, 5)))
#polygon is a hole
Sr4 = Polygon(cbind(c(5, 6, 6, 5, 5), c(4, 4, 3, 3, 4)), hole = TRUE)

#have to redefine as polygons
Srs1 = Polygons(list(Sr1), "s1")
Srs2 = Polygons(list(Sr2), "s2")
Srs3 = Polygons(list(Sr4, Sr3), "s3/4")
SpP = SpatialPolygons(list(Srs1, Srs2, Srs3), 1:3)
leaflet(height = "300px") %>% addPolygons(data = SpP)

#using maps

mapStates = map("state", fill = TRUE, plot = FALSE)
leaflet(data = mapStates) %>% addTiles() %>%
        addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)

# Add default OpenStreetMap map tiles
m = leaflet() %>% addTiles()
#Create a data frame
df = data.frame(
        lat = rnorm(100),      #latitude of point
        lng = rnorm(100),      #longitude of point
        size = runif(100, 5, 20),   #size of point
        color = sample(colors(), 100)   #color of point
)

#create leaflet window with data frame
m = leaflet(df) %>% addTiles()   # Add default OpenStreetMap map tiles

#add circles based on the data frame in leaflet
m %>% addCircleMarkers(radius = ~size, color = ~color, fill = FALSE)

#add circles based on data frame, with size and color defined in the arguments rather than df
m %>% addCircleMarkers(radius = runif(100, 4, 10), color = c('red'))
