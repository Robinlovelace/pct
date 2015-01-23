# Bumpf: code that didn't make it into the final version

# Testing time taken to calculate distances in one go vs for loop:
s_time <- Sys.time()
D <- gDistance(leeds, leeds, byid = T)
e_time <- Sys.time()
e_time - s_time # 2.5 mins
plot(as.numeric(D), fleeds$dist)

s_time <- Sys.time()
# for(i in 1:100){ # test the loop (uncomment + skip next line to test)
for(i in 1:nrow(fleeds)){
  from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
  to <- leeds$geo_code %in% fleeds$Area.of.workplace[i]
  fleeds$dist[i] <- gDistance(leeds[from, ], leeds[to, ])
  if(i %% round(nrow(fleeds) / 100) == 0)
    print(paste0(100 * i/nrow(fleeds), " % out of ", nrow(fleeds),
      " distances calculated"))
}
e_time <- Sys.time()
e_time - s_time

s_time <- Sys.time()
# for(i in 1:100){ # test the loop (uncomment + skip next line to test)
for(i in 1:nrow(fleeds)){
  from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
  to <- leeds$geo_code %in% fleeds$Area.of.workplace[i]
  fleeds$dist[i] <- gDistance(lcents[from, ], lcents[to, ])
  if(i %% round(nrow(fleeds) / 100) == 0)
    print(paste0(100 * i/nrow(fleeds), " % out of ", nrow(fleeds),
      " distances calculated"))
}
e_time <- Sys.time()
e_time - s_time

# test gSimplify
leeds_s <- gSimplify(leeds, tol = 200, topologyPreserve = TRUE)
plot(leeds_s)

# mapshaper
system('mapshaper pct-data/leeds/leeds-central-sample.shp auto-snap -simplify keep-shapes 2.5% -o force pct-data/leeds/leeds-central-sample-mapshaped.shp',wait=TRUE);

leeds_s2 <- readOGR("pct-data/leeds/", "leeds-central-sample-mapshaped")
object.size(leeds_s2) / 1000
object.size(leeds_s) / 1000
plot(leeds_s2)

# to 1%
system('mapshaper pct-data/leeds/leeds-central-sample.shp auto-snap -simplify keep-shapes 1% -o force pct-data/leeds/leeds-central-sample-mapshaped2.shp',wait=TRUE);

leeds_s2 <- readOGR("pct-data/leeds/", "leeds-central-sample-mapshaped2")
object.size(leeds_s2) / 1000
object.size(leeds_s) / 1000
plot(leeds_s2)

# To rename files
# rename -v 's/leeds-central-sample-mapshaped2/leeds-central-sample/' *.*

library(spatstat)
library(maptools)
lspat <- as.ppp(gCentroid(leeds, byid = T))
plot(lspat)
nndist(lspat[1, ], lspat[2, ])

# failing to write GeoJSON files
dir <- getwd()
todir <- "pct-data/leeds/leeds-central-msoa.geojson"
dir <- paste(dir, todir, sep = "/")
writeOGR(leeds, dsn = dir, layer = "OGRGeoJSON", driver = "GeoJSON")