# # # # # # # # # # # #
# Aim: load pct data  #
# # # # # # # # # # # #

la
start_time <- Sys.time() # for timing the script
source("set-up.R") # pull in packages needed

# # # # # # # #
# Parameters  #
# # # # # # # #

# Set local authority and ttwa zone names
la <- "Manchester" # name of the local authority
# ttwa_name <- "newcastle" # name of the travel to work area
dir.create(file.path("pct-data", tolower(la))) # on a unix machine

# Minimum flow between od pairs, subsetting lines. High means fewer lines.
mflow <- 30
mdist <- 10 # maximum euclidean distance (km) for subsetting lines
buff_dist <- 0 # radius of buffer used to select additional msoas

# # # # # # # # # # # #
# Load national data  #
# # # # # # # # # # # #

# # Travel to work areas (ttwa) see load-uk.R # comment out if not used
# fttw <- "pct-bigdata/national/ttwa_all.geojson"
# ttwa_all <- readOGR(dsn = fttw, layer = "OGRGeoJSON")
# ttwa_all <- spTransform(ttwa_all, CRSobj = CRS("+init=epsg:27700"))
# ttwa_zone <- ttwa_all[ grep(ttwa_name, ttwa_all$TTWA07NM, ignore.case = T),]

# Extract la data
ukmsoas <- shapefile("pct-bigdata/national/msoas.shp")

# Load population-weighted centroids
cents <- readOGR("pct-bigdata/national/cents.geojson", layer = "OGRGeoJSON")

# Load local authorities
las <- readOGR(dsn = "pct-bigdata/national/las-pcycle.geojson", layer = "OGRGeoJSON")
lasdat <- SpatialPointsDataFrame(coords = coordinates(las), data = las@data)
x <- dplyr::select(las@data, clc, pcycle)
lasdat@data <- x

# cuas <- readOGR(dsn = "pct-bigdata/national/cuas.geojson", layer = "OGRGeoJSON")
# proj4string(lasdat) <- proj4string(las)
# cuas <- aggregate(lasdat, cuas, mean, na.action = na.omit()) # todo: fix data
# cua_shape <- cuas[grep(pattern = la, x = cuas@data$NAME)] # todo: fix
# # tmap::qtm(cuas2,fill = "clc")

la_shape <- las[grep(pattern = la, x = las@data$NAME),]
plot(la_shape) # update la data
cents <- cents[la_shape,]
points(cents)

# Convert cents to OSGB CRS
cents <- spTransform(cents, CRSobj = proj4string(ukmsoas))

# Extract zones to plot
# zones <- ukmsoas[ grep(la, ukmsoas$geo_label), ] # extract by name
zones <- ukmsoas[cents, ]
zone <- gBuffer(zones, width = buff_dist) # create la zone outline
plot(zones)
plot(zone, lwd = 5, add = T)
zone <- spTransform(zone, CRS("+init=epsg:4326"))

# Check n. zones. If too few, add more
if(nrow(zones) < 50){

  zbuf <- gBuffer(zones, width = buff_dist)
  plot(zbuf)
  plot(zones, col = "red", add = T)
  plot(cents, add = T)
  proj4string(cents) <- proj4string(zones)
  cents <- cents[zbuf, ]
  zones <- ukmsoas[ukmsoas$geo_code %in% cents$geo_code,]
  plot(zones, add = T)

}

nrow(zones) # updated n. zones

# Check the area is correct
# plot(ttwa_zone, lwd = 4)
# points(cents)
# plot(zones, col = "red", add = T)
# plot(zbuf, lwd = 6, add = T)

# # # # # # #
# Flow data #
# # # # # # #

flow <- readRDS("pct-bigdata/national/flow.Rds")

# Subset by zones in the study area
o <- flow$Area.of.residence %in% cents$geo_code
d <- flow$Area.of.workplace %in% cents$geo_code
flow <- flow[o & d, ] # subset flows with o and d in study area
nrow(flow)

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
nrow(flow)
flow <- flow[flow$All > mflow, ]
nrow(flow)

flow$id <- paste(flow$Area.of.residence, flow$Area.of.workplace)

