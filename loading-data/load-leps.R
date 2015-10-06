source("set-up.R")
# install.packages("rvest")
library(rvest)
# vignette("selectorgadget")
lep_page <- read_html("https://www.gov.uk/government/statistical-data-sets/local-enterprise-partnerships-leps-rural-urban-gis-shapefiles")
lep_page %>%
  html_nodes(".inline a") %>%
  html_attr("href") %>%
  paste0("https://www.gov.uk/", .) -> lep_links

lep_page %>%
  html_nodes(".inline a") %>%
  html_text() -> lep_names_full

lep_names <- gsub(" ", "-", lep_names_full)
lep_names <- gsub(",", "", lep_names)
lep_names <- gsub("&", "and", lep_names)


# Download and simplify for 1 lep
i <- 1
downloader::download(url = lep_links[i],
                     destfile = paste0(lep_names[i], ".zip"))
unzip(paste0(lep_names[i], ".zip"))
# gMapshape(dsn = list.files(pattern = ".shp"), percent = 0.3)
lep <- shapefile(list.files(pattern = ".shp"))
lep_out <- gBuffer(lep, width = 0)
row.names(lep_out) <- as.character(i)
leps <- SpatialPolygonsDataFrame(lep_out,
                                 data.frame(name = lep_names[i]))
file.remove(list.files(pattern = ".dbf|.prj|.sbn|.sbx|.shp|.shx"))

i <- 2
for(i in 2:length(lep_links)){
  print(paste0("Loading lep ", i, ", ", lep_names[i]))
  if(!file.exists(paste0(lep_names[i], ".zip"))){
    downloader::download(url = lep_links[i],
                         destfile = paste0(lep_names[i], ".zip"))
  }
  unzip(paste0(lep_names[i], ".zip"))
  old_names <- list.files(pattern = "&")
  new_names <- gsub("&", "and", old_names)
  file.rename(old_names, new_names)
  # gMapshape(dsn = list.files(pattern = ".shp"), percent = 0.3)
  lep <- shapefile(list.files(pattern = ".shp"))
  lep_out <- gBuffer(lep, width = 0)
  row.names(lep_out) <- as.character(i)
  lep_data <- data.frame(name = lep_names[i])
  row.names(lep_data) <- i
  lep <- SpatialPolygonsDataFrame(lep_out, lep_data)
  file.remove(list.files(pattern = ".dbf|.prj|.sbn|.sbx|.shp|.shx"))
  leps <- spRbind(leps, lep)
}

leps <- spTransform(leps, CRS("+init=epsg:4326"))
plot(leps) # it's still very detailed, and big
write_shape(leps, "leps.shp")

gMapshape("leps.shp", percent = 5)

leps_small <- read_shape("lepsmapshaped_5%.shp")
geojson_write(leps, file = "pct-bigdata/national/leps.geojson")

to_remove <- list.files(pattern = ".zip")
file.remove(to_remove)
file.remove(list.files(pattern = ".dbf|.prj|.sbn|.sbx|.shp|.shx"))
plot(leps)

leps <- geojson_read("pct-bigdata/national/leps.geojson", what = "sp")
plot(leps)

