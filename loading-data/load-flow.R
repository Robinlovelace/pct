# # # # # # # # # # # # #
# Aim: load flow data   #
# add ag. model output  #
# # # # # # # # # # # # #

# # # # # # #
# Load data #
# # # # # # #

# see https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
f <- "bigdata/public-flow-data-msoa/wu03ew_v2.csv" # file location
flow <- read.csv(f, stringsAsFactors = F) # load public msoa-level flow data
flow <- rename(flow, All = All.categories..Method.of.travel.to.work)

# # # # # # # # # #
# The study area  #
# # # # # # # # # #

# ttwa data from documents/ttwa.Rmd - SpatialPolygon of study area
study_area <- readRDS("pct-data/manchester/manc-ttwa.Rds")
plot(study_area)

# Loading the (maybe smaller, maybe equal in size) area to plot
manc <- shapefile("pct-data/manchester/manc-msoa-lores.shp") # polygon
library(maptools)
plot_area <- unionSpatialPolygons(manc, IDs = rep(1, nrow(manc))) # create outline
if(proj4string(plot_area) != proj4string(study_area)){
  proj4string(plot_area) <- proj4string(study_area)
}

# # # # # # # # #
# Subset flows  #
# in study area #
# # # # # # # # #

cents <- shapefile("bigdata/centroids/MSOA_2011_EW_PWC.shp")
cents <- cents[study_area,] # subset centroids geographically
cents_study <- cents # copy cents data (we'll overwrite cents)
o <- flow$Area.of.residence %in% cents$MSOA11CD
d <- flow$Area.of.workplace %in% cents$MSOA11CD
flow <- flow[o & d, ] # subset flows with o and d in study area

# # # # # # # # # # # # # # # # # #
# Calculate flow-level variables: #
# distances and clc for ag. model #
# # # # # # # # # # # # # # # # # #

# For loop to calculate distances
for(i in 1:nrow(flow)){
  from <- cents$MSOA11CD %in% flow$Area.of.residence[i]
  to <- cents$MSOA11CD %in% flow$Area.of.workplace[i]
  flow$dist[i] <- gDistance(cents[from, ], cents[to, ])
  if(i %% round(nrow(flow) / 10) == 0)
    print(paste0(100 * i/nrow(flow), " % out of ", nrow(flow),
      " distances calculated")) # print % of distances calculated
}

flow$dist <- flow$dist / 1000 # convert from metres to km
flow$clc <- flow$Bicycle / flow$All # current level of cycling

# # # # # # # # # # # # # #
# Estimates plc from clc  #
# # # # # # # # # # # # # #

source("models/aggregate-model.R")

flow$ecp_perc <- flow$plc - flow$clc
flow$ecp <- flow$ecp_perc * flow$All

# # # # # # # # # # # # # # # # #
# Subset lines to plotting area #
# # # # # # # # # # # # # # # # #

cents <- cents[plot_area,] # subset centroids geographically
o <- flow$Area.of.residence %in% cents$MSOA11CD
d <- flow$Area.of.workplace %in% cents$MSOA11CD
flow <- flow[o & d, ] # subset flows with o and d in study area

# # Save flow data and polygon centroids
# write.csv(flow, "pct-data/manchester/msoa-flow-manc.csv")
# writeOGR(cents, "pct-data/manchester/cents", layer = "cents", driver = "GeoJSON")
# cents84 <- spTransform(cents, CRSobj = CRS("+init=epsg:4326"))
# writeOGR(cents84, "pct-data/manchester/cents84", layer = "cents", driver = "GeoJSON")
