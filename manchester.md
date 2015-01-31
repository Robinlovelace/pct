

```r
# # # # #
# setup #
# # # # #

source("set-up.R") # load required packages
```

```
## Downloading github repo robinlovelace/pctpack@master
## Installing pctpack
## '/usr/lib/R/bin/R' --vanilla CMD INSTALL  \
##   '/tmp/RtmpJrHBDh/devtools7d0b11ea775/Robinlovelace-pctpack-e966355'  \
##   --library='/home/robin/R/i686-pc-linux-gnu-library/3.1'  \
##   --install-tests 
## 
## Reloading installed pctpack
```

```r
# # # # # # # # # # # # #
# Load Manchester data  #
# No need to run this   #
# # # # # # # # # # # # #

# Load public access flow data
# Set file location (will vary - download files from here:
# https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
# f <- "/media/robin/data/data-to-add/public-flow-data-msoa/wu03ew_v2.csv"
# flowm <- read.csv(f) # load public msoa-level flow data
# o_in_manc <- flowm$Area.of.residence %in% manc$geo_code
# d_in_manc <- flowm$Area.of.workplace %in% manc$geo_code
#
# fmanc <- flowm[ o_in_manc & d_in_manc , ]
# write.csv(fmanc, "pct-data/manchester/msoa-flow-manc.csv")

# # # # # # # # # # # #
# Load the test data  #
# (Available online)  #
# # # # # # # # # # # #

# Load the geographical data
manc <- readOGR("pct-data/manchester/", "manc-msoa-lores")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "pct-data/manchester/", layer: "manc-msoa-lores"
## with 57 features and 3 fields
## Feature type: wkbPolygon with 2 dimensions
```

```r
# Load the flow data
fmanc <- read.csv("pct-data/manchester/msoa-flow-manc.csv")
cents <- gCentroid(manc, byid = T) # centroids of the zones

fmanc$dist <- NA # create distance field

# Calculate distance between OD pairs in Manchester
for(i in 1:nrow(fmanc)){
  from <- manc$geo_code %in% fmanc$Area.of.residence[i]
  to <- manc$geo_code %in% fmanc$Area.of.workplace[i]
  fmanc$dist[i] <- gDistance(cents[from, ], cents[to, ])
  if(i %% round(nrow(fmanc) / 10) == 0)
    print(paste0(100 * i/nrow(fmanc), " % out of ", nrow(fmanc),
      " distances calculated")) # print % of distances calculated
}
```

```
## [1] "9.98711340206185 % out of 3104 distances calculated"
## [1] "19.9742268041237 % out of 3104 distances calculated"
## [1] "29.9613402061856 % out of 3104 distances calculated"
## [1] "39.9484536082474 % out of 3104 distances calculated"
## [1] "49.9355670103093 % out of 3104 distances calculated"
## [1] "59.9226804123711 % out of 3104 distances calculated"
## [1] "69.909793814433 % out of 3104 distances calculated"
## [1] "79.8969072164948 % out of 3104 distances calculated"
## [1] "89.8840206185567 % out of 3104 distances calculated"
## [1] "99.8711340206186 % out of 3104 distances calculated"
```

```r
# Propensity to cycle
fmanc$p_cycle <- iac(fmanc$dist / 1000)
fmanc$n_cycle <- fmanc$p_cycle * fmanc$All.categories..Method.of.travel.to.work

# Extra cycling potential
fmanc$ecp <- fmanc$n_cycle - fmanc$Bicycle
summary(fmanc$ecp)
```

```
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
## -19.7800   0.1161   0.5858   3.9440   2.2500 238.8000
```

```r
summary(fmanc$Bicycle)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   0.000   0.000   0.000   1.849   2.000  55.000
```

```r
write.csv(fmanc, "pct-data/manchester/manc-msoas-dists.csv")

# Test plotting
plot(manc)
# for(i in 1:nrow(fmanc)){
for(i in 1:20){
  from <- manc$geo_code %in% fmanc$Area.of.residence[i]
  to <- manc$geo_code %in% fmanc$Area.of.workplace[i]
  x <- coordinates(manc[from, ])
  y <- coordinates(manc[to, ])
  lines(c(x[1], y[1]), c(x[2], y[2]), lwd = fmanc$ecp[i] )
}
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-1.png) 

```r
# Compare estimated and actual number of cyclists
plot(fmanc$Bicycle, fmanc$n_cycle)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-2.png) 

```r
cor(fmanc$Bicycle, fmanc$n_cycle)
```

```
## [1] 0.5644529
```

