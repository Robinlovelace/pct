# Load msoa-msoa by sex data and save it to RAM as flowsex
# see load.R

# see https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
f <- "/media/robin/data/data-to-add/msoa-2011-flow-mode/WU01BEW_msoa_v1.zip" # file location
unzip(f)

library(readr) # new library for reading data quickly
flowsex <- read_csv("wu01bew_msoa_v1.csv", col_names = F)
head(flowsex)
names(flowsex) <- c("Area.of.residence", "Area.of.workplace", "All", "Male", "Female")

# # # # # # # # # #
# The study area  #
# # # # # # # # # #

# ttwa data from documents/ttwa.Rmd - SpatialPolygon of study area
zones <- readRDS("pct-data/manchester/z.Rds")
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
o <- flowsex$Area.of.residence %in% cents$MSOA11CD
d <- flowsex$Area.of.workplace %in% cents$MSOA11CD
flowsex <- flowsex[o & d, ] # subset flows with o and d in study area