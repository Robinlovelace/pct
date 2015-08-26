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
rfall$current <- l@data$Bicycle

plot(l@data$dist, rfall@data$length) # shows its the same data

plot(rfall)

plot(rfall)

t10 <- rfall[1:20,]
plot(t10)
head(t10@data)
rg10 <- gOverline(t10, attrib = "gov_target")

# rg <- gOverline(rfall, attrib = "gov_target")
rg <- readRDS("~/repos/pct/pct-data/leeds/rnet.RData")

line_widths <- rg@data$gov_target / 100
line_widths <- line_widths + 0.3
summary(line_widths)
line_widths[line_widths > 8] <- 8

leaflet() %>% addTiles() %>% addPolylines(data = rg, weight = line_widths, popup = rg@data$gov_target)

rg <-

plot(rg, lwd = rg@data$gov_target / 500)
# saveRDS(rg, "~/repos/pct/pct-data/leeds/rnet.RData")
