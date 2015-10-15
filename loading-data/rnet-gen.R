# Purpose: to generate the network analysis layer from l and rf objects
library(stplanr)

la <- "norwich"

l <- readRDS(paste0("pct-data/", la, "/l.Rds"))
rf <- readRDS(paste0("pct-data/", la, "/rf.Rds"))

nrow(l) == nrow(rf)
rf@data["base_olc"] <- l@data["base_olc"]
rnet <- gOverline(rf, "base_olc")
rf$clc <- NULL
# test the resulting plot
plot(rnet, lwd = rnet$base_olc / mean(rnet$base_olc))
scens <- c("cdp_slc", "gendereq_slc", "dutch_slc", "ebike_slc")
# for(i in scens){
#   print(paste0("Working on the ", i, " scenario"))
#   rf@data[i] <- l@data[i]
#   rnet_tmp <- gOverline(rf, i)
#   rnet@data[i] <- rnet_tmp@data[i]
#   rf@data[i] <- NULL
# }

# if that fails...
for(i in scens){
  print(paste0("Working on the ", i, " scenario"))
  rnet@data[i] <- rnet$base_olc
}

plot(rnet, lwd = rnet$cdp_slc / mean(rnet$base_olc))

saveRDS(rnet, paste0("pct-data/", la, "/rnet.Rds"))
