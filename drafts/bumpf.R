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

# Original code for the aggregate pct model
# Parameterise distance decay
# Which flows have cycling as 0%?
sel <- flow$Bicycle > 0
logistic <- lm(log(flow$pcycle[sel]) ~ flow$dist[sel])
plot(flow$dist, flow$pcycle) # the problem with flow data: many 0's and 1's
plot(logistic)
summary(logistic)
logistic$coefficients[2]
exp(logistic$coefficients[1])

# Binning variables
flow <- flow[flow$dist < 20.5, ]
brks <- c(0, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 9.5, 12.5, 15.5, 20.5)
flow$binned_dist <- cut(flow$dist, breaks = brks, include.lowest = T)
summary(flow$binned_dist) # summaries binned distances

# Create aggregate variables
gflow <- group_by(flow, binned_dist) %>%
  summarise(mdist = mean(dist), mbike = mean(pcycle),
    total = sum(All.categories..Method.of.travel.to.work))

plot(gflow$mdist, gflow$mbike,
  xlab = "Distance (miles)", ylab = "Percent cycling")

mod_loglin <- lm(log(gflow$mbike) ~ gflow$mdist)
mod_logsqr <- lm(log(gflow$mbike) ~ gflow$mdist + I(gflow$mdist^2))
mod_logcub <- lm(log(gflow$mbike) ~ gflow$mdist + I(gflow$mdist^2) + I(gflow$mdist^3))

plot(gflow$mdist, gflow$mbike,
  xlab = "Distance (miles)", ylab = "Percent cycling")
lines(gflow$mdist, exp(mod_loglin$fitted.values), col = "blue")
lines(gflow$mdist, exp(mod_logsqr$fitted.values), col = "red")
lines(gflow$mdist, exp(mod_logcub$fitted.values), col = "green")