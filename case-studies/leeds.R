# # # # #
# setup #
# # # # #

source("set-up.R") # load required packages

# # # # # # # # # # # # #
# Load Leeds data       #
# No need to run this   #
# # # # # # # # # # # # #

# Load public access flow data
# Set file location (will vary - download files from here:
# https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
# f <- "/media/robin/data/data-to-add/public-flow-data-msoa/wu03ew_v2.csv"
# flowm <- read.csv(f) # load public msoa-level flow data
# o_in_leeds <- flowm$Area.of.residence %in% leeds$geo_code
# d_in_leeds <- flowm$Area.of.workplace %in% leeds_outer$geo_code
#
# fleeds <- flowm[ o_in_leeds & d_in_leeds , ]
# write.csv(fleeds, "pct-data/leeds/msoa-flow-leeds-wider.csv")
# saveRDS(fleeds, "pct-data/leeds/msoa-flow-leeds-wider.Rds")

# # # # # # # # # # # #
# Load the test data  #
# (Available online)  #
# # # # # # # # # # # #

# Load the geographical data
leeds <- readRDS("pct-data/leeds/leeds-msoas-simple.Rds")
leeds_outer <- readRDS("pct-data/leeds/outer-points.Rds")
# Load the flow data
fleeds <- readRDS("pct-data/leeds/msoa-flow-leeds-wider.Rds")
buf <- readRDS("pct-data/leeds/10km-buffer.Rds")
cents <- gCentroid(leeds, byid = T) # centroids of the zones

fleeds$dist <- NA # create distance field

# Calculate distance between OD pairs in leeds
for(i in 1:nrow(fleeds)){
  from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
  to <- leeds$geo_code %in% fleeds$Area.of.workplace[i]
  fleeds$dist[i] <- gDistance(cents[from, ], cents[to, ])
  if(i %% round(nrow(fleeds) / 10) == 0)
    print(paste0(100 * i/nrow(fleeds), " % out of ", nrow(fleeds),
      " distances calculated")) # print % of distances calculated
}

# Propensity to cycle
fleeds$p_cycle <- iac(fleeds$dist / 1000)
fleeds$pc <- fleeds$p_cycle * fleeds$All.categories..Method.of.travel.to.work

# Extra cycling potential
fleeds$ecp <- fleeds$pc - fleeds$Bicycle
summary(fleeds$ecp)
summary(fleeds$Bicycle)

# Actual rate of cycling
plot(leeds)
lwd <- fleeds$Bicycle / mean(fleeds$Bicycle) * 0.1
for(i in 1:nrow(fleeds)){
  from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
  to <- leeds_outer$geo_code %in% fleeds$Area.of.workplace[i]
  x <- coordinates(leeds[from, ])
  y <- coordinates(leeds_outer[to, ])
  lines(c(x[1], y[1]), c(x[2], y[2]), lwd = lwd, col = "blue" )
}

# Model estimate of cycling
plot(leeds)
for(i in 1:nrow(fleeds)){
  from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
  to <- leeds_outer$geo_code %in% fleeds$Area.of.workplace[i]
  x <- coordinates(leeds[from, ])
  y <- coordinates(leeds_outer[to, ])
  lines(c(x[1], y[1]), c(x[2], y[2]), lwd = fleeds$pc[i] / 400 )
}

# Compare estimated and actual number of cyclists
plot(fleeds$Bicycle, fleeds$pc)
cor(fleeds$Bicycle, fleeds$pc)