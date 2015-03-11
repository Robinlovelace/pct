# # # # # # # # # #
# load data for   #
# npct shiny tool #
# # # # # # # # # #

source("set-up.R") # load required packages

zones <- shapefile("pct-data/manchester/manc-msoa-lores.shp") # zones to display

# Load the local flow data - see loading-data/load-flow.R
flow <- read.csv("pct-data/manchester/msoa-flow-manc.csv")
flow$X <- NULL

l <- gFlow2line(flow, zones)
head(l@data)

l$clc_dutch <- l$clc + runif(nrow(l), min = 0, max = 0.2)
l$plc_dutch <- l$plc + runif(nrow(l), min = 0, max = 0.2)
l$ecp_dutch <- l$clc + runif(nrow(l), min = 0, max = 20)

writeGeoJSON(x = l, filename = "pct-data/manchester-shiny/lines")

# # # # # #
# Testing #
# # # # # #

# # Test plotting
#
# cols <- heat.colors(4, alpha = 0.9)
#
# flow$col <- cut(flow$ecp, breaks = quantile(flow$ecp), labels = cols)
#
# # pdf()
# plot(zones)
# for(i in 1:nrow(flow)){
# # for(i in 1:300){
#   from <- zones$geo_code %in% flow$Area.of.residence[i]
#   to <- zones$geo_code %in% flow$Area.of.workplace[i]
#   x <- coordinates(zones[from, ])
#   y <- coordinates(zones[to, ])
#   lines(c(x[1], y[1]), c(x[2], y[2]), col = flow$col[i], lwd = flow$ecp[i] / 100)
# }
# # dev.off()
#
#
# # Compare estimated and actual number of cyclists
# plot(flow$Bicycle, flow$ecp)
# cor(flow$Bicycle, flow$ecp)
