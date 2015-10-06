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
