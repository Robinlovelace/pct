# # # # # # # # # # # #
# Aim: load pct data  #
# # # # # # # # # # # #

start_time <- Sys.time() # for timing the script
source("set-up.R") # pull in packages needed

# Set local authority and ttwa zone names
la <- "coventry" # Name of the local authority
dir.create(paste0("pct-data/", la))

# # # # # # # # # # # #
# Load national data  #
# # # # # # # # # # # #

ttwa_name <- "coventry" # name of the Travel to Work Area (must type this)
ttwa_all <- shapefile("bigdata/TTWA_DEC_2007_EW_BGCmapshaped_5%.shp") # all zones
ttwa_zone <- ttwa_all[ grep(ttwa_name, ttwa_all$TTWA07NM, ignore.case = T),]

# Extract la data
ukmsoas <- shapefile("pct-data/national/infuse_msoa_lyr_2011mapshaped_5%.shp")

# Extract zones to plot
zones <- ukmsoas[ grep(la, ukmsoas$geo_label, ignore.case = T), ]

# Load centroid data (strategy: load all data to these first for model)
cents <- shapefile("bigdata/centroids/MSOA_2011_EW_PWC.shp") # pop. weighted cents
cents@data <- rename(cents@data, geo_code = MSOA11CD)
proj4string(zones) <- proj4string(cents)
cents <- cents[ ttwa_zone,] # subset centroids geographically to ttwa

# Add age by distance to centroids

# Add gender balance of cyclists
# From http://www.ons.gov.uk/ons/guide-method/geography/products/census/spatial/centroids/index.html
# oaps <- shapefile("bigdata/centroids/OA_2011_EW_PWC.shp")

oagen_mode <- read.csv("/media/robin/data/data-to-add/msoa-2011-sex-method-ttw-nomis-lc7103ew.csv", stringsAsFactors = F)
# oagen_mode <- read.csv("bigdata/LC7103EW_2011STATH_NAT_OA_REL_1.1.1_20140319-0942-19509/LC7103EW_2011STATH_NAT_OA_REL_1.1.1/LC7103EWDATA05.CSV", stringsAsFactors = F)
names(oagen_mode)
oagen_mode$fem <- oagen_mode$Sex..Females..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value / (oagen_mode$Sex..Males..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value + oagen_mode$Sex..Females..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value)

oagen_mode <- dplyr::select(oagen_mode, geo_code = geography.code, percent_fem = fem)

cents@data <- left_join(cents@data, oagen_mode)
cents@data <- left_join(cents@data, cents@data)

summary(cents)

# Check the area is correct
plot(ttwa_zone)
plot(zones, add = T)

# # # # # # # # # # #
# Add height data   #
# (see steepness.R) #
# # # # # # # # # # #

msoa_slopes <- read.csv("pct-data/national/avslope-msoa.csv")
head(msoa_slopes)
msoa_slopes <- dplyr::select(msoa_slopes, geo_code, avslope)
head(zones@data)
cents@data <- left_join(cents@data, msoa_slopes)

# # # # # # #
# Flow data #
# # # # # # #

f <- "bigdata/public-flow-data-msoa/wu03ew_v2.csv" # file location
flow <- read.csv(f, stringsAsFactors = F) # load public msoa-level flow data
flow <- rename(flow, All = All.categories..Method.of.travel.to.work)
o <- flow$Area.of.residence %in% cents$geo_code
d <- flow$Area.of.workplace %in% cents$geo_code
flow <- flow[o & d, ] # subset flows with o and d in study area
flow$id <- paste(flow$Area.of.residence, flow$Area.of.workplace)
l <- gFlow2line(flow = flow, zones = cents)

# # # # # # # # # # # # # # # # # #
# Calculate flow-level variables: #
# distances and clc for ag. model #
# # # # # # # # # # # # # # # # # #

# Calculate distances (eventually use route distance)
proj4string(l) <- proj4string(cents)
flow$dist <- gLength(l, byid = T) / 1000 # Euclidean distance

# Transform CRS for plotting
zones <- spTransform(zones, CRS("+init=epsg:4326"))
zone <- gBuffer(zones, width = 0) # create la zone outline
cents <- spTransform(cents, CRS("+init=epsg:4326"))
l <- spTransform(l, CRS("+init=epsg:4326"))

# # # # # # # # # # # # # # #
# Allocate flows to network #
# Warning: time-consuming!  #
# # # # # # # # # # # # # # #

if(grep("rf.Rds|rq.Rds", list.files(paste0("pct-data/", la))) >= 2){
  rf <- readRDS(paste0("pct-data/", la, "/rf.Rds")) # if you've loaded them
  rq <- readRDS(paste0("pct-data/", la, "/rq.Rds"))
} else{
  rf <- gLines2CyclePath(l[ flow$dist > 0, ])
  rq <- gLines2CyclePath(l[ flow$dist > 0, ], plan = "quietest")
}

# Process route data
rf$length <- rf$length / 1000
rq$length <- rq$length / 1000
rq$id <- rf$id <- flow$id[flow$dist > 0]

# Allocate route factors to flows
nz <- which(flow$dist > 0) # non-zero lengths = nz
flow$dist_quiet <- flow$dist_fast <- flow$cirquity <- flow$distq_f <- NA
flow$dist_fast[nz] <- rf$length
flow$dist_quiet[nz] <- rq$length
flow$cirquity[nz] <- flow$dist[nz] / rf$length
flow$distq_f[nz] <- rf$length / rq$length

