library(stplanr)

rf <- route_cyclestreet(from = "Dublin", to = "Maynooth", plan = "fastest")
plot(rf)

source("~/repos/stplanr/R/qleafmap.R")

qleafmap(rf)

rf2 <- route_graphhopper(from = "Dublin", to = "Maynooth", vehicle = "car")

rf2@data

l <- readRDS("~/repos/pct/pct-data/leeds/l.Rds")
rfall <- readRDS("~/repos/pct/pct-data/leeds/rf.Rds")
l <- readRDS("~/repos/pct/pct-data/leeds/l.Rds")
nrow(l)
nrow(rfall)

rfall$gov_target <- l@data$cdp_slc

plot(l@data$dist, rfall@data$length) # shows its the same data

plot(rfall)
rg <- gOverline(rfall, attrib = "gov_target")
rg <- readRDS("~/repos/pct/pct-data/leeds/rnet.RData")

leaflet() %>% addTiles() %>% addPolylines(data = rg, weight = rg@data$gov_target / 80)


plot(rg, lwd = rg@data$gov_target / 500)
# saveRDS(rg, "~/repos/pct/pct-data/leeds/rnet.RData")
