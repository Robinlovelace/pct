start_time <- Sys.time() # for timing the script

# # # # # # # # # # # #
# Aim: load pct data  #
# # # # # # # # # # # #

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
cents_ttwa <- cents # copy cents data (we'll overwrite cents)
cents <- cents[ ttwa_zone,] # subset centroids geographically to ttwa

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

# # # # # # # # # # # # # # # # # #
# Calculate flow-level variables: #
# distances and clc for ag. model #
# # # # # # # # # # # # # # # # # #

# For loop to calculate distances (eventually use route distance)
proj4string(l) <- proj4string(cents)
flow$dist <- gLength(l, byid = T) / 1000


flow$dist <- flow$dist / 1000 # convert from metres to km
flow$clc <- flow$Bicycle / flow$All # current level of cycling



# # # # # # # # # # # # # # # # # #
# Extract area-level commute data #
# # # # # # # # # # # # # # # # # #

# Transform CRS for plotting
zones <- spTransform(zones, CRS("+init=epsg:4326"))
cents <- spTransform(cents, CRS("+init=epsg:4326"))
l <- spTransform(l, CRS("+init=epsg:4326"))

rf <- gLines2CyclePath(l[ l$dist > 0, ])
rq <- gLines2CyclePath(l[ l$dist > 0, ], plan = "quietest")

# Allocate route factors to flows
nonzero_lengths <- which(l$dist > 0)
flow$cirquity <- flow$quietest_over_fastest <- NA
flow$cirquity[nonzero_lengths] <- (rf$length / 1000) / flow$dist[flow$dist > 0]
flow$quietest_over_fastest[nonzero_lengths] <- rf$length / rq$length

# Check the data makes sense
plot(zones)
plot(l, add = T)
lines(rf[1:100,], col = "red")
lines(rq[1:100,], col = "green")

# # # # # # # # # # # # # #
# Estimates plc from clc  #
# # # # # # # # # # # # # #

source("models/aggregate-model.R") # this model creates the variable 'plc'

flow$ecp_perc <- flow$plc - flow$clc
flow$ecp <- flow$ecp_perc * flow$All
# flow$ecp2 <- flow$plc * flow$All - flow$Bicycle # identical ecp result

# # # # # # # # # # # # #
# Additional scenarios  #
# # # # # # # # # # # # #

# Additional scenarios
# Replace with source("models/aggregate-model-dutch|gendereq|ebike.R"))
set.seed(2015)
flow$plc_gendereq <- flow$plc + runif(nrow(flow), min = 0, max = 0.1)
flow$ecp_perc_gendereq <- flow$plc_gendereq - flow$clc
flow$ecp_gendereq <- flow$ecp_perc_gendereq * flow$All

flow$plc_dutch <- flow$plc + runif(nrow(flow), min = 0, max = 0.2)
flow$ecp_perc_dutch <- flow$plc_dutch - flow$clc
flow$ecp_dutch <- flow$ecp_perc_dutch * flow$All

flow$plc_ebike <- flow$plc + runif(nrow(flow), min = 0, max = 0.3)
flow$ecp_perc_ebike <- flow$plc_ebike - flow$clc
flow$ecp_ebike <- flow$ecp_perc_ebike * flow$All

# # # # # # # # # # # # # # # # #
# Subset lines to plotting area #
# # # # # # # # # # # # # # # # #

flow_ttwa <- flow # save flows for the ttwa
rf_ttwa <- rf # save flows for the ttwa
rq_ttwa <- rq # save flows for the ttwa
l_ttwa <- l

cents <- cents[ zones,] # subset centroids geographically
o <- flow$Area.of.residence %in% cents$geo_code
d <- flow$Area.of.workplace %in% cents$geo_code
flow <- flow[o & d, ] # subset flows with o and d in study area
l <- l[la, ]
rf <- rf[la, ] # subset flows with o and d in study area
rq <- rq[la, ] # subset flows with o and d in study area

# Aggregate flow-level data to zones
summary(cents$geo_code %in% zones$geo_code)

for(i in 1:nrow(cents)){

  #   plotting for validation (not needed)
  #   points(cents[i, ], pch = 22)
  #   sel <- l@data$Area.of.residence %in% cents@data$geo_code[i]
  #   plot(l[sel, ], add = T, pwd = l[sel, ]$ecp + 3)
  j <- which(flow$Area.of.residence == cents$geo_code[i])

  cents$clc[i] <- sum(flow$Bicycle[j]) / sum(flow$All[j])
  cents$plc[i] <- sum(flow$Bicycle[j]) + sum(flow$ecp[j])
  cents$ecp[i] <- sum(flow$ecp[j])

  # values for scenarios
  cents$plc_gendereq[i] <- sum(flow$Bicycle[j]) + sum(flow$ecp_gendereq[j])
  cents$ecp_genereq[i] <- sum(flow$ecp_gendereq[j])

  cents$plc_dutch[i] <- sum(flow$Bicycle[j]) + sum(flow$ecp_dutch[j])
  cents$ecp_dutch[i] <- sum(flow$ecp_dutch[j])

  cents$plc_ebike[i] <- sum(flow$Bicycle[j]) + sum(flow$ecp_ebike[j])
  cents$ecp_ebike[i] <- sum(flow$ecp_ebike[j])

  cents$circuity <- mean((flow$dist * flow$All / r))

}

# Add gender balance of cyclists
# From http://www.ons.gov.uk/ons/guide-method/geography/products/census/spatial/centroids/index.html
# oaps <- shapefile("bigdata/centroids/OA_2011_EW_PWC.shp")

oagen_mode <- read.csv("/media/robin/data/data-to-add/msoa-2011-sex-method-ttw-nomis-lc7103ew.csv", stringsAsFactors = F)
# oagen_mode <- read.csv("bigdata/LC7103EW_2011STATH_NAT_OA_REL_1.1.1_20140319-0942-19509/LC7103EW_2011STATH_NAT_OA_REL_1.1.1/LC7103EWDATA05.CSV", stringsAsFactors = F)
names(oagen_mode)
oagen_mode$fem <- oagen_mode$Sex..Females..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value / (oagen_mode$Sex..Males..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value + oagen_mode$Sex..Females..Method.of.travel.to.work..2001.specification...All.other.methods.of.travel.to.work..measures..Value)

oagen_mode <- dplyr::select(oagen_mode, geo_code = geography.code, percent_fem = fem)

zones@data <- left_join(zones@data, oagen_mode)

zones@data <- left_join(zones@data, cents@data)

summary(zones)

# # # # # # # # #
# Save the data #
# # # # # # # # #

saveRDS(zones, paste0("pct-data/", la, "/z.Rds"))
saveRDS(cents, paste0("pct-data/", la, "/c.Rds"))
saveRDS(l, paste0("pct-data/", la, "/l.Rds"))
saveRDS(rf, paste0("pct-data/", la, "/rf.Rds"))
saveRDS(rq, paste0("pct-data/", la, "/rq.Rds"))

end_time <- Sys.time()

end_time - start_time
