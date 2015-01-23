# Script to load geographical data for Leeds

source("set-up.R") # packages needed for this analysis

dir <- "/home/robin/Dropbox/new-projects/census-flow-data-R/data/" # file directory
f <- "msoas-leeds" # the name of the shapefile to load
leeds <- readOGR(dsn = dir, layer = f)
leeds <- leeds[ grep("Leeds", leeds$geo_label), ]
plot(leeds) # take a look at the data
head(leeds@data)

