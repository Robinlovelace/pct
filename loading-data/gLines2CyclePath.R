plan = "fastest"

gLines2CyclePath <- function(l, plan = "fastest"){
  if(is.null(cckey)) stop("You must have a CycleStreets.net api key saved as 'cckey'")
  coord_list <- lapply(slot(l, "lines"), function(x) lapply(slot(x, "Lines"),
    function(y) slot(y, "coords")))
  output <- vector("list", length(coord_list))
  api_base <- sprintf("https://%s@api.cyclestreets.net/v2/", cckey)
  for(i in 1:length(output)){
    from <- coord_list[[i]][[1]][1, ]
    to <- coord_list[[i]][[1]][2, ]
    from_string <- paste(from, collapse = ",")
    to_string <- paste(to, collapse = ",")
    ft_string <- paste(from_string, to_string, sep = "|")
    journey_plan <- sprintf("journey.plan?waypoints=%s&plan=%s", ft_string, plan)
    request <- paste0(api_base, journey_plan)

    # Thanks to barry Rowlingson for this part:
    obj <- jsonlite::fromJSON(request)

    # Catch 'no route found' stuff
    if(is.null(obj$features[1,]$geometry$coordinates[[1]])){
      route <- SpatialLines(list(Lines(list(Line(rbind(from, to))), row.names(l[i,]))))
      df <- data.frame(matrix(NA, ncol = 6))
      names(df) <- c("plan", "start", "finish", "length", "time", "waypoint")
    } else {
    route <- SpatialLines(list(Lines(list(Line(obj$features[1,]$geometry$coordinates[[1]])), ID = row.names(l[i,]))))
    df <- obj$features[1,]$properties
    }

    row.names(df) <- row.names(l[i,])
    route <- SpatialLinesDataFrame(route, df)

    # Status checker: % downloaded
    if(i == 10)
      print("The first 10 routes have been saved, be patient. I'll say when 10% have been loaded.")
    perc_temp <- i %% round(nrow(l) / 10)
    if(!is.na(perc_temp) & perc_temp == 0){
      print(paste0(round(100 * i/nrow(flow)), " % out of ", nrow(flow),
        " distances calculated")) # print % of distances calculated
    }

    if(i == 1){
      output <- route
    }
    else{
      output <- maptools::spRbind(output, route)
    }
  }
  proj4string(output) <- CRS("+init=epsg:4326")
  output
}