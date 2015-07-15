# nationalflow - aim run flow model on sample of national data
source("set-up.R")

# Minimum flow between od pairs, subsetting lines. High means fewer lines.
mflow <- 30
mdist <- 10 # maximum euclidean distance (km) for subsetting lines

flow <- readRDS(file = "pct-bigdata/national/flow_eng_avlslope.Rds")
# flow <- flow[grep(pattern = "E", x = flow$Area.of.residence),] # english days
# flow <- flow[grep(pattern = "E", x = flow$Area.of.workplace),]

set.seed(8)

flow <- flow[sample(nrow(flow), size = 50000),] # subset flows with o and d in study area
nrow(flow)

cents <- readOGR("pct-bigdata/national/cents.geojson", layer = "OGRGeoJSON")
cents <- spTransform(x = cents, CRSobj = CRS("+init=epsg:27700"))

nrow(flow)
flow <- flow[flow$All > mflow, ]
nrow(flow) # dramatically reduces n. flows

# # Allocate zone characteristics to flows
# flow$avslope <- NA
# for(i in 1:nrow(flow)){
#   avslope_o <- cents$avslope[cents$geo_code == flow$Area.of.residence[i]]
#   avslope_d <- cents$avslope[cents$geo_code == flow$Area.of.workplace[i]]
#   # Note: there are more sophisticated ways to allocate hilliness to lines
#   # E.g. by dividing the line into sections for each zone it crosses or
#   # identifying the hilliness of the network-allocated path
#   flow$avslope[i] <- (avslope_o + avslope_d) / 2 # calculate average slope
# }

# Subset by total amount of flow
summary(flow$All)
summary(flow$avslope)

flow$id <- paste(flow$Area.of.residence, flow$Area.of.workplace)

l <- gFlow2line(flow = flow, zones = cents)
l$dist <- gLength(l, byid = T) / 1000 # Euclidean distance
dsel <- l$dist < mdist

l <- l[dsel,]
l <- l[l$dist > 0, ] # to remove flows of 0 length
plot(cents)
lines(l, col = "red") # show the lines on the map


# # # # # # # # # # # # # # # # # #
# Calculate flow-level variables: #
# distances and olc for ag. model #
# # # # # # # # # # # # # # # # # #

l <- spTransform(l, CRSobj = "+init=epsg:4326")

  rf <- gLines2CyclePath(l[ l$dist > 0, ])
  rq <- gLines2CyclePath(l[ l$dist > 0, ], plan = "quietest")

  rf$length <- rf$length / 1000
  rq$length <- rq$length / 1000

rq$id <- rf$id <- l$id

# Allocate route factors to flows
# nz <- which(l$dist > 0) # non-zero lengths = nz
l$dist_quiet <- l$dist_fast <- l$cirquity <- l$distq_f <- NA
l$dist_fast <- rf$length
l$dist_quiet <- rq$length
l$cirquity <- rf$length / l$dist
l$distq_f <- rq$length / rf$length

# Check the data makes sense
plot(cents)
plot(l)
a = 11
plot(l[l$dist > 0,])
plot(l[a,])
lines(rf[a,], col = "red")
lines(rq[a,], col = "green")
plot(l$dist, l@data$dist_fast)

# # # # # # # # # # # # # #
# Estimates slc from olc  #
# # # # # # # # # # # # # #

l$clc <- l$Bicycle / l$All

nrm <- which(is.na(l@data$dist_quiet))
l <- l[-nrm,]
rf <- rf[-nrm,]
rq <- rq[-nrm,]


nrow(l)

saveRDS(rf, "pct-bigdata/national/rfl_sam8.Rds") # save the routes
saveRDS(rq, "pct-bigdata/national/rql_sam8.Rds") # save the routes
saveRDS(l, "pct-bigdata/national/l_sam8.Rds")

l <- readRDS("pct-bigdata/national/l_sam8.Rds")

flow <- l@data
source("models/aggregate-model.R") # this model creates the variable 'slc'
cor(flow$clc, mod_logsqr$fitted.values) # crude indication of goodness-of-fit

summary(mod_logsqr)
# saveRDS(mod_logsqr, "pct-bigdata/national/mod_logsqr_national_8.Rds")
# now do analytics, then incorporate into load.Rmd

l$slc <- flow$plc