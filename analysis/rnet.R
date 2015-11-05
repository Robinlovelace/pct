# Aim: explore generation and visualisation of the network
# Next step: develop a proper script, to be called from load.Rmd that does this
# for each region

library(stplanr)

l <- readRDS("~/repos/pct/pct-data/West-Yorkshire/l.Rds")
rfall <- readRDS("~/repos/pct/pct-data/West-Yorkshire/rf.Rds")
l <- readRDS("~/repos/pct/pct-data/West-Yorkshire/l.Rds")
nrow(l)
nrow(rfall)

rfall$gov_target <- l@data$cdp_slc
rfall$current <- l@data$Bicycle

plot(l@data$dist, rfall@data$length) # shows its the same data

plot(rfall)

plot(rfall)

t10 <- rfall
plot(t10)
head(t10@data)
rg <- gOverline(t10, attrib = "gov_target")

# plot with width proportional to olc
leaflet()  %>% addPolylines(data = rnet, weight = rnet$ /1.5, opacity = 0.2)

# rg <- gOverline(rfall, attrib = "gov_target")
rg <- readRDS("~/repos/pct/pct-data/West-Yorkshire/rnet.Rds")

summary(rg)
line_widths <- rg$dutch_slc / mean(rg$dutch_slc) * 3
summary(line_widths)
line_widths <- line_widths + 0.3
summary(line_widths)
line_widths[line_widths > 8] <- 8

library(leaflet)
leaflet() %>% addTiles() %>% addPolylines(data = rg, weight = line_widths, popup = rg@data$gov_target)

# Add Bradford data
opts <- raster::shapefile("~/Desktop/bradford/HS2 options W2L_polyline.shp")
bbox(opts)
opts <- spTransform(opts, CRSobj = CRS("+init=epsg:4326"))

leaflet() %>% addTiles() %>% addPolylines(data = rg, weight = line_widths, popup = rg@data$gov_target) %>%
  addPolylines(data = opts, color = "black")

plot(rg, lwd = rg@data$gov_target / 500)
# saveRDS(rg, "~/repos/pct/pct-data/West-Yorkshire/rnet.RData")
