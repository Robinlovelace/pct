# take data from la-analysis and plot it on a map

bbox(las)
las <- spTransform(las, CRSobj = CRS("+init=epsg:4326"))

qtm(las, "shortcar", fill.palette = "YlOrRd", scale = 0.7)
nrow(las)

# las <- las[!is.na(las$All_All),]
las2 <- las[!is.na(las$All_All),]
qtm(las2) # error: the selection breaks continuity...
las$shortcar <- las$shortcar * 100

library(leaflet)

# Leaflet map
qpal <- colorQuantile(palette = "YlOrRd", las$shortcar, n = 5)
qpal <- colorBin(palette = "YlOrRd", las$shortcar, bins = 5)
leaflet(las) %>%
  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>%
  addPolygons(color = ~qpal(shortcar), fillOpacity = 0.7, smoothFactor = 0.2, weight = 1) %>%
  addLegend(pal = qpal, values = ~shortcar, opacity = 1)


object.size(las) / 1000000

lasen <- las[grepl(pattern = "E", las@data$geo_code),]
bbox(cuas)
bbox(las)
las_outline <- gBuffer(cuas, width = 0.001)
plot(las_outline)
plot(lasen)
qtm(lasen)