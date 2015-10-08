source("set-up.R")


downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/infuse_cnty_lyr_2011.zip",
                     destfile = "counties.zip")
unzip("counties.zip")
counties <- shapefile("infuse_cnty_lyr_2011.shp")
plot(counties)


downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_nhsat_2013_gen_clipped.zip",
                     destfile = "counties.zip")
unzip("counties.zip")
gMapshape("england_nhsat_2013_gen_clipped.shp", 3)
nhs_teams <- shapefile("england_nhsat_2013_gen_clippedmapshaped_3%.shp")
plot(nhs_teams)
nrow(nhs_teams)
geojson_write(nhs_teams, file = "pct-bigdata/national/nhs-teams.geojson")


downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_ccg_2013_gen_clipped.zip",
                     destfile = "counties.zip")
unzip("counties.zip")
gMapshape("england_ccg_2013_gen_clipped.shp", 5)
nhs_teams <- shapefile("england_ccg_2013_gen_clippedmapshaped_5%.shp")
plot(nhs_teams)
nrow(nhs_teams)
geojson_write(nhs_teams, file = "pct-bigdata/national/ccgs.geojson")

downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_nhscr_2013_gen_clipped.zip",
                     destfile = "counties.zip")
unzip("counties.zip")
gMapshape("england_nhscr_2013_gen_clipped.shp", 5)
nhs_teams <- shapefile("england_nhscr_2013_gen_clippedmapshaped_5%.shp")
plot(nhs_teams)
nrow(nhs_teams)

downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_fct_2011_gen_clipped.zip",
                     destfile = "counties.zip")
unzip("counties.zip")
gMapshape("England_fct_2011_gen_clipped.shp", 5)
counties <- shapefile("England_fct_2011_gen_clippedmapshaped_5%.shp")
plot(counties)
nrow(counties)

counties <- spTransform(counties, CRS("+init=epsg:4326"))
geojson_write(counties, file = "pct-bigdata/national/former-counties.geojson")
bbox(counties)

downloader::download("http://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_ct_1991.zip",
                     destfile = "counties.zip")
unzip("counties.zip")
counties <- shapefile("England_ct_1991_area.shp")
plot(counties)
nrow(counties)
counties <- spTransform(counties, CRS("+init=epsg:4326"))

# Assign las to counties
las <- readOGR(dsn = "pct-bigdata/national/cuas-mf.geojson", layer = "OGRGeoJSON")
proj4string(las) <- CRS("+init=epsg:4326")
plot(counties)
plot(las, add = T)

las$Region <- NA
for(i in (1:nrow(las))[-c(54)]){
  lasp <- SpatialPoints(coordinates(las[i,] ))
  proj4string(lasp) <- CRS("+init=epsg:4326")
  las$Region[i] <- counties[lasp,]$NAME
}

las$Region[grep("London", las$Region)] <- "London"

geojson_write(las, file = "pct-bigdata/national/las-pcycle-region.geojson")
# Outlier
las$Region[las$CTYUA12NM == "Torbay"] <- "Devon"
las$Region[las$CTYUA12NM == "Plymouth"] <- "Devon"
# Sheffield CA
las$Region[grep("Barnsley|Doncaster|Rotherham|Sheffield", las$CTYUA12NM)] <- "South Yorkshire"
las$Region[
  grep("Durham|Gateshead|Newcastle|Tyneside|South Tyne|Sunderl", las$CTYUA12NM)] <-
  "North East"
gm <- "Bolton|Bury|Oldham|Manchester|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan"
las$Region[grep(gm, las$CTYUA12NM)] <- "Greater Manchester"
lcr <- "Halton|Knowsley|Liverpool|Sefton|Helens|Wirral"
las$CTYUA12NM[grep(lcr, las$CTYUA12NM)]
las$Region[grep(lcr, las$CTYUA12NM)] <- "Liverpool City Region"
wm <- "Dudley|Sandwell|Solihull|Walsall|Wolverhampton"
las$Region[grep(wm, las$CTYUA12NM)] <- "West Midlands"
wy <- "Bradford|Calderdale|Kirklees|Leeds|Wakefield"
las$Region[grep(wy, las$CTYUA12NM)] <- "West Yorkshire"
las$Region[grep("Darl", las$CTYUA12NM)] <- "North East"

length(unique(las$Region))
write_shape(las, "/tmp/las-pcycle-region")
geojson_write(las, file = "pct-bigdata/national/las-pcycle-region.geojson")

# fix holes
slot(las, "polygons") <- lapply(slot(las, "polygons"), checkPolygonsHoles)
regions <- gUnionCascaded(las, id = las$Region)
plot(regions)
geojson_write(regions, file = "pct-bigdata/national/regions.geojson")

