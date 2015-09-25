# Load gender equality for zones
source("set-up.R")

library(downloader)
# download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011_gen_clipped.tar.gz", "private-data/England_lad_2011_gen_clipped.tar.gz")
# untar(tarfile = "private-data/England_lad_2011_gen_clipped.tar.gz", exdir = "private-data/")
# gMapshape(dsn = "private-data/England_lad_2011_gen_clipped.shp", 4)
# las <- shapefile("private-data/England_lad_2011_gen_clippedmapshaped_4%.shp")
las <- shapefile("private-data/4perc-clean.shp")
plot(las)
las@data <- rename(las@data, GeographyCode = CODE)

las$GeographyCode <- as.character(las$GeographyCode)

head(las)
library(readr)

# link geographical zones to data
# https://wicid.ukdataservice.ac.uk/cider/info.php?geogtype=96&lablist=1
linkla <- read_csv("pct-bigdata/national/la-old-new.csv", col_types = "icccc")
head(linkla)
linkla <- rename(linkla, GeographyCode = ONS)
df <- read_csv("private-data/DC7101EWla_2011CMLADH_NAT_LAD_REL_1.1.1_20140228-1007-06168/DC7101EWla_2011CMLADH_NAT_LAD_REL_1.1.1/DC7101EWlaDATAA5.CSV")

head(df[1:4])
df <- left_join(df, linkla)
head(df[250:256])

summary(df$clc <- df$DC7101EWla0007 / df$DC7101EWla0001)
summary(df$clc_m <- df$DC7101EWla0124 / df$DC7101EWla0007)

df <- dplyr::select(df, CODE, GeographyCode, clc, clc_m)
head(df)
head(las$GeographyCode)
head(df$CODE) # they are the same

summary(las$GeographyCode %in% df$CODE)
las@data <- rename(las@data, CODE = GeographyCode)

head(las$CODE)
head(df$CODE)
las@data <- left_join(las@data, df, by = "CODE")

library(tmap)
qtm(las, "clc") # test the map makes sense
las@data[ which(las$clc > 0.1), ]
las$log_pcycle <- log(las$clc * 100)
tmap::qtm(shp = las, "log_pcycle")

# Analysis
head(las)
las$pcycle <- las$clc * 100
las$pmale <- las@data$clc_m * 100
las$log_pcycle <- log(las$pcycle)

tm_shape(las) +
  tm_fill(c("log_pcycle", "pmale"))

tm_shape(las) +
  tm_fill(c("pcycle", "pmale"), n = 4,
    title = c("% cycling", "% male"), style = "quantile", palette = list("Greens", "Reds"))

par(mfrow = c(2, 1))



library(gridExtra)
grid.arrange(p1, p2)

lasf <- fortify(las)
geom_polygon(data = lasf, )
head(lasf)

qplot(las$pcycle, las$pmale) +
  geom_smooth() +
  theme_bw() +
  ylab("% cycle commuters who are male") +
  xlab("% commutes made by bicycle")

las <- spTransform(las, CRS("+init=epsg:4326"))

# geojson_write(input = las, file = "pct-bigdata/national/las-pcycle.geojson")
# las_pcycle <- geojson_read("pct-bigdata/national/las-pcycle.geojson", what = "sp") # fail
las <- readOGR(dsn = "pct-bigdata/national/las-pcycle.geojson", layer = "OGRGeoJSON")



tmap::qtm(shp = las, "clc_m")

## Allocate age/sex split to cuas

cuas <- geojsonio::geojson_read("pct-bigdata/national/cuas.geojson", what = "sp")
las_c <- gCentroid(las, byid = T)
las_c <- SpatialPointsDataFrame(las_c, las@data)
isnum <- sapply(las_c@data, is.numeric)
las_c@data <- las_c@data[isnum]
las_c@data <- las_c@data["clc_m"]

library(sp)
cuas_m <- aggregate(las_c, cuas, mean)
head(cuas_m)
cuas$clc_m <- cuas_m$clc_m

tmap::qtm(cuas, "clc_m")

geojsonio::geojson_write(cuas, file = "pct-bigdata/national/cuas-mf.geojson")
