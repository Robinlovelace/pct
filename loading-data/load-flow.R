# # # # # # # # # # # # #
# Aim: load flow data   #
# add ag. model output  #
# and data for pct tool #
# # # # # # # # # # # # #

# # # # # # #
# Load data #
# # # # # # #

# see https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
f <- "pct-data/national/wu03ew_v2.csv" # file location
flow <- read.csv(f, stringsAsFactors = F) # load public msoa-level flow data
flow <- rename(flow, All = All.categories..Method.of.travel.to.work)

saveRDS(flow, "pct-data/national/flow.Rds")

# # # # # # # # # #
# The study area  #
# # # # # # # # # #

# ttwa data from documents/ttwa.Rmd - SpatialPolygon of study area
study_area <- readRDS("pct-data/manchester/manc-ttwa.Rds")
plot(study_area)

# Loading the (maybe smaller, maybe equal in size) area to plot
plot_area <- shapefile("pct-data/manchester/manc-msoa-lores.shp") # polygon
library(maptools)
# create outline
plot_area <- unionSpatialPolygons(plot_area, IDs = rep(1, nrow(plot_area)))
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
# flow$ecp2 <- flow$plc * flow$All - flow$Bicycle # identical ecp result

# # # # # # # # # # # # #
# Additional scenarios  #
# # # # # # # # # # # # #

# Invented data (for testing)
flow$plc_dutch <- flow$plc + runif(nrow(l), min = 0, max = 0.2)
flow$ecp_dutch <- flow$clc + runif(nrow(l), min = 0, max = 20)

# # # # # # # # # # # # # # # # #
# Subset lines to plotting area #
# # # # # # # # # # # # # # # # #

cents <- cents[plot_area,] # subset centroids geographically
o <- flow$Area.of.residence %in% cents$MSOA11CD
d <- flow$Area.of.workplace %in% cents$MSOA11CD
flow <- flow[o & d, ] # subset flows with o and d in study area

# # # # # # # # # # # # # #
# Extract area-level data #
# # # # # # # # # # # # # #

# l <- gFlow2line(flow, zones) # doing it with lines for validation

plot(plot_area)
for(i in 1:length(cents)){

#   plotting for validation (not needed)
#   points(cents[i, ], pch = 22)
#   sel <- l@data$Area.of.residence %in% cents@data$MSOA11CD[i]
#   plot(l[sel, ], add = T, pwd = l[sel, ]$ecp + 3)

  cents$clc[i] <- sum(flow$Bicycle[i]) / sum(flow$All[i])
  cents$plc[i] <- sum(flow$Bicycle[i]) + sum(flow$ecp[i])
  cents$ecp[i] <- sum(flow$ecp[i])

  # values for scenarios
  cents$plc_dutch[i] <- sum(flow$Bicycle[i]) + sum(flow$ecp_dutch[i])
  cents$ecp_dutch[i] <- sum(flow$ecp_dutch[i])

}

msoa_avslope <- read.csv("pct-data/national/avslope-msoa.csv")
msoa_avslope <- rename(msoa_avslope, MSOA11CD = geo_code)
msoa_avslope <- select(msoa_avslope, MSOA11CD, avslope)

cents@data <- inner_join(cents@data, msoa_avslope)
head(cents@data)

# # Save flow data and polygon centroids
# write.csv(flow, "pct-data/manchester/msoa-flow-manc.csv")
# writeOGR(cents, "pct-data/manchester/cents", layer = "cents", driver = "GeoJSON")
# cents84 <- spTransform(cents, CRSobj = CRS("+init=epsg:4326"))
# writeOGR(cents84, "pct-data/manchester-shiny/cents84", layer = "cents", driver = "GeoJSON")
# shapefile(filename = "pct-data/manchester-shiny/cents.shp", object = cents84)
# write.csv(cents@data, "pct-data/manchester-shiny/cents.csv")

# # Rename variables of flow - run once then forget!
# flow <- readRDS("pct-bigdata/national/flow.Rds")
# flow <- rename(flow, From_home = Work.mainly.at.or.from.home, Light_rail = Underground..metro..light.rail..tram, Bus = Bus..minibus.or.coach, Motorbike = Motorcycle..scooter.or.moped, Car_driver = Driving.a.car.or.van, Car_passenger = Passenger.in.a.car.or.van, Foot = On.foot, Other = Other.method.of.travel.to.work)
# saveRDS(flow, "pct-bigdata/national/flow.Rds")
#



