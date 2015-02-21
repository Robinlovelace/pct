# Leeds lines

summary(flow)
flow <- flow[flow$Bicycle > 0,]

l <- vector("list", nrow(flow))


for(i in 1:nrow(flow)){
  from <- leeds$geo_code %in% flow$Area.of.residence[i]
  to <- leeds$geo_code %in% flow$Area.of.workplace[i]
  x <- coordinates(leeds[from, ])
  y <- coordinates(leeds[to, ])
  l[[i]] <- Lines(list(Line(rbind(x, y))), as.character(i))
}

l <- SpatialLines(l)
l <- SpatialLinesDataFrame(l, data = flow, match.ID = F)
# plot(leeds)
# plot(l, add = T)
