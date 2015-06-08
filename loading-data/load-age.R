# Load age data at msoa level
source("set-up.R")
# aim: % young ppl short (<5 km) distances per msoa

# From https://www.nomisweb.co.uk/census/2011/bulk/r5
download.file(url = "https://www.nomisweb.co.uk/output/census/2011/wp7102ew_msoa.zip", destfile = "/media/robin/data/data-to-add/wp7102ew_msoa-distance-ttw-age.zip", method = "wget")
unzip("/media/robin/data/data-to-add/wp7102ew_msoa-distance-ttw-age.zip", exdir = "private-data/")
download.file(url = "https://www.nomisweb.co.uk/output/census/2011/wp7101ew_msoa.zip", destfile = "/media/robin/data/data-to-add/wp7101ew_msoa-method-ttw-age.zip", method = "wget")
unzip("/media/robin/data/data-to-add/wp7101ew_msoa-method-ttw-age.zip", exdir = "private-data/")

av <- read.csv("private-data/wp7102ew_msoa/WP7102EWDATA.CSV", stringsAsFactors = F)
names(av)
names_young_sub_10km <- "geo|0001|0002|0008|0014|0020"
av <- dplyr::select(av, matches(names_young_sub_10km))
psy <- rowSums(av[3:5]) / av$WP7102EW0001
av <- data.frame(geo_code = av$GeographyCode, perc_short_young = psy)
head(av)
summary(av)
write.csv(av, "private-data/wp7102ew_msoa/perc_short_young.csv")
