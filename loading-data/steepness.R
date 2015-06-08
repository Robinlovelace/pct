# # # # # # # # # # #
# UK slope analysis #
# # # # # # # # # # #

# Packages we'll be using
pkgs <- c("raster", "rgdal", "rgeos", "ggmap", "dplyr")
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
# proj4string(ukslope) <- CRS("+init=epsg:4326")
# ukslope2 <- projectRaster(ukslope, crs = CRS("+init=epsg:27700"))
# ukslope2 # to find resolution

# # # # # # # # # # # # # # # # #
# Download latest 90m res data  #
# See http://srtm.csi.cgiar.org/#
# Select tiles manually         #
# # # # # # # # # # # # # # # # #

# For Netherlands
nl <- getData(name = 'GADM', country = "NLD", level = 0)
library(downloader)
download("https://github.com/johan/world.geo.json/raw/master/countries/NLD.geo.json", destfile = "/tmp/NLD.geojson")
library(geojsonio)
nl <- geojson_read("/tmp/NLD.geojson")
bbox(nl)
url <- "ftp://srtm.csi.cgiar.org/SRTM_V41/SRTM_Data_GeoTiff/" # base url

tiles <- c("srtm_37_02.zip", "srtm_38_02.zip")
for(i in tiles){
  # download.file(paste0(url, i), destfile = paste0("private-data/", i), method = "curl")
  unzip(paste0("private-data/", i), exdir = "private-data/")
}

# For UK
# which tiles are you interested in?
# tiles <- c("srtm_35_02.zip", "srtm_36_02.zip", "srtm_37_02.zip", "srtm_35_01.zip", "srtm_36_01.zip" )
# paste0(url, tiles)

# # Download files in a loop - warning: takes some time!
# for(i in tiles){
#   download.file(paste0(url, i), destfile = paste0("private-data/", i), method = "curl")
#   unzip(paste0("private-data/", i), exdir = "private-data/")
# }

# # # # # # # #  #
# Load srtm data #
# # # # # # # #  #

f <- list.files(path = "private-data/", pattern = paste(gsub(".zip", ".tif", tiles), sep = "|", collapse = "|"), full.names = T)
uksrtm <- raster(f[1])
for(i in f[-1]){
  uksrtm <- raster::merge(uksrtm, raster(i))
}

proj4string(uksrtm) <- CRS("+init=epsg:4326")
writeRaster(uksrtm, filename = "/tmp/nl-alts.geotiff")
uksrtm2 <- projectRaster(uksrtm, crs = CRS("+init=epsg:27700")) # warning: not necessary, computationally intensive
uksrtm2 # to find resolution

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
# writeRaster(ukslope, filename = "private-data/dutchslope.asc")
# writeRaster(ukslope, filename = "private-data/dutchslope.tif")
# ukslope <- raster("private-data/ukslope.grd")
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
# writeOGR(eng_lsoa, dsn = "private-data/", layer = "terrain_shape", driver = "ESRI Shapefile")

# # # # # #
# Merging #
# Binning #
# # # # # #

tomerge <- read.csv("/tmp/England_pcycle2011_LSOA11.csv")
head(tomerge)
unique(tomerge$pcycle11) # 22 unique bins
head(eng_lsoa@data)
bins <- quantile(avslope, probs = seq(0, 1, length.out = 21), na.rm = T)
avslope_binned <- cut(avslope, bins)
eng_lsoa$avslope_binned <- avslope_binned
frommerge <- eng_lsoa@data

# Prepare for merge
tomerge <- rename(tomerge, geo_code = lsoacode_11)
tomerge$geo_label <- as.character(tomerge$geo_label)
frommerge$geo_label <- as.character(frommerge$geo_label)
head(tomerge$geo_code)
head(frommerge$geo_code)
merged <- inner_join(tomerge, frommerge)
summary(merged$avslope_binned)
# write.csv(merged, "/tmp/merged.csv")

# Re-aggregate data to different levels

lsoas <- shapefile("private-data/terrain_shape.shp")
msoas <- shapefile("pct-data/national/infuse_msoa_lyr_2011mapshaped_5%.shp")
head(avslope)
head()

lsoas@data <- inner_join(lsoas@data)

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
