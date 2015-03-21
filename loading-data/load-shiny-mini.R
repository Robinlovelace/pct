# # # # # # # # # #
# load data for   #
# shiny (small)   #
# # # # # # # # # #

city <- "manchester" # which city are we saving data for?
data_dir <- paste0("pct-data/", city, "-shiny")
dir.create(data_dir) # dir. to stash data

source("set-up.R") # load required packages

zones <- shapefile("pct-data/manchester/manc-msoa-lores.shp") # zones to display
zones <- spTransform(zones, CRS("+init=epsg:4326"))

# Load the local flow data - see loading-data/load-flow.R
flow <- read.csv("pct-data/manchester/msoa-flow-manc.csv")
flow$X <- NULL

# Subset lines to make dataset tiny
quantile(flow$All, seq(0, 1, 0.1) ) # what's the distribution of flows?
dlim <- 20 # flow rate deemed the 'limit' (can be calculated, not arbitrary)
sel <- flow$All > dlim
sum(sel) / nrow(flow) # % of lines covered (1/3 for manchester)
sum(flow$All[sel]) / sum(flow$All) # % of commutes (80%+ for manchester)
flow <- flow[sel, ]

# Remove lines of 0 distance
flow <- flow[flow$dist != 0,]

l <- gFlow2line(flow, zones) # convert data.frame to SpatialLinesDataFrame!
proj4string(l) <- CRS("+init=epsg:4326")
summary(l) # Check the data's ship-shape

# Save routes with x highest ecp values
sel <- head(order(l$ecp, decreasing = T), 50)
routes_fastest <- gLines2CyclePath(l, plan = "fastest")
routes_quietest <- gLines2CyclePath(l, plan = "quietest")
routes_fastest@data <- cbind(routes_fastest@data, l@data)
routes_quietest@data <- cbind(routes_quietest@data, l@data)

proj4string(routes_fastest) <- CRS("+init=epsg:4326")
proj4string(routes_quietest) <- CRS("+init=epsg:4326")

# Add routes data to l
plot(l)
plot(routes_fastest, add = T, col = "red")
plot(routes_quietest, add = T, col = "green")

names(l)
l$dist_fast <- routes_fastest$length / 1000
l$dist_quiet <- routes_quietest$length / 1000

# # # # # # # # #
# Save the data #
# # # # # # # # #

# saveRDS(l, "~/other-repos/pct-shiny/data/manchester/l.Rds") # uncomment to save
# saveRDS(zones, "~/other-repos/pct-shiny/data/manchester/z.Rds")
# saveRDS(routes_fastest, "~/other-repos/pct-shiny/data/manchester/rf.Rds")
# saveRDS(routes_quietest, "~/other-repos/pct-shiny/data/manchester/rq.Rds")
