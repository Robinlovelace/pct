library(shiny)
library(leaflet)
library(ggmap)

map_centre <- geocode("Leeds")

function(input, output){
  map = leaflet() %>% addTiles() %>% setView(lng = map_centre[1], lat = map_centre[2], zoom = 15)
  output$myMap = renderLeaflet(map)

}