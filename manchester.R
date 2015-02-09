# # # # #
# setup #
# # # # #

source("set-up.R") # load required packages

# # # # # # # # # # # # #
# Load Manchester data  #
# No need to run this   #
# # # # # # # # # # # # #

# Load public access flow data
# Set file location (will vary - download files from here:
# https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
# f <- "/media/robin/data/data-to-add/public-flow-data-msoa/wu03ew_v2.csv"
# flowm <- read.csv(f) # load public msoa-level flow data
# o_in_manc <- flowm$Area.of.residence %in% manc$geo_code
# d_in_manc <- flowm$Area.of.workplace %in% manc$geo_code
#
# fmanc <- flowm[ o_in_manc & d_in_manc , ]
# write.csv(fmanc, "pct-data/manchester/msoa-flow-manc.csv")

# # # # # # # # # # # #
# Load the test data  #
# (Available online)  #
# # # # # # # # # # # #

# Load the geographical data
manc <- readOGR("pct-data/manchester/", "manc-msoa-lores")

# Load the flow data
fmanc <- read.csv("pct-data/manchester/msoa-flow-manc.csv")
cents <- gCentroid(manc, byid = T) # centroids of the zones

fmanc$dist <- NA # create distance field

# Calculate distance between OD pairs in Manchester
for(i in 1:nrow(fmanc)){
  from <- manc$geo_code %in% fmanc$Area.of.residence[i]
  to <- manc$geo_code %in% fmanc$Area.of.workplace[i]
  fmanc$dist[i] <- gDistance(cents[from, ], cents[to, ])
  if(i %% round(nrow(fmanc) / 10) == 0)
    print(paste0(100 * i/nrow(fmanc), " % out of ", nrow(fmanc),
      " distances calculated")) # print % of distances calculated
}

# Propensity to cycle
fmanc$p_cycle <- iac(fmanc$dist / 1000)
fmanc$n_cycle <- fmanc$p_cycle * fmanc$All.categories..Method.of.travel.to.work

# Extra cycling potential
fmanc$ecp <- fmanc$n_cycle - fmanc$Bicycle
summary(fmanc$ecp)
summary(fmanc$Bicycle)

# write.csv(fmanc, "pct-data/manchester/manc-msoas-dists.csv")
summary(fmanc$dist)
# remove 0 distance points
fmanc <- fmanc[fmanc$dist > 0, ]

# Test plotting
plot(manc)
# for(i in 1:nrow(fmanc)){
for(i in 70:100){
  from <- manc$geo_code %in% fmanc$Area.of.residence[i]
  to <- manc$geo_code %in% fmanc$Area.of.workplace[i]
  x <- coordinates(manc[from, ])
  y <- coordinates(manc[to, ])
  lines(c(x[1], y[1]), c(x[2], y[2]), lwd = fmanc$ecp[i] )
}

# Compare estimated and actual number of cyclists
plot(fmanc$Bicycle, fmanc$n_cycle)
cor(fmanc$Bicycle, fmanc$n_cycle)


