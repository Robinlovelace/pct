# # # # # # # # # # #
# UK slope analysis #
# # # # # # # # # # #

# Packages we'll be using
pkgs <- c("raster", "rgdal", "rgeos", "ggmap")
lapply(pkgs, library, character.only = TRUE)

# # # # # # # # # # # # # # # #
# Load the UK elevation data  #
# -> convert to slope         #
# # # # # # # # # # # # # # # #

# # # # # # # # # # # # # #
# Load ~1km raster data)  #
# # # # # # # # # # # # # #

# ukterrain <- getData(name = 'alt', download = T, country = "GBR", level = 1)
# ukterrain <- getData(name = 'alt', download = F, path = "/media/robin/SWIVEL/Robin/", country = "GBR", level = 1)
# ukslope <- terrain(x = ukterrain, opt = "slope", unit = "degrees")
# plot(ukslope)
# writeRaster(x = ukslope, "pct-data/ukslope.asc", "ascii")
# ukslope <- raster("pct-data/ukslope.asc")

# # # # # # # # # # # # # # # # #
# Download latest 90m res data  #
# See http://srtm.csi.cgiar.org/#
# # # # # # # # # # # # # # # # #

# url <- "ftp://srtm.csi.cgiar.org/SRTM_V41/SRTM_Data_GeoTiff/" # base url
# # which tiles are you interested in?
# tiles <- c("srtm_35_02.zip", "srtm_36_02.zip", "srtm_37_02.zip", "srtm_35_01.zip", "srtm_36_01.zip" )

# # Download files in a loop - warning: takes some time!
# for(i in tiles){
#   download.file(paste0(url, i), destfile = paste0("bigdata/", i), method = "curl")
#   unzip(paste0("bigdata/", i), exdir = "bigdata/")
# }

# # # # # # # #  #
# Load srtm data #
# # # # # # # #  #

# f <- list.files(path = "bigdata/", pattern = ".tif", full.names = T)
# uksrtm <- raster(f[1])
# for(i in f[-1]){
#   uksrtm <- raster::merge(uksrtm, raster(i))
# }

# # # # # # # # #
# lsoa dataset  #
# # # # # # # # #

# dir <- "/media/robin/SAMSUNG/geodata/lsoa-2011/"
# eng_lsoa <- readOGR(dir, "infuse_lsoa_lyr_2011")
# object.size(eng_lsoa) / 1000000
# gMapshape(dsn = "/media/robin/SAMSUNG/geodata/lsoa-2011/infuse_lsoa_lyr_2011.shp", percent = 5)
# f <- list.files(dir, pattern = "5")
# file.copy(paste0(dir, f), paste0("pct-data/national/", f))

# # # # # # # # # #
# Read local data #
# # # # # # # # # #

eng_lsoa <- readOGR("pct-data/national/", "infuse_lsoa_lyr_2011mapshaped_5%")
eng_lsoa <- spTransform(eng_lsoa, CRS("+init=epsg:4326"))
eng_lsoa_cents <- gCentroid(eng_lsoa, byid = T)

# Run on full dataset
# avalt <- raster::extract(uksrtm, eng_lsoa, method = 'bilinear', fun = mean, na.rm = T)
# write.csv(avalt, "pct-data/national/avalt-lsoas.csv")

# # # # # # # # # # # # # #
# Convert height to slope #
# # # # # # # # # # # # # #

# ukslope <- terrain(uksrtm, opt = "slope", unit = "degrees")
# writeRaster(ukslope, filename = "bigdata/ukslope.grd")
# ukslope <- raster("bigdata/ukslope.grd")
# system.time(
# avslope <- raster::extract(ukslope, eng_lsoa, method = 'bilinear', fun = mean, na.rm = T)
#   )
# write.csv(avslope, "pct-data/national/avslope-lsoas.csv")

# # # # # # # # # # # #
# Read-in local data  #
# # # # # # # # # # # #

avalt <- read.csv("pct-data/national/avalt-lsoas.csv")$x
avslope <- read.csv("pct-data/national/avslope-lsoas.csv")$x
eng_lsoa$avalt <- avalt
eng_lsoa$avslope <- avslope

# # # # # # # #
# Export data #
# # # # # # # #

# write.csv(eng_lsoa@data, "/tmp/height-slope.csv")
# writeOGR(eng_lsoa, dsn = "bigdata/", layer = "terrain_shape", driver = "ESRI Shapefile")

# # # # #
# Tests #
# # # # #

# # Convert hilliness raster to lsoa: test with 900m res data:
# sel <- eng_lsoa_cents[ leeds, ]
# plot(sel)
# sel2 <- eng_lsoa[ row.names(sel), ]
# plot(ukslope, add = T)
# plot(sel2, add = T)
# avslop <- raster::extract(ukslope, sel2, method = 'bilinear', fun = mean)
# sel2$avslop <- avslop
# plot(sel2)
# plot(sel2[ is.na(avslop),  ], add = T, col = "red")

# # Test with 90m res data:
# lrast <- raster::crop(uksrtm, bbox(leeds))
# lrast <- terrain(lrast, opt = "slope", unit = "degrees")
# plot(lrast)
# plot(sel2, add = T)
# avslop <- raster::extract(lrast, sel2, method = 'bilinear', fun = mean, na.rm = T)
