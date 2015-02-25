# # # # # # # # # # # # # # # #
# Load MSOA areas for the UK  #
# Needs mapshaper installed   #
# - thanks to Richard Ellison #
# # # # # # # # # # # # # # # #

library("raster")

# # Heavily simplify the shape. Warning - this will change the centroid results

# # Original code:
# # system('mapshaper /media/robin/SAMSUNG/geodata/msoa-2011/infuse_msoa_lyr_2011.shp auto-snap -simplify keep-shapes 1% -o force /media/robin/SAMSUNG/geodata/msoa-2011/infuse_msoa_lyr_2011-1perc-mappshaped.shp',wait=TRUE)

# # New code (will need install_github("robinlovelace/pctpack") to work)
# dir <- "/media/robin/SAMSUNG/geodata/msoa-2011/infuse_msoa_lyr_2011.shp" # directory
# pctpack::gMapshape(dir, percent = 1)

# dir <- "/media/robin/SAMSUNG/geodata/msoa-2011/"
# ukmsoa <- readOGR(dir, "infuse_msoa_lyr_2011mapshaped_1%")
# plot(ukmsoa)

# Load manchester
# sel_man <- grepl( "Manchester", ukmsoa$geo_label )
# manc <- ukmsoa[ sel_man, ]
# plot(manc)
# writeOGR(manc, "pct-data/manchester/", "manc-msoa-lores", "ESRI Shapefile")
man <- shapefile("pct-data/manchester/manc-msoa-lores.shp")

# # Greater manchester
# gman <- c("Manchester|Bolton|Bury|Oldham|Rochdale|Stockport|Tameside|Trafford|Wigan|Salford")
# sel_gman <- grepl(gman, ukmsoa$geo_label )
# gman <- ukmsoa[ sel_gman, ]
# plot(gman)
# writeOGR(gman, "pct-data/manchester/", "gman-msoa-lores", "ESRI Shapefile")
gman <- shapefile("pct-data/manchester/gman-msoa-lores.shp")

# # Load coventry
# sel_cov <- grepl( "Coventry", ukmsoa$geo_label )
# cov <- ukmsoa[ sel_cov, ]
# plot(cov)
# writeOGR(cov, "pct-data/coventry", "msoa-lores", "ESRI Shapefile")
cov <- shapefile("pct-data/coventry/msoa-lores.shp")

# # Load nor
# sel_nor <- grepl("Norw", ukmsoa$geo_label )
# nor <- ukmsoa[ sel_nor, ]
# plot(nor)
# writeOGR(nor, "pct-data/norwich", "msoa-lores", "ESRI Shapefile")
nor <- shapefile("pct-data/norwich/msoa-lores.shp")

# # Wider Norwich
# sel_wnor <- grepl("South Norfolk|Norwich|Broadland", ukmsoa$geo_label )
# wnor <- ukmsoa[ sel_wnor, ]
# plot(wnor)
# writeOGR(wnor, "pct-data/norwich", "wmsoa-lores", "ESRI Shapefile")
wnor <- shapefile("pct-data/norwich/wmsoa-lores.shp")

# # Load leeds
# sel_lds <- grepl( "Leeds", ukmsoa$geo_label )
# leeds <- ukmsoa[ sel_lds, ]
# plot(leeds)
# writeOGR(leeds, "pct-data/leeds/", "leeds-msoa-lores", "ESRI Shapefile")

# # Extract buffer of surrounding areas
# library(maptools)
# outline <- unionSpatialPolygons(leeds, IDs = rep(1, nrow(leeds)) )
# plot(outline)
# buf <- gBuffer(outline, width = 10000)
# plot(buf)
# plot(leeds, add = T)
# outer <- ukmsoa[buf, ]
# plot(outer)
# plot(buf, add = T) # the selection includes centroide far beyond the buffer
#
# # attempt2: used centroids
# ukmsoa_cents <- gCentroid(ukmsoa, byid = T)
# ukmsoa_cents <- SpatialPointsDataFrame(ukmsoa_cents, data = ukmsoa@data)
# outer <- ukmsoa_cents[buf, ]
# plot(outer, add = T)

# # save the output
# saveRDS(outer, file = "pct-data/leeds/outer-points.Rds")
# saveRDS(leeds, file = "pct-data/leeds/leeds-msoas-simple.Rds")
# saveRDS(buf, file = "pct-data/leeds/10km-buffer.Rds")

# # Load TTWA
# url = "https://geoportal.statistics.gov.uk/Docs/Boundaries/Travel_to_work_areas_%28E+W%29_2007_Boundaries_%28Generalised_Clipped%29.zip"
# download.file(url, method = "curl", destfile = "bigdata/ttwa.zip")
# unzip(zipfile = "bigdata/ttwa.zip", exdir = "bigdata/")
ttw <- shapefile("bigdata/TTWA_DEC_2007_EW_BGCmapshaped_5%.shp")
