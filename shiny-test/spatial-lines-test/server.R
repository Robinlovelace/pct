library(shiny)
library(leaflet)
library(ggmap)
library(rgdal)

# Load data
map_centre <- geocode("Leeds")
l <- readRDS("l.Rds")

function(input, output){
  map = leaflet(data = l) %>%
    addTiles() %>%
    setView(lng = map_centre[1], lat = map_centre[2], zoom = 15) %>%
    addPolylines()
#     addPopups(-1.549, 53.8, 'First ever popup in leaflet') # add popup

  output$myMap = renderLeaflet(map)

}