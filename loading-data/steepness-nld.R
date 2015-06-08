# # # # # # # # # # #
# NL slope analysis #
# # # # # # # # # # #

# Packages we'll be using
pkgs <- c("raster", "rgdal", "rgeos", "ggmap", "dplyr")
lapply(pkgs, library, character.only = TRUE)

# # # # # # # # # # # # # # # #
# Load the UK elevation data  #
# -> convert to slope         #
# # # # # # # # # # # # # # # #

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
  download.file(paste0(url, i), destfile = paste0("private-data/", i), method = "curl")
  unzip(paste0("private-data/", i), exdir = "private-data/")
}

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
plot(uksrtm)

# # # # # # # # # #
# Read local data #
# # # # # # # # # #

nllsoa <- shapefile("private-data/dutch-geo/oppervlakte cbs buurten.shp")
summary(nllsoa)
proj4string(nllsoa) <- CRS("+init=epsg:28992")
nllsoa <- spTransform(nllsoa, CRS(proj4string(uksrtm)))
plot(nllsoa, add = T)

# # # # # # # # # # # # # #
# Convert height to slope #
# # # # # # # # # # # # # #

ukslope <- terrain(uksrtm, opt = "slope", unit = "degrees")
writeRaster(ukslope, filename = "private-data/dutchslope.asc")
avslope <- raster::extract(ukslope, nllsoa, method = 'bilinear', fun = mean, na.rm = T)

summary(avslope)
nllsoa$avslope <- avslope
library(tmap)
write.csv(cbind(nllsoa@data$BU_CODE, nllsoa@data$avslope), "pct-data/national/avslope-nl.csv")
shapefile("private-data/avslope-nl.shp", nllsoa)
