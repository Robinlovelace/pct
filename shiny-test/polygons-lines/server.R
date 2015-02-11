library(shiny)
library(leaflet)
library(ggmap)
library(rgdal)

# Load data
map_centre <- geocode("Leeds")
l <- readRDS("al.Rds")

leeds <- readRDS("leeds-msoas-simple.Rds") %>%
  spTransform(CRS("+init=epsg:4326"))

function(input, output){
  map = leaflet(data = l) %>%
    addTiles() %>%
    setView(lng = map_centre[1], lat = map_centre[2], zoom = 10) %>%
    addPolygons(data = leeds) %>%
    addPolylines(color = "red")
  #     addPopups(-1.549, 53.8, 'First ever popup in leaflet') # add popup

  output$myMap = renderLeaflet(map)

}