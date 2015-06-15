# Aim: load population-weighted centroids

# Load centroid data (strategy: load all data to these first for model)
cents <- shapefile("private-data/centroids/MSOA_2011_EW_PWC.shp") # pop. weighted cents
cents@data <- rename(cents@data, geo_code = MSOA11CD)

# Add age by distance to centroids

# Add gender balance of cyclists
# From http://www.ons.gov.uk/ons/guide-method/geography/products/census/spatial/centroids/index.html
# oaps <- shapefile("private-data/centroids/OA_2011_EW_PWC.shp")

oagen_mode <- read.csv("private-data/msoa-2011-sex-method-ttw-nomis-lc7103ew.csv", stringsAsFactors = F)
# oagen_mode <- read.csv("private-data/LC7103EW_2011STATH_NAT_OA_REL_1.1.1_20140319-0942-19509/LC7103EW_2011STATH_NAT_OA_REL_1.1.1/LC7103EWDATA05.CSV", stringsAsFactors = F)
names(oagen_mode)
oagen_mode$fem <- oagen_mode$Sex..Females..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value / (oagen_mode$Sex..Males..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value + oagen_mode$Sex..Females..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value)

oagen_mode <- dplyr::select(oagen_mode, geo_code = geography.code, percent_fem = fem)

cents@data <- left_join(cents@data, oagen_mode)
cents@data <- left_join(cents@data, cents@data)

summary(cents)

# Check the area is correct
plot(ttwa_zone, lwd = 4)
points(cents)
plot(zones, col = "red", add = T)

# # # # # # # # # # #
# Add height data   #
# (see steepness.R) #
# # # # # # # # # # #

msoa_slopes <- read.csv("pct-data/national/avslope-msoa.csv")
head(msoa_slopes)
msoa_slopes <- dplyr::select(msoa_slopes, geo_code, avslope)
head(zones@data)
cents@data <- left_join(cents@data, msoa_slopes)

cents <- spTransform(cents, CRSobj = CRS("+init=epsg:4326"))
# After load-cents.R and library(geojsonio)
geojson_write(cents, file = "pct-data/national/cents.geojson")

# Test load
# cents <- readOGR("pct-data/national/cents.geojson", layer = "OGRGeoJSON")
