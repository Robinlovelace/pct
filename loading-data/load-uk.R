# # # # # # # # # # # # # # # #
# Load MSOA areas for the UK  #
# Needs mapshaper installed   #
# - thanks to Richard Ellison #
# # # # # # # # # # # # # # # #

library("raster")

# # # # # # # # # # # # #
# Local authority data  #
# # # # # # # # # # # # #

las <- readOGR(dsn = "pct-bigdata/national/las-pcycle.geojson", layer = "OGRGeoJSON")
nrow(las) # 326 las (including districts) in England

# download.file(url = "https://geoportal.statistics.gov.uk/Docs/Boundaries/County_and_unitary_authorities_(E+W)_2012_Boundaries_(Full_Extent).zip", destfile = "cuas.zip", method = "wget")
# download.file(url = "http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_ct_2011_gen_clipped.zip", destfile = "cuas.zip", method = "wget")


unzip("cuas.zip", exdir = "private-data/")
file.remove("cuas.zip")
lfs <- list.files(path = "private-data/", pattern = "CTYU", full.names = T)
gMapshape("private-data/CTYUA_DEC_2012_EW_BFE.shp", percent = 3)
cuas <- shapefile("pct-bigdata/national/CTYUA_DEC_2012_EW_BFEmapshaped_3%.shp")
# writeOGR(obj = cuas, dsn = "pct-bigdata/national/cuas", layer = "OGRGeoJSON", driver = "GeoJSON")

cuas <- shapefile("pct-bigdata/national/cuas.shp")
head(cuas)
cuas <- cuas[grep(pattern = "E", x = cuas@data$CTYUA12CD), ]
shapefile(x = cuas, file = "pct-bigdata/national/cuas.shp")
# geojson_write(cuas, file = "pct-bigdata/national/cuas-jsonio.geojson")
# cuas <- readOGR(dsn = "pct-bigdata/national/cuas", layer = "OGRGeoJSON")
# cuas <- geojson_read("pct-bigdata/national/cuas.geojson", what = "sp") # fails
# file.remove(lfs)
qtm(cuas)
nrow(cuas)
object.size(cuas) / 1000000 # 1 mb now!
nrow(cuas) # only 174 counties and unitary authorities
bbox(cuas)
cuas <- spTransform(cuas, CRSobj = CRS("+init=epsg:4326"))
qtm(cuas)
geojson_write(input = cuas, file = "pct-bigdata/national/cuas.geojson")
nrow(cuas)

# # # # # # # # #
# lsoa dataset  #
# # # # # # # # #

# dir <- "/media/robin/SAMSUNG/geodata/lsoa-2011/"
# eng_lsoa <- readOGR(dir, "infuse_lsoa_lyr_2011")
# object.size(eng_lsoa) / 1000000
# gMapshape(dsn = "/media/robin/SAMSUNG/geodata/lsoa-2011/infuse_lsoa_lyr_2011.shp", percent = 5)
# f <- list.files(dir, pattern = "5")
# file.copy(paste0(dir, f), paste0("pct-data/national/", f))

# Merge-in lsoa-level data, aggregated, to msoa
lsoas <- shapefile("private-data/terrain_shape.shp")

# Adding additional data (todo)

geoc_lsoas <- SpatialPointsDataFrame(gCentroid(lsoas, byid = T), lsoas@data)
geoc_lsoas <- spTransform(geoc_lsoas, CRS(proj4string(msoas)))

msoas <- shapefile("pct-data/national/infuse_msoa_lyr_2011mapshaped_5%.shp")
proj4string(msoas)
msoas_agg <- aggregate(geoc_lsoas, msoas, mean)
head(msoas_agg@data)

msoas$avslope <- msoas_agg$avslope
sheftest <- msoas[grep("Sheff", msoas@data$geo_label), ]
qtm(sheftest, fill = avslope)

# shapefile("pct-data/national/msoas.shp", msoas)
write.csv(msoas@data, "pct-data/national/avslope-msoa.csv")

# Preprocessing

# # New code (will need install_github("robinlovelace/pctpack") to work)
# dir <- "/media/robin/SAMSUNG/geodata/msoa-2011/infuse_msoa_lyr_2011.shp" # directory
# pctpack::gMapshape(dir, percent = 1)
# f <- list.files("/media/robin/SAMSUNG/geodata/msoa-2011/", pattern = "5", full.names = T)
# ft <- list.files("/media/robin/SAMSUNG/geodata/msoa-2011/", pattern = "5")
# ft <- paste0("pct-data/national/", ft)
# file.copy(f, ft)

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
# download.file(url, method = "curl", destfile = "private-data/ttwa.zip")
# unzip(zipfile = "private-data/ttwa.zip", exdir = "private-data/")
# ttw <- shapefile("private-data/TTWA_DEC_2007_EW_BGCmapshaped_5%.shp")

ttwa_name <- "cambridge" # name of the Travel to Work Area (must type this)
# gMapshape("private-data/TTWA_DEC_2007_EW_BGC.shp", percent = 1)
ttwa_all <- shapefile("private-data/TTWA_DEC_2007_EW_BGCmapshaped_1%.shp") # all zones
ttwa_all <- spTransform(ttwa_all, CRSobj = CRS("+init=epsg:4326"))
geojson_write(ttwa_all, file = "pct-data/national/ttwa_all.geojson")
