# # Attempt 1 fails due to not having cycling as a mode: abandon
# download("https://www.nomisweb.co.uk/output/census/2011/lc7103ew_oa.zip", "bigdata/lc7103ew_oa.zip")
# unzip("bigdata/lc7103ew_oa.zip", exdir = "bigdata/")
# df <- read.csv("bigdata/LC7103EW_2011STATH_NAT_OA_REL_1.1.1_20140319-0942-19509/LC7103EWDATA.CSV")
# head(df)

# From LA data
# download("https://www.nomisweb.co.uk/output/census/2011/dc7101ewla.zip", "bigdata/dc7101ewla.zip")
# unzip("bigdata/dc7101ewla.zip", exdir = "bigdata/")
# download("https://github.com/Robinlovelace/cycling-chd/raw/master/data/las.geojson", "pct-bigdata/national/las.geojson")
# las <- geojson_read("pct-bigdata/national/las.geojson") # features
# las <- readOGR("pct-bigdata/national/las.geojson", layer = "OGRGeoJSON")

download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011_gen_clipped.tar.gz", "bigdata/England_lad_2011_gen_clipped.tar.gz")
untar(tarfile = "bigdata/England_lad_2011_gen_clipped.tar.gz", exdir = "bigdata/")
las <- shapefile("bigdata/England_lad_2011_gen_clipped.shp")
las@data <- rename(las@data, GeographyCode = CODE)


# They are not linking: need to change codes
library(stringr)
las$geocode <- str_sub(las$GeographyCode, start = -3, end = -1)
df$geocode <- str_sub(df$GeographyCode, start = -3, end = -1)
summary(las$geocode %in% df$geocode)

# which values in the join are not working?
las@data$GeographyCode[las$geocode == "014"]
df$GeographyCode[grepl("14", df$geocode)]
sort(df$GeographyCode)
sort(las$GeographyCode) # illustratest patter

# fit by order?
df$ord <- order(df$GeographyCode)
las$ord <- order(las$GeographyCode)






download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/infuse_dist_lyr_2011.tgz", "infuse_dist_lyr_2011.tgz")
untar(tarfile = "infuse_dist_lyr_2011.tgz", exdir = "bigdata/")
las <- shapefile("bigdata/infuse_merging_district_lyr_2011.shp")
