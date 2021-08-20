#map tiles
library('leaflet')
library(magrittr)
library(sp)
library(maps)

#default OpenStreetMap tiles
m<- leaflet() %>%
        setView(lat=42.7952, lng =105.0324, zoom=12)

#third party tiles
#add using addProviderTiles()
m %>% addProviderTiles(providers$OpenTopoMap)


#icon markers
#addMarkers() or addAwesomeMarkers(), default is dropped pin icon

#data set of 1000 seismic events. lat, long, depth, mag, stations
data(quakes)

# Show first 20 rows from the `quakes` dataset
leaflet(data = quakes[1:20,]) %>% addTiles() %>%
        #plot the icons, if you hover / click it shows magnitude from magnitude column in data
        addMarkers(~long, ~lat, popup = ~as.character(mag), label = ~as.character(mag))



#customizing
#icon as a URL or file path

#makeIcon() to apply a single icon to a set of markers
greenLeafIcon <- makeIcon(
        iconUrl = "http://leafletjs.com/examples/custom-icons/leaf-green.png",
        iconWidth = 38, iconHeight = 95,
        iconAnchorX = 22, iconAnchorY = 94,
        shadowUrl = "http://leafletjs.com/examples/custom-icons/leaf-shadow.png",
        shadowWidth = 50, shadowHeight = 64,
        shadowAnchorX = 4, shadowAnchorY = 62
)

leaflet(data = quakes[1:4,]) %>% addTiles() %>%
        addMarkers(~long, ~lat, icon = greenLeafIcon)


#icons only vary by a couple of parameters, use icons()
#any arguments that are 
quakes1 <- quakes[1:10,]

leafIcons <- icons(
        iconUrl = ifelse(quakes1$mag < 4.6,
                         "http://leafletjs.com/examples/custom-icons/leaf-green.png",
                         "http://leafletjs.com/examples/custom-icons/leaf-red.png"
        ),
        iconWidth = 38, iconHeight = 95,
        iconAnchorX = 22, iconAnchorY = 94,
        shadowUrl = "http://leafletjs.com/examples/custom-icons/leaf-shadow.png",
        shadowWidth = 50, shadowHeight = 64,
        shadowAnchorX = 4, shadowAnchorY = 62
)

leaflet(data = quakes1) %>% addTiles() %>%
        addMarkers(~long, ~lat, icon = leafIcons)


#icons vary by multiple parameters, makeIcon()
# Make a list of icons. We'll index into it based on name.
oceanIcons <- iconList(
        ship = makeIcon("ferry-18.png", "ferry-18@2x.png", 18, 18),
        pirate = makeIcon("danger-24.png", "danger-24@2x.png", 24, 24)
)

# Some fake data

df <- sp::SpatialPointsDataFrame(
        cbind(
                (runif(20) - .5) * 10 - 90.620130,  # lng
                (runif(20) - .5) * 3.8 + 25.638077  # lat
        ),
        data.frame(type = factor(
                ifelse(runif(20) > 0.75, "pirate", "ship"),
                c("ship", "pirate")
        ))
)

leaflet(df) %>% addTiles() %>%
        # Select from oceanIcons based on df$type
        addMarkers( icon = ~oceanIcons[type])


#awesome markers
# first 20 quakes
df.20 <- quakes[1:20,]

#sort quakes by magnitude by giving markers a color
getColor <- function(quakes) {
        sapply(quakes$mag, function(mag) {
                if(mag <= 4) {
                        "green"
                } else if(mag <= 5) {
                        "orange"
                } else {
                        "red"
                } })
}

icons <- awesomeIcons(
        icon = 'ios-close',
        iconColor = 'black',
        library = 'ion',
        markerColor = getColor(df.20)
)

leaflet(df.20) %>% addTiles() %>%
        addAwesomeMarkers(~long, ~lat, icon=icons, label=~as.character(mag))

#cluster options
leaflet(quakes) %>% addTiles() %>% addMarkers(
        clusterOptions = markerClusterOptions()
)
#freeze cluster markers at a specific zoom level
leaflet(quakes) %>% addTiles() %>% addMarkers(
        clusterOptions = markerClusterOptions(freezeAtZoom = 5)
)





#Circle markers
df <- sp::SpatialPointsDataFrame(
        cbind(
                (runif(20) - .5) * 10 - 90.620130,  # lng
                (runif(20) - .5) * 3.8 + 25.638077  # lat
        ),
        data.frame(type = factor(
                ifelse(runif(20) > 0.75, "pirate", "ship"),
                c("ship", "pirate")
        ))
)

#like regular cicles, but radius stays constant regardless of zoom level

#default appearance
leaflet(df) %>% addTiles() %>% addCircleMarkers()

# Create a palette that maps factor levels to colors
#pallette = color that values will be mapped to
#domain = possible values that can be mapped
pal <- colorFactor(palette = c("navy", "red"), domain = c("ship", "pirate"))

#leaflet window based on df
leaflet(df) %>% addTiles() %>%
        addCircleMarkers(
                #size of circle depends on if it is a ship or not in the type column in df
                radius = ~ifelse(type == "ship", 6, 10),
                
                #color of circle depends on type in pal
                color = ~pal(type),
                stroke = FALSE, fillOpacity = 0.5
        )



