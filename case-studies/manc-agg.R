# Loading data

source("geo-load/load-uk.R")
source("geo-load/load-uk-centroids.R")

ttw <- ttw[ttw@data$TTWA07NM == "Manchester", ]

cent <- cents_msoa[ ttw, ]
plot(cent)
nrow(cent)

# Load flow data, subset area of interest
source("geo-load/load-flow-open.R")
o <- flowm$Area.of.residence %in% cent$MSOA11CD
d <- flowm$Area.of.workplace %in% cent$MSOA11CD
f <- flowm[ o & d , ]

# The current level of cycling (% cycle commuters)
f$clc <- f$Bicycle / f$All.categories..Method.of.travel.to.work

head(f)
f$dist <- NA # create distance field
plot(cent)
# Calculate distance between OD pairs (takes time)
for(i in 1:nrow(f)){
  from <- cent$MSOA11CD %in% f$Area.of.residence[i]
  to <- cent$MSOA11CD %in% f$Area.of.workplace[i]
  f$dist[i] <- gDistance(cent[from, ], cent[to, ])
  # print % of distances calculated
  if(i %% round(nrow(f) / 10) == 0)
    print(paste0(100 * round(i/nrow(f)), " % out of ", nrow(f)))
}

f$dist <- f$dist / 1000 # distance in km
plot(f$dist, f$clc, xlab = "Distance (km)", ylab = "Proportion of commutes by bike")
# Propensity to cycle


# Extra cycling potential
f$ecp <- f$pc - f$Bicycle
head(f)
summary(f$ecp)
summary(f$Bicycle)

leeds <- spTransform(leeds, CRS("+init=epsg:4326"))
sel <- match(f$Area.of.residence, cent$MSOA11CD)
head(sel)
ocoords <- coordinates(leeds)[sel,] # where distance = 0

sel <- match(f$Area.of.workplace, cent$MSOA11CD)
head(sel)
dcoords <- coordinates(leeds)[sel,]

f <- cbind(f, ocoords, dcoords)
head(f)
names(f)
names(f)[19:22] <- c("lon_origin", "lat_origin", "lon_dest", "lat_dest")

# write.csv(f, "pct-data/leeds/msoa-flow-leeds-all.csv")

# # Actual rate of cycling
plot(leeds)
lwd <- f$Bicycle / mean(f$Bicycle) * 0.1
for(i in 1:nrow(f)){
  # for(i in 1:1000){
  from <- cent$MSOA11CD %in% f$Area.of.residence[i]
  to <- cent$MSOA11CD %in% f$Area.of.workplace[i]
  x <- coordinates(leeds[from, ])
  y <- coordinates(leeds[to, ])
  lines(c(x[1], y[1]), c(x[2], y[2]), lwd = lwd, col = "blue" )
  if(i %% round(nrow(f) / 10) == 0)
    print(paste0(100 * i/nrow(f), " % out of ", nrow(f)))
}
#
# head(f)
#
# plot(leeds)
# for(i in 1:nrow(f)){
#   from <- cent$MSOA11CD %in% f$Area.of.residence[i]
#   to <- cent$MSOA11CD %in% f$Area.of.workplace[i]
#   x <- coordinates(leeds[from, ])
#   y <- coordinates(leeds[to, ])
# #   lines(c(x[1], y[1]), c(x[2], y[2]), lwd = f$pc[i] / 400 )
# }

# Compare estimated and actual number of cyclists
plot(f$Bicycle, f$pc)
cor(f$Bicycle, f$pc)

# Create lines, convert to wgs84, export as geojson
