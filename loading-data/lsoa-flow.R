source("set-up.R")

dsource <- "F:/flow-data/WM12EW[CT0489]_lsoa.zip"

unzip(zipfile = dsource, exdir = tempdir())
list.files(tempdir())

flow <- read_csv(file.path(tempdir(), "WM12EW[CT0489]_lsoa.csv"))
object.size(flow) / 1000000000 # 8 gb of data!!!

# reduce to top n flows
flo <- top_n(flow, n = 10000, wt = flow$AllMethods_AllSexes_Age16Plus)
flo <- flo[ !flo$`Area of usual residence` == flo$`Area of Workplace`,]

head(flo[1:4])
flo <- dplyr::select(flo, `Area of Workplace`, everything())
flo <- dplyr::select(flo, `Area of usual residence`, everything())

# load lsoas - see load-uk-centroids.R
head(cents_lsoa)
flo <- data.frame(flo)

l <- od2line(flo, cents_lsoa)
plot(l)

l <- spTransform(l, CRS("+init=epsg:4326"))
bbox(l)

library(leaflet)
leaflet() %>% addTiles() %>% addPolylines(data = l)
