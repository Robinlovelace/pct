# Load msoa-msoa by sex data and save it to RAM as flowsex
# see load.R

# see https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
# f <- "bigdata/WU01BEW_msoa_v1.zip" # Not in bigdata repo as it is senstive
# unzip("bigdata/WU01BEW_msoa_v1.zip", exdir = "bigdata/")

library(readr)
flowsex <- read_csv("bigdata/wu01bew_msoa_v1.csv", col_names=F, skip=12)
head(flowsex)
names(flowsex) <- c("Area.of.residence", "Area.of.workplace", "All", "Male", "Female")

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

cents <- shapefile("bigdata/centroids/MSOA_2011_EW_PWC")
cents <- cents[study_area,] # subset centroids geographically
cents_study <- cents # copy cents data (we'll overwrite cents)
o <- flowsex$Area.of.residence %in% cents$MSOA11CD
d <- flowsex$Area.of.workplace %in% cents$MSOA11CD
flowsex <- flowsex[o & d, ] # subset flows with o and d in study area

flow <- readRDS("bigdata/national/flow.Rds")
flow <- dplyr::select(flow, Area.of.residence, Area.of.workplace, Bicycle)
o <- flow$Area.of.residence %in% cents$MSOA11CD
d <- flow$Area.of.workplace %in% cents$MSOA11CD
flow <- flow[o & d, ]

# add Bicyle to flowsex
flowsex <- left_join(flow, flowsex, by = c("Area.of.residence", "Area.of.workplace"))
# # # # # # # # #  #
# Get av nos males #
# cycling in zone  #
# # # # # # # # #  #
las_pcycle <- geojson_read("bigdata/national/las-pcycle.geojson", parse=T)
las_pcycle <- las_pcycle$features$properties
area_pcycle <- las_pcycle[las_pcycle$NAME == 'Manchester',]
p_trips_male <- area_pcycle$pmale


flowsex$gendereq = flowsex$Bicycle / flowsex$All * p_trips_male * (1+ flowsex$Female / flowsex$Male)
