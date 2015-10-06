# Aim: explore generation and visualisation of the network
# Next step: develop a proper script, to be called from load.Rmd that does this
# for each region

library(stplanr)

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

t10 <- rfall
plot(t10)
head(t10@data)
rg <- gOverline(t10, attrib = "gov_target")

# plot with width proportional to olc
leaflet()  %>% addPolylines(data = t10, weight = t10$current/1.5, opacity = 0.2)

# rg <- gOverline(rfall, attrib = "gov_target")
# rg <- readRDS("~/repos/pct/pct-data/leeds/rnet.RData")

summary(rg)
line_widths <- rg$gov_target / mean(rg$gov_target) * 3
summary(line_widths)
line_widths <- line_widths + 0.3
summary(line_widths)
line_widths[line_widths > 8] <- 8

library(leaflet)
rg <
leaflet() %>% addTiles() %>% addPolylines(data = rg, weight = line_widths, popup = rg@data$gov_target)

plot(rg, lwd = rg@data$gov_target / 500)
# saveRDS(rg, "~/repos/pct/pct-data/leeds/rnet.RData")
