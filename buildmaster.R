library(knitr)

la_all <- c("Barking-and-Dagenham", "Barnet",
            "Barnsley", "Bath-and-North-East-Somerset")

for(i in la_all){
  la <- i
  knitr::knit2html(
    input = "load.Rmd",
    output = file.path("pct-data/", la, "/model-output.html"),
    envir = globalenv()
  )
}


las <- readOGR(dsn = "pct-bigdata/national/cuas-mf.geojson", layer = "OGRGeoJSON")
las_names <- las$CTYUA12NM
las_names <- las_names[order(las_names)]
las_names <- as.character(las_names)
head(las_names)
dput(las_names[1:4])
