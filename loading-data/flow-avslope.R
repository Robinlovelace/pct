# Allocate zone characteristics to flows

flow <- readRDS(file = "pct-bigdata/national/flow.Rds")
flow <- flow[grep(pattern = "E", x = flow$Area.of.residence),] # english days
flow <- flow[grep(pattern = "E", x = flow$Area.of.workplace),]

cents <- readOGR("pct-bigdata/national/cents.geojson", layer = "OGRGeoJSON")
cents <- spTransform(x = cents, CRSobj = CRS("+init=epsg:27700"))
flow$avslope <- NA
for(i in 1:nrow(flow)){
  avslope_o <- cents$avslope[cents$geo_code == flow$Area.of.residence[i]]
  avslope_d <- cents$avslope[cents$geo_code == flow$Area.of.workplace[i]]
  # Note: there are more sophisticated ways to allocate hilliness to lines
  # E.g. by dividing the line into sections for each zone it crosses or
  # identifying the hilliness of the network-allocated path
  flow$avslope[i] <- (avslope_o + avslope_d) / 2 # calculate average slope
  if(i %% 1000 == 0) print(paste0(i, " done, ",round(100 * i / nrow(flow)), " percent"))
}

saveRDS(object = flow, file = "pct-bigdata/national/flow_eng_avlslope.Rds")