# Load gender equality

library(downloader)

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

# download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011_gen_clipped.tar.gz", "bigdata/England_lad_2011_gen_clipped.tar.gz")
# untar(tarfile = "bigdata/England_lad_2011_gen_clipped.tar.gz", exdir = "bigdata/")
las <- shapefile("bigdata/England_lad_2011_gen_clipped.shp")
head(las)
las@data <- rename(las@data, GeographyCode = CODE)
las$GeographyCode <- as.character(las$GeographyCode)

head(las)
library(readr)
df <- read_csv("bigdata/DC7101EWla_2011CMLADH_NAT_LAD_REL_1.1.1_20140228-1007-06168/DC7101EWla_2011CMLADH_NAT_LAD_REL_1.1.1/DC7101EWlaDATAA5.CSV")

names(df)
df <- df[!grepl("W", df$GeographyCode),]

summary(df$clc <- df$DC7101EWla0007 / df$DC7101EWla0001)
summary(df$clc_m <- df$DC7101EWla0124 / df$DC7101EWla0007)

df <- dplyr::select(df, GeographyCode, clc, clc_m)
summary(las$GeographyCode)
summary(df$GeographyCode)
summary(las$GeographyCode %in% df$GeographyCode)

# They are not linking: need to change codes
library(stringr)
las$geocode <- str_sub(las$GeographyCode, start = -3, end = -1)
df$geocode <- str_sub(df$GeographyCode, start = -3, end = -1)
summary(las$geocode %in% df$geocode)

las@data <- inner_join(las@data, df, by = "geocode")
head(las)
las$pcycle <- las$clc * 100

library(tmap)
tmap::qtm(shp = las, "pcycle")

library(ggmap)
ggsave("/tmp/pcycle.png")

