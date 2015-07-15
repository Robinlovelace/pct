# Aim: analyse potential of cycling uptake based on commute distance band
source("set-up.R")

# downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/infuse_dist_lyr_2011_clipped.zip", "lamerged.zip")
# unzip("lamerged.zip", exdir = "pct-bigdata/national/")
# downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011_gen_clipped.tar.gz", destfile = "private-data/")
# unzip("private-data/Eng")

las <- geojson_read("pct-bigdata/national/las-pcycle.geojson", what = "sp")
#
gMapshape("pct-bigdata/national/inf", percent = 5)
las <- shapefile("private-data/England_lad_2011_gen_clipped.dbf")

cuas <- shapefile("pct-bigdata/national/cuas.shp")
qtm(cuas)
plot(las)
qtm(las)
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

lasen <- las
lasen@data <- rename(lasen@data, geo_code = CODE)
qtm(lasen)
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
las$pcycle <- las@data$Bicycle_All / las$All_All * 100
tm_shape(las) +
  tm_fill("pcycle", style = "kmeans")

# All trips of a certain distance
names(las)
select(las@data, contains("[0"))

luk <- readRDS("pct-bigdata/national/l_sam8.Rds")
luk <- luk@data
head(luk)
luk$dband <- cut(luk$dist, breaks = c(0, 2, 5, 10, 20, 30, 40, 60, 200))
plot(luk$dband)

# select national flows representative of area 1
las$`All_[0,2)`[1]
las$All_sub10 <- las$`All_[0,2)` +
  las$`All_[2,5)` +
  las$`All_[5,10)`

luk0 <- luk[luk$dband == "(0,2]",]
luk2 <- luk[luk$dband == "(2,5]",]
luk5 <- luk[luk$dband == "(5,10]",]

i = 1 # for testing outside for loop
las$expected <- NA

for(i in 1:nrow(las)){
# for(i in 1:5){

lz0 <- luk0[sample(nrow(luk0), 10),] # start with a random sample
lz2 <- luk2[sample(nrow(luk2), 10),]
lz5 <- luk5[sample(nrow(luk5), 10),]

while(
  # Are any flows not enough?
  sum(lz0$All) < las$`All_[0,2)`[i] |
  sum(lz2$All) < las$`All_[2,5)`[i] |
  sum(lz5$All) < las$`All_[5,10)`[i]
    ) {

  # short distances
  sel0 <- luk0[sample(nrow(luk0), 1),]
  if(sum(lz0$All) < las$`All_[0,2)`[i]){
    lz0 <- rbind(lz0, sel0)
  }

  # mid distances
  sel2 <- luk2[sample(nrow(luk2), 1),]
  if(sum(lz2$All) < las$`All_[2,5)`[i]){
    lz2 <- rbind(lz2, sel2)
  }

  # long distances
  sel5 <- luk5[sample(nrow(luk5), 1),]
  if(sum(lz5$All) < las$`All_[5,10)`[i]){
    lz5 <- rbind(lz5, sel5)
  }
}

lz <- rbind(lz0, lz2, lz5)

# estimated rate of cycling in our model

mod_nat <- readRDS("pct-bigdata/national/mod_logsqr_national_8.Rds")
lz$npred <- exp(predict(mod_nat, lz))
lz$expected <- lz$All * lz$npred

las@data$All_sub10_sim[i] <- sum(lz$All)
las@data$Bicycle_All[i]
las$expected[i] <- sum(lz$expected)
print(i)
}

cor(las@data$All_sub10, las@data$All_sub10_sim)

summary(las@data$expected)

las$cdp <- las$Bicycle_All + las$expected
las@data$pcycle_exp <- las$expected / las$All_All * 100

plot(las$Bicycle_All, las$expected)
cor(las$Bicycle_All, las$expected)
plot(las$pcycle, las$pcycle_exp)
cor(las$pcycle, las$pcycle_exp)
cor(las$Bicycle_All, las$cdp)
sum(las$Bicycle_All) / sum(las$cdp)

# save it - don't use geojson as it destroys geometry
# geojson_write(las, file = "pct-bigdata/national/las-alltrips.geojson")
# saveRDS(las@data, "pct-bigdata/national/las-data.Rds")
# lasdata <- readRDS("pct-bigdata/national/las-data.Rds")
# las@data <- lasdata
# saveRDS(las, "pct-bigdata/national/las.Rds")