l <- gFlow2line(flow = flow, zones = cents)
plot(cents)
lines(l) # show the lines on the map


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
  if(sum(grepl("l_all", f)) == 0) saveRDS(l, file.path("pct-data", la, "l_all.Rds"))
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
if(length(grep("rf_ttwa.Rds|rq_ttwa.Rds", list.files(file.path("pct-data", la)))) >= 2){
  rf <- readRDS(file.path(("pct-data", la, "rf_ttwa.Rds")) # if you've loaded them
  rq <- readRDS(file.path(("pct-data", la, "rq_ttwa.Rds"))
} else{
  rf <- gLines2CyclePath(l[ l$dist > 0, ])
  rq <- gLines2CyclePath(l[ l$dist > 0, ], plan = "quietest")

  # Process route data
  rf$length <- rf$length / 1000
  rq$length <- rq$length / 1000
  saveRDS(rf, file.path("pct-data", la, "rf_ttwa.Rds")) # save the routes
  saveRDS(rq, file.path("pct-data", la, "rq_ttwa.Rds"))
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
# l <- l[l$dist > 0, ]
l$base_olc <- l$Bicycle
l$base_slc <- l$slc * l$All
l$base_sic <- l$base_slc - l$base_olc
# l$sic2 <- l$slc * l$All - l$Bicycle # identical sic result

# # # # # # # # # # # # #
# Additional scenarios  #
# # # # # # # # # # # # #

# Additional scenarios
# Replace with source("models/aggregate-model-dutch|gendereq|ebike.R"))
set.seed(2015)
l$gendereq_slc <- l$All * (l$slc + runif(nrow(l), 0, max = 0.1))
l$gendereq_sic <- l$gendereq_slc - l$base_olc

l$dutch_slc <- l$All * (l$slc + runif(nrow(l), 0, max = 0.2))
l$dutch_sic <- l$dutch_slc - l$base_olc

l$ebike_slc <- l$All * (l$slc + runif(nrow(l), 0, max = 0.3))
l$ebike_sic <- l$ebike_slc - l$base_olc

# # # # # # # # # # # # # # # # # #
# Extract area-level commute data #
# # # # # # # # # # # # # # # # # #

for(i in 1:nrow(cents)){

  # all flows originating from centroid i
  j <- which(l$Area.of.residence == cents$geo_code[i])

  cents$base_olc[i] <- sum(l$Bicycle[j])
  cents$base_slc[i] <- sum(l$base_slc[j])
  cents$base_sic[i] <- sum(l$base_sic[j])

  # values for scenarios
  cents$gendereq_slc[i] <- sum(l$gendereq_slc[j])
  cents$gendereq_sic[i] <- sum(l$gendereq_sic[j])

  cents$dutch_slc[i] <- sum(l$dutch_slc[j])
  cents$dutch_sic[i] <- sum(l$dutch_sic[j])

  cents$ebike_slc[i] <- sum(l$ebike_slc[j])
  cents$ebike_sic[i] <- sum(l$ebike_sic[j])

  cents$av_distance[i] <- sum(l$dist[j] * l$All[j])  / sum(l$All[j])
  cents$cirquity[i] <- sum(l$cirquity[j] * l$All[j], na.rm = T )  / sum(l$All[j])
  cents$distq_f[i] <- sum(l$distq_f[j] * l$All[j], na.rm = T )  / sum(l$All[j])
}

names(l) # which line names can be added for non-directional flows?
addids <- c(3:14, 23:31)

# Aggregate bi-directional flows

# Subset by zone bounding box
# l <- l[as.logical(gContains(zone, l, byid = T)),]
nrow(l)

# 4: by aggregating 2 way flows
l <- gOnewayid(l, attrib = addids)
l$clc <- l$Bicycle / l$All
l$slc <- l$base_slc / l$All

nrow(l)
idsel <- l$id
plot(zone)
lines(l, col = "green")
rf <- rf[rf@data$id %in% idsel,]
rq <- rq[rq@data$id %in% idsel,]

# Sanity test
summary(l@data)
cents_ttwa <- cents # copy cents data (we'll overwrite cents)

# # Subset to zone
# cents <- cents_ttwa[zone,] # subset centroids geographically
# zones <- zones[cents,]
plot(zone, lwd = 5)
plot(zones, add = T)
points(cents_ttwa, col = "red")
points(cents)
lines(l, col = "red")
lines(rq, col = "white")
lines(rf, col = "blue")
toplot <- sample(nrow(l), size = 10)
plot(l[toplot,])
lines(rq[toplot,], col = "green")
lines(rf[toplot,], col = "blue")

flow_in_l <- names(flow) %in% names(l)
l@data <- left_join(l@data, data.frame(id = flow$id, plc = flow[,!flow_in_l]), by = "id")

# Check the data
summary(cents$geo_code %in% zones$geo_code) # check zones are equal
head(zones@data)
head(l@data)
plot(data.frame(l= l$dist, rq = rq$length, rf = rf$length))

# # # # # # # # #
# Save the data #
# # # # # # # # #

# Transfer cents data to zones
c_in_z <- names(cents) == "avslope"
zones@data <- left_join(zones@data, cents@data[,!c_in_z])
summary(cents)
summary(zones)

# Save objects
saveRDS(zones, file.path("pct-data", la, "z.Rds"))
saveRDS(cents, file.path("pct-data", la, "c.Rds"))
saveRDS(l, file.path("pct-data", la, "l.Rds"))
saveRDS(rf, file.path("pct-data", la, "rf.Rds"))
saveRDS(rq, file.path("pct-data", la, "rq.Rds"))
saveRDS(mod_logsqr, file.path("pct-data", la, "model.Rds"))

# # Save data for wider ttwz area
# saveRDS(ttwa_zone, paste0("pct-data/", la, "/ttw_zone.Rds"))
# saveRDS(cents_ttwa, paste0("pct-data/", la, "/c_ttwa.Rds"))
# saveRDS(l_ttwa, paste0("pct-data/", la, "/l_ttwa.Rds"))

# Create new folder in pct-shiny repo
rname <- tolower(la)
dname <- file.path("~", "repos", "pct-shiny", rname)
dir.create(dname)
files <- list.files("~/repos/pct-shiny/manchester/", full.names = T)
file.copy(files, dname)
server <- readLines(file.path(dname, "server.R"))
server <- gsub("manchester", la, server)
writeLines(server, file.path(dname, "server.R"))

# Save the script that loaded the lines into the data directory
file.copy("loading-data/load.R", file.path("pct-data", la, "load.R"))

end_time <- Sys.time()

end_time - start_time
