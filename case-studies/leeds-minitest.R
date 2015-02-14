# # # # #
# setup #
# # # # #

source("set-up.R") # load required packages
# source("geo-load//load-leeds.R") # load geographical data for leeds

# # # # # # # # # # #
# create test data  #
# # # # # # # # # # #

# # Subset zones in circle with geo-central leeds
# lcentre <- gCentroid(leeds)
# lcentre <- gBuffer(lcentre, width = 5000)
#
# plot(lcentre, add = T)
# lcents <- gCentroid(leeds, byid = T)
# sel <- as.logical(gWithin(leeds, lcentre, byid = TRUE))
# leeds <- leeds[ sel, ]
# plot(leeds)
# writeOGR(leeds, dsn = "pct-data/leeds/", layer = "leeds-central-sample-large",
#   driver = "ESRI Shapefile")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Needs mapshaper installed - thanks to Richard Ellison #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # Heavily simplify the shape. Warning - this will change the centroid results
# system('mapshaper pct-data/leeds/leeds-central-sample-large.shp auto-snap -simplify keep-shapes 1% -o force pct-data/leeds/leeds-central-sample.shp',wait=TRUE)

# Set file location (will vary - download files from here:
# https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
# f <- "/media/robin/data/data-to-add/public-flow-data-msoa/wu03ew_v2.csv"
# flowm <- read.csv(f) # load public msoa-level flow data
# o_in_leeds <- flowm$Area.of.residence %in% leeds$geo_code
# d_in_leeds <- flowm$Area.of.workplace %in% leeds$geo_code
#
# fleeds <- flowm[ o_in_leeds & d_in_leeds , ]
# write.csv(fleeds, "pct-data/leeds/sample-leeds-centre-msoa.csv")
# gDistance(leeds[1,], leeds[2,]) # test the calculation of distances
#
# fleeds$dist <- NA # create distance field
# dir.create("pct-data/leeds")

# # Calculate distance between OD pairs in Leeds. Warning: time consuming
# # for(i in 1:100){ # test the loop (uncomment + skip next line to test)
# for(i in 1:nrow(fleeds)){
#   from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
#   to <- leeds$geo_code %in% fleeds$Area.of.workplace[i]
#   fleeds$dist[i] <- gDistance(lcents[from, ], lcents[to, ])
#   if(i %% round(nrow(fleeds) / 100) == 0)
#     print(paste0(100 * i/nrow(fleeds), " % out of ", nrow(fleeds),
#       " distances calculated"))
# }

# # # # # # # # # # # #
# Load the test data  #
# (Available online)  #
# # # # # # # # # # # #

fleeds <- read.csv("pct-data/leeds/sample-leeds-centre-msoa.csv")
leeds <- readOGR("pct-data/leeds/", "leeds-central-sample")
lcents <- gCentroid(leeds, byid = T) # centroids of the data

gDistance(lcents[1,], lcents[2,]) # test the calculation of distances

fleeds$dist <- NA # create distance field

# Calculate distance between OD pairs in Leeds. Warning: time consuming
# for(i in 1:100){ # test the loop (uncomment + skip next line to test)
for(i in 1:nrow(fleeds)){
  from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
  to <- leeds$geo_code %in% fleeds$Area.of.workplace[i]
  fleeds$dist[i] <- gDistance(lcents[from, ], lcents[to, ])
  if(i %% round(nrow(fleeds) / 10) == 0)
    print(paste0(100 * i/nrow(fleeds), " % out of ", nrow(fleeds),
      " distances calculated")) # print % of distances calculated
}

# Estimate propensity to cycle
# Distance-decay function (Iacono et al. 2011)
iac <- function(x, a = 0.3, b = 0.2){
  a * exp(1)^(-b * x)
}
iac(1:10)

# Expected number who cycle
fleeds$pcycle <- fleeds$Bicycle / fleeds$All.categories..Method.of.travel.to.work
fleeds$pcp <- iac(fleeds$dist / 1000)
fleeds$pcp_n <- fleeds$pcp * fleeds$All.categories..Method.of.travel.to.work

# Propensity to cycle
fleeds$pc1 <- fleeds$pcp_n - fleeds$Bicycle
summary(fleeds$pc1)

# write.csv(fleeds, "pct-data/leeds/sample-leeds-centre-dists.csv")
d0 <- fleeds$dist == 0 # internal flows
flow <- fleeds[ !d0, ]

# All flows
plot(leeds)
for(i in 1:nrow(flow)){
# for(i in 1:20){
  from <- leeds$geo_code %in% flow$Area.of.residence[i]
  to <- leeds$geo_code %in% flow$Area.of.workplace[i]
  x <- coordinates(leeds[from, ])
  y <- coordinates(leeds[to, ])
  lines(c(x[1], y[1]), c(x[2], y[2]), lwd = flow$pc1[i] / 10 )
}

# Create SpatialLines
l <- vector("list", nrow(flow))

for(i in 1:nrow(flow)){
  from <- leeds$geo_code %in% flow$Area.of.residence[i]
  to <- leeds$geo_code %in% flow$Area.of.workplace[i]
  x <- coordinates(leeds[from, ])
  y <- coordinates(leeds[to, ])
  l[[i]] <- Lines(list(Line(rbind(x, y))), as.character(i))
}

l <- SpatialLines(l)
l <- SpatialLinesDataFrame(l, data = flow, match.ID = F)
# plot(l)

# writeOGR(l, "/tmp/", layer = "testlines", "ESRI Shapefile")

