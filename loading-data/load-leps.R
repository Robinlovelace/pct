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

# Download and simplify for 1 lep
i <- 1
downloader::download(url = lep_links[i],
                     destfile = paste0(lep_names[i], ".zip"))
unzip(paste0(lep_names[i], ".zip"))
gMapshape(dsn = list.files(pattern = ".shp"), percent = 0.3)
lep <- shapefile(list.files(pattern = "%.shp"))
lep_out <- gBuffer(leps, width = 0)
row.names(lep_out) <- as.character(i)
leps <- SpatialPolygonsDataFrame(lep_out,
                                 data.frame(name = lep_names[i]))
file.remove(list.files(pattern = ".dbf|.prj|.sbn|.sbx|.shp|.shx"))


for(i in 2:length(lep_links)){
  downloader::download(url = lep_links[i],
                       destfile = paste0(lep_names[i], ".zip"))
  unzip(paste0(lep_names[i], ".zip"))
  gMapshape(dsn = list.files(pattern = ".shp"), percent = 0.3)
  lep <- shapefile(list.files(pattern = "%.shp"))
  lep_out <- gBuffer(lep, width = 0)
  row.names(lep_out) <- as.character(i)
  lep_data <- data.frame(name = lep_names[i])
  row.names(lep_data) <- i
  lep <- SpatialPolygonsDataFrame(lep_out, lep_data)
  file.remove(list.files(pattern = ".dbf|.prj|.sbn|.sbx|.shp|.shx"))
  leps <- spRbind(leps, lep)
}

