library(knitr)

la_all <- c("Bedfordshire", "Berkshire", "Buckinghamshire")

for(i in la_all){
  region <- i
  print(i)
  knitr::knit2html(
    input = "load.Rmd",
    output = file.path("pct-data/", la, "/model-output.html"),
    envir = globalenv()
  )
}

regions$Region[1:10]
dput(as.character(regions$Region[2:4]))

# las <- readOGR(dsn = "pct-bigdata/national/cuas-mf.geojson", layer = "OGRGeoJSON")
# las_names <- las$CTYUA12NM
# las_names <- las_names[order(las_names)]
# las_names <- as.character(las_names)
# head(las_names)
# dput(las_names[1:4])
