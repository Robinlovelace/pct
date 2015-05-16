# nationalflow - aim run flow model on sample of national data

# Minimum flow between od pairs, subsetting lines. High means fewer lines.
mflow <- 30
mdist <- 10 # maximum euclidean distance (km) for subsetting lines

flow <- readRDS("pct-bigdata/national/flow.Rds")

set.seed(8)

flow <- flow[sample(nrow(flow), size = 10000),] # subset flows with o and d in study area
nrow(flow)
flow <- flow[grep(pattern = "E", x = flow$Area.of.residence),] # english days
flow <- flow[grep(pattern = "E", x = flow$Area.of.workplace),]

cents <- readOGR("pct-bigdata/national/cents.geojson", layer = "OGRGeoJSON")
cents <- spTransform(x = cents, CRSobj = CRS("+init=epsg:27700"))

# Allocate zone characteristics to flows
flow$avslope <- NA
for(i in 1:nrow(flow)){
  avslope_o <- cents$avslope[cents$geo_code == flow$Area.of.residence[i]]
  avslope_d <- cents$avslope[cents$geo_code == flow$Area.of.workplace[i]]
  # Note: there are more sophisticated ways to allocate hilliness to lines
  # E.g. by dividing the line into sections for each zone it crosses or
  # identifying the hilliness of the network-allocated path
  flow$avslope[i] <- (avslope_o + avslope_d) / 2 # calculate average slope
}

# Subset by total amount of flow
summary(flow$All)
summary(flow$avslope)
nrow(flow)
flow <- flow[flow$All > mflow, ]
nrow(flow) # dramatically reduces n. flows

flow$id <- paste(flow$Area.of.residence, flow$Area.of.workplace)

l <- gFlow2line(flow = flow, zones = cents)
plot(cents)
lines(l, col = "red") # show the lines on the map


# # # # # # # # # # # # # # # # # #
# Calculate flow-level variables: #
# distances and olc for ag. model #
# # # # # # # # # # # # # # # # # #

# Calculate distances (eventually use route distance)
proj4string(l) <- proj4string(cents)
flow$dist <- gLength(l, byid = T) / 1000 # Euclidean distance

# Transform CRS for plotting
zones <- spTransform(zones, CRS("+init=epsg:4326"))
cents <- spTransform(cents, CRS("+init=epsg:4326"))
l <- spTransform(l, CRS("+init=epsg:4326"))

# merge flow data with lines
nrow(l)
nrow(flow)
l@data <- flow # copy flow data across
# l <- readRDS(paste0("pct-bigdata/", la, "/l_all.Rds")) # regenerate l at this point

# # # # # # # # # # # # # # # # #
# Subset lines to plotting area #
# # # # # # # # # # # # # # # # #

# Subset data to reduce overheads for plotting
nrow(l)
l_b4_sub <- l # backup data

# Subset by distance
summary(l$dist)
l <- l[l$dist < mdist,]
l <- l[l$dist > 0, ] # to remove flows of 0 length
nrow(l)

# # # # # # # # # # # # # # #
# Allocate flows to network #
# Warning: time-consuming!  #
# Needs CycleStreet.net API #
# # # # # # # # # # # # # # #

# Create local version of lines; if there are too many in the TTWA, sample!
l_local_sel <- l@data$Area.of.residence %in% zones$geo_code &
  l@data$Area.of.workplace %in% zones$geo_code
if(nrow(l) > 2 * sum(l_local_sel) & nrow(l) > 5000){ # sample if too many lines
  l_all <- l
  f <- list.files(paste0("pct-data/", la, "/"))
  if(sum(grepl("l_all", f)) == 0) saveRDS(l, paste0("pct-data/", la, "/l_all.Rds"))
  #   l <- readRDS(paste0("pct-data/", la, "/l_all.Rds")) # restart point
  set.seed(2050)
  # sample from all routes in the TTWZ - change 1 for different % outside zone
  lsel <- sample(which(!l_local_sel), size = sum(l_local_sel) * 1)
  lsel <- c(lsel, which(l_local_sel))
  length(lsel)
  l <- l_all[lsel, ] # subset the lines
  plot(l)
  lines(l[2000:2600,], col = "blue") # ensure we have all the local ones
}

# Create route allocated lines
if(length(grep("rf_ttwa.Rds|rq_ttwa.Rds", list.files(paste0("pct-data/", la)))) >= 2){
  rf <- readRDS(paste0("pct-data/", la, "/rf_ttwa.Rds")) # if you've loaded them
  rq <- readRDS(paste0("pct-data/", la, "/rq_ttwa.Rds"))
} else{
  rf <- gLines2CyclePath(l[ l$dist > 0, ])
  rq <- gLines2CyclePath(l[ l$dist > 0, ], plan = "quietest")

  # Process route data
  rf$length <- rf$length / 1000
  rq$length <- rq$length / 1000
  saveRDS(rf, paste0("pct-data/", la, "/rf_ttwa.Rds")) # save the routes
  saveRDS(rq, paste0("pct-data/", la, "/rq_ttwa.Rds"))
}
rq$id <- rf$id <- l$id[l$dist > 0]


# Allocate route factors to flows
# nz <- which(l$dist > 0) # non-zero lengths = nz
l$dist_quiet <- l$dist_fast <- l$cirquity <- l$distq_f <- NA
l$dist_fast <- rf$length
l$dist_quiet <- rq$length
l$cirquity <- rf$length / l$dist
l$distq_f <- rq$length / rf$length

# Check the data makes sense
plot(cents)
plot(zones, add = T)
a = 11
plot(l[l$dist > 0,][a,])
lines(rf[a,], col = "red")
lines(rq[a,], col = "green")

# # # # # # # # # # # # # #
# Estimates slc from olc  #
# # # # # # # # # # # # # #

l$clc <- l$Bicycle / l$All
flow_ttwa <- flow # save flows for the ttwa
flow <- l@data

source("models/aggregate-model.R") # this model creates the variable 'slc'
cor(flow$clc, mod_logsqr$fitted.values) # crude indication of goodness-of-fit
# summary(mod_logsqr)

l$slc <- flow$plc