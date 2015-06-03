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
source("buildmaster.R") # load data from build file
plot(zbuf) # study area (scope of analysis)

# Loading the (maybe smaller, maybe equal in size) area to plot
plot(zones, add = T) # zones to plot

# # # # # # # # #
# Subset flows  #
# in study area #
# # # # # # # # #

flowsex$id <- paste(flowsex$Area.of.residence, flowsex$Area.of.workplace)
flowsex <- flowsex[flowsex$id %in% flow$id,]

# add Bicyle to flowsex

plot(flow$All, flowsex$All) # shows not 100% identical
flow_to_join <- dplyr::select(flow, id, Bicycle)
flowsex <- left_join(flow_to_join, flowsex)

# # # # # # # # #  #
# Get av nos males #
# cycling in zone  #
# # # # # # # # #  #
las_pcycle <- readOGR("pct-bigdata/national/las-pcycle.geojson", "OGRGeoJSON")
area_pcycle <- las_pcycle@data[las_pcycle$NAME == 'Manchester',]
p_trips_male <- area_pcycle$clc_m


flowsex$gendereq = flowsex$Bicycle / flowsex$All * p_trips_male * (1 + flowsex$Female / flowsex$Male)

summary(flowsex$gendereq)

# from flow-model.Rmd: pcycle(z) m ∗ tf low ∗ ptrips f
tflow_m <- flowsex$Male
tflow_f <- flowsex$Female
clc_m <- flow$Bicycle * p_trips_male
pmale_c <- clc_m / tflow_m
slc_gendereq_f <- tflow_f * pmale_c
slc_gendereq <- clc_m + slc_gendereq_f
# final result (need to deal with inf/na values)

summary(slc_gendereq)
plot(flowsex$Bicycle, slc_gendereq)
abline(a = 0, b = 1)

plot(flowsex$Bicycle, flowsex$gendereq)
abline(a = 0, b = 1)
