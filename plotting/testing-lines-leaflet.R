# Export to shapefile for testing
shapefile("/tmp/l.shp", l)

# Explore that the distribution of l makes sense
l <- readRDS("~/other-repos/pct-shiny/data/manchester//l.Rds")

summary(l$Bicycle)

cor(l$All, l$ecp)

lhigh <- l[l$Bicycle > 10, ]
lecp <- l[ l$ecp > 6, ]
lecp <- l[ head(order(l$plc), 10), ]
lecp <- l[ head(order(l$plc, decreasing = T), 10), ]
lecp <- l[ head(order(l$dist, decreasing = T), 10), ]

library(leaflet)

leaflet() %>%
  addTiles() %>%
  addPolylines(data = lhigh) %>%
  addPolylines(data = lecp, col = "red", popup = lecp$dist)