# Check the data makes sense
plot(cents)
plot(zones, add = T)
plot(l, add = T)
lines(rf[1:100,], col = "red")
lines(rq[1:100,], col = "green")

# # # # # # # # # # # # # #
# Estimates plc from clc  #
# # # # # # # # # # # # # #

flow$clc <- flow$Bicycle / flow$All

source("models/aggregate-model.R") # this model creates the variable 'plc'

flow$base_clc <- flow$Bicycle
flow$base_plc <- flow$plc * flow$All
flow$base_ecp <- flow$base_plc - flow$base_clc
# flow$ecp2 <- flow$plc * flow$All - flow$Bicycle # identical ecp result

# # # # # # # # # # # # #
# Additional scenarios  #
# # # # # # # # # # # # #

# Additional scenarios
# Replace with source("models/aggregate-model-dutch|gendereq|ebike.R"))
set.seed(2015)
flow$gendereq_plc <- flow$All * (flow$plc + runif(nrow(flow), 0, max = 0.1))
flow$gendereq_ecp <- flow$gendereq_plc - flow$base_clc

flow$dutch_plc <- flow$All * (flow$plc + runif(nrow(flow), 0, max = 0.2))
flow$dutch_ecp <- flow$dutch_plc - flow$base_clc

flow$ebike_plc <- flow$All * (flow$plc + runif(nrow(flow), 0, max = 0.3))
flow$ebike_ecp <- flow$ebike_plc - flow$base_clc

# # # # # # # # # # # # # # # # # #
# Extract area-level commute data #
# # # # # # # # # # # # # # # # # #

for(i in 1:nrow(cents)){

  # all flows originating from centroid i
  j <- which(flow$Area.of.residence == cents$geo_code[i])

  cents$base_clc[i] <- sum(flow$Bicycle[j]) / sum(flow$All[j])
  cents$base_plc[i] <- sum(flow$Bicycle[j]) + sum(flow$ecp[j])
  cents$base_ecp[i] <- sum(flow$ecp[j])

  # values for scenarios
  cents$gendereq_plc[i] <- sum(flow$gendereq_plc[j])
  cents$gendereq_ecp[i] <- sum(flow$gendereq_ecp[j])

  cents$dutch_plc[i] <- sum(flow$dutch_plc[j])
  cents$dutch_ecp[i] <- sum(flow$dutch_ecp[j])

  cents$ebike_plc[i] <- sum(flow$ebike_plc[j])
  cents$ebike_ecp[i] <- sum(flow$ebike_ecp[j])

  cents$av_distance <- sum(flow$dist[j] * flow$All[j])  / sum(flow$All[j])
  cents$cirquity <- mean(flow$cirquity[j] * flow$All[j], na.rm =T)  / sum(flow$All[j])

}

# # # # # # # # # # # # # # # # #
# Subset lines to plotting area #
# # # # # # # # # # # # # # # # #

flow_ttwa <- flow # save flows for the ttwa
rf_ttwa <- rf # save flows for the ttwa
rq_ttwa <- rq # save flows for the ttwa
l_ttwa <- l
cents_ttwa <- cents # copy cents data (we'll overwrite cents)

cents <- cents_ttwa[zone,] # subset centroids geographically
plot(cents_ttwa)
points(cents)
lines(l, col = "red")
lsel <- as.logical(gContains(zone, l, byid = T)) & gLength(l,byid = T) > 0
idsel <- l$id[lsel]
l <- l[l$id %in% idsel, ]
lines(l, col = "green")

rf <- rf[rf$id %in% idsel, ] # subset routes
rq <- rq[rq$id %in% idsel, ]
lines(rq, col = "white")
lines(rf, col = "blue")

flow_in_l <- names(flow) %in% names(l)
l@data <- left_join(l@data, cbind(id = flow$id, flow[,!flow_in_l]), by = "id")

# # # # # # # # #
# Save the data #
# # # # # # # # #

summary(cents$geo_code %in% zones$geo_code) # check zones are equal

# Transfer cents data to zones
zones@data <- left_join(zones@data, cents@data, by = "geo_code")

# Save objects
saveRDS(zones, paste0("pct-data/", la, "/z.Rds"))
saveRDS(cents, paste0("pct-data/", la, "/c.Rds"))
saveRDS(l, paste0("pct-data/", la, "/l.Rds"))
saveRDS(rf, paste0("pct-data/", la, "/rf.Rds"))
saveRDS(rq, paste0("pct-data/", la, "/rq.Rds"))

# Save data for wider ttwz area
saveRDS(ttwa_zone, paste0("pct-data/", la, "/ttw_zone.Rds"))
saveRDS(cents_ttwa, paste0("pct-data/", la, "/c_ttwa.Rds"))
saveRDS(l_ttwa, paste0("pct-data/", la, "/l_ttwa.Rds"))
saveRDS(rf_ttwa, paste0("pct-data/", la, "/rf_ttwa.Rds"))
saveRDS(rq_ttwa, paste0("pct-data/", la, "/rq_ttwa.Rds"))

end_time <- Sys.time()

end_time - start_time
