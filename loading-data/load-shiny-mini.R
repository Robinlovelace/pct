# # # # # # # # # #
# load data for   #
# shiny (small)   #
# # # # # # # # # #

dir.create("pct-data/manchester-shiny") # dir. to stash data

source("set-up.R") # load required packages

zones <- shapefile("pct-data/manchester/manc-msoa-lores.shp") # zones to display

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

l <- gFlow2line(flow, zones) # convert data.frame to SpatialLinesDataFrame!
head(l@data)

proj4string(l) <- CRS("+init=epsg:27700")
l <- spTransform(l, CRS("+init=epsg:4326"))

# # # # # # # # #
# Save the data #
# # # # # # # # #

saveRDS(l, "pct-data/manchester-shiny/l.Rds")
saveRDS(zones, "pct-data/manchester-shiny/z.Rds")

