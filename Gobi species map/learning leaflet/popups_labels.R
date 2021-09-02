#popups
library('leaflet')
library(magrittr)
#library(sp)
#library(maps)

library(htmltools)

content <- paste(sep = "<br/>",
                 "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>",
                 "606 5th Ave. S",
                 "Seattle, WA 98138"
)

leaflet() %>% addTiles() %>%
        addPopups(-122.327298, 47.597131, content,
                  options = popupOptions(closeButton = FALSE)
        )

#on markers and shapes

df <- read.csv(textConnection(
        "Name,Lat,Long
Samurai Noodle,47.597131,-122.327298
Kukai Ramen,47.6154,-122.327157
Tsukushinbo,47.59987,-122.326726"
))

#htmlEscape used to sanitize any characters in the name that might be interpreted as HTML
leaflet(df) %>% addTiles() %>%
        addMarkers(~Long, ~Lat, popup = ~htmlEscape(Name))



#customixe marker labels
#addMarkers(labelOptions=labelOptions())
#noHide    false(default)=label displayed when hover,   true=label always displayed

# Change Text Size and text Only and also a custom CSS
leaflet() %>% addTiles() %>% setView(-118.456554, 34.09, 13) %>%
        addMarkers(
                lng = -118.456554, lat = 34.105,
                label = "Default Label",
                labelOptions = labelOptions(noHide = T)) %>%
        addMarkers(
                lng = -118.456554, lat = 34.095,
                label = "Label w/o surrounding box",
                labelOptions = labelOptions(noHide = T, textOnly = TRUE)) %>%
        addMarkers(
                lng = -118.456554, lat = 34.085,
                label = "label w/ textsize 15px",
                labelOptions = labelOptions(noHide = T, textsize = "15px")) %>%
        addMarkers(
                lng = -118.456554, lat = 34.075,
                label = "Label w/ custom CSS style",
                labelOptions = labelOptions(noHide = T, direction = "bottom",
                                            style = list(
                                                    "color" = "red",
                                                    "font-family" = "serif",
                                                    "font-style" = "italic",
                                                    "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
                                                    "font-size" = "12px",
                                                    "border-color" = "rgba(0,0,0,0.5)"
                                            )))


#labels without markers using addLabelOnlyMarkers function
leaflet() %>% addTiles() %>%
        addLabelOnlyMarkers(lng=-100, lat=20, label="meow", labelOptions=labelOptions(noHide=T))