# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Needs mapshaper installed - thanks to Richard Ellison #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # Heavily simplify the shape. Warning - this will change the centroid results

# # Original code:
# # system('mapshaper /media/robin/SAMSUNG/geodata/msoa-2011/infuse_msoa_lyr_2011.shp auto-snap -simplify keep-shapes 1% -o force /media/robin/SAMSUNG/geodata/msoa-2011/infuse_msoa_lyr_2011-1perc-mappshaped.shp',wait=TRUE)

# # New code (will need install_github("robinlovelace/pctpack") to work)
# dir <- "/media/robin/SAMSUNG/geodata/msoa-2011/infuse_msoa_lyr_2011.shp" # directory
pctpack::gMapshape(dir, percent = 1)

dir <- "/media/robin/SAMSUNG/geodata/msoa-2011/"
ukmsoa <- readOGR(dir, "infuse_msoa_lyr_2011mapshaped_1%")
# plot(ukmsoa)

head(ukmsoa@data)

# Load manchester

sel_man <- grepl( "Manchester", ukmsoa$geo_label )
manc <- ukmsoa[ sel_man, ]
plot(manc)
# writeOGR(manc, "pct-data/manchester/", "manc-msoa-lores", "ESRI Shapefile")

# Load leeds
sel_lds <- grepl( "Leeds", ukmsoa$geo_label )
leeds <- ukmsoa[ sel_lds, ]
plot(leeds)
writeOGR(leeds, "pct-data/leeds/", "leeds-msoa-lores", "ESRI Shapefile")

# Extract buffer of surrounding areas
library(maptools)
outline <- unionSpatialPolygons(leeds, IDs = rep(1, nrow(leeds)) )
plot(outline)
buf <- gBuffer(outline, width = 10000)
plot(buf)
plot(leeds, add = T)
outer <- ukmsoa[buf, ]
plot(outer)
plot(buf, add = T) # the selection includes centroide far beyond the buffer

# attempt2: used centroids
ukmsoa_cents <- gCentroid(ukmsoa, byid = T)
ukmsoa_cents <- SpatialPointsDataFrame(ukmsoa_cents, data = ukmsoa@data)
outer <- ukmsoa_cents[buf, ]
plot(outer, add = T)

# # save the output
# saveRDS(outer, file = "pct-data/leeds/outer-points.Rds")
# saveRDS(leeds, file = "pct-data/leeds/leeds-msoas-simple.Rds")
# saveRDS(buf, file = "pct-data/leeds/10km-buffer.Rds")
