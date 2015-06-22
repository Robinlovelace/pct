# Aim: analyse potential of cycling uptake based on commute distance band
source("set-up.R")

# downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/infuse_dist_lyr_2011_clipped.zip", "lamerged.zip")
# unzip("lamerged.zip", exdir = "pct-bigdata/national/")
# downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011_gen_clipped.tar.gz", destfile = "private-data/")
# unzip("private-data/Eng")

las <- geojson_read("pct-bigdata/national/las-pcycle.geojson", what = "sp")
# gMapshape("pct-bigdata/national/infuse_dist_lyr_2011_clipped.shp", percent = 0.1)
# las <- shapefile("pct-bigdata/national/infuse_dist_lyr_2011_clippedmapshaped_0.1%.shp")

cuas <- shapefile("pct-bigdata/national/cuas.shp")
qtm(cuas)
plot(las)
nrow(las)
names(las)

ldf <- read_csv("pct-bigdata/national/lattw.csv")

# link for joining old/new codes
linkla <- read_csv("pct-bigdata/national/la-old-new.csv", col_types = "icccc")
head(linkla)
ldf$geography
names(ldf)[3] <- "ONS"
head(ldf$ONS)
head(linkla$ONS)
head(linkla$CODE)
ldf <- inner_join(ldf, linkla)

# process ttw data

names(ldf)
dbands <- levels(cut(1:200, breaks = c(0, 2, 5, 10, 20, 30, 40, 60, 200), right = F))
dbands <- c("All", dbands, "MfH", "other")

names(ldf[4:12]) # that's captured the distance bands
justmode <- gsub(pattern = "Method of travel to work: ", replacement = "", names(ldf))
justmode <- gsub(pattern = "; Distance travelled.+", replacement = "", justmode)
justmode <- unique(justmode)
justmode <- justmode[4:12]
justmode <- c("All",
  "MfH",
  "Rail",
  "Bus",
  "Car",
  "Passenger",
  "Bicycle",
  "Foot",
  "Other"
  )

col_names <- rep(dbands, length(justmode))
justmode_exp <- rep(justmode, each = length(dbands))
allnames <- paste(justmode_exp, col_names, sep = "_")
allnames[1:50]
names(ldf)[4:53]
names(ldf)[(1:99) + 3] <- allnames

lasen <- shapefile("private-data/England_lad_2011_gen_clippedmapshaped_4%.shp")
lasen@data <- rename(lasen@data, geo_code = CODE)
head(lasen)
names(las)
head(las)

# head(las@data$CODE)
if(is.null(las@data$geo_code)){
  las@data <- rename(las@data, geo_code = CODE)
}
head(las@data$geo_code)
lasen@data <- left_join(lasen@data, las@data)
ldf <- rename(ldf, geo_code = CODE)
head(ldf$geo_code)
las <- lasen


ldf2 <- left_join(las@data, ldf)
summary(ldf2)
summary(las$geo_code == ldf2$geo_code)
head(las)
las@data <- left_join(las@data, ldf2)


# Debugging join to contain no data
ldf2[1:3, 1:20]
ldf2$geo_label[grepl(pattern = "E", las$geo_code) & is.na(las$All_All)]
ldf$geography[grepl(pattern = "Corn", ldf$geography)]
ldf$geo_code[grepl(pattern = "Corn", ldf$geography)]
ccode <- las$geo_code[grepl(pattern = "Corn", las$geo_label)]
plot(las[grepl(pattern = "Corn", las$geo_label),])
ldf$geo_code[ldf$ONS == ccode]
las$geo_code[grepl(pattern = "Corn", las$geo_label)] <- ldf$geo_code[ldf$ONS == ccode]
ldf2 <- left_join(las@data, ldf)
ldf2[grepl("Corn", ldf2$geo_label),]
las@data <- ldf2

names(las)
las <- las[!is.na(las@data$All_All),]
qtm(las, "Foot_[5,10)")
qtm(las, "Car_[40,60)", fill.palette = "Reds")
las$shortcar <- las@data$`Car_[0,2)` / las@data$`All_[0,2)`
# geojson_write(las, file = "pct-bigdata/national/las-dbands.geojson")
# las <- geojson_read("pct-bigdata/national/las-dbands.geojson", what = "sp")

las@data$NAME[is.na(las$`Foot_[5,10)`)]

qtm(las, "All_All", fill.palette = "Reds")

bbox(las)
las <- spTransform(las, CRSobj = CRS("+init=epsg:4326"))

qtm(las, "shortcar", fill.palette = "YlOrRd", scale = 0.7)
nrow(las)

# las <- las[!is.na(las$All_All),]
las2 <- las[!is.na(las$All_All),]
qtm(las2) # error: the selection breaks continuity...
las$shortcar <- las$shortcar * 100

library(leaflet)

# Leaflet map
qpal <- colorQuantile(palette = "YlOrRd", las$shortcar, n = 5)
qpal <- colorBin(palette = "YlOrRd", las$shortcar, bins = 5)
leaflet(las) %>%
  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>%
  addPolygons(color = ~qpal(shortcar), fillOpacity = 0.7, smoothFactor = 0.2, weight = 1) %>%
  addLegend(pal = qpal, values = ~shortcar, opacity = 1)


object.size(las) / 1000000

lasen <- las[grepl(pattern = "E", las@data$geo_code),]
bbox(cuas)
bbox(las)
las_outline <- gBuffer(cuas, width = 0.001)
plot(las_outline)
plot(lasen)
qtm(lasen)
