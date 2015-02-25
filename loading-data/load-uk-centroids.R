# # # # # # # # # # # # # # # # #
# Population weighted centroids #
# # # # # # # # # # # # # # # # #

library(raster)

# url = "https://geoportal.statistics.gov.uk/Docs/Boundaries/Lower_layer_super_output_areas_(E+W)_2011_Population_Weighted_Centroids_V2.zip"
# download.file(url = url, destfile = "lsoa-cents.zip", method = "curl")
#
# url = "https://geoportal.statistics.gov.uk/Docs/Boundaries/Middle_layer_super_output_areas_(E+W)_2011_Population_Weighted_Centroids_V2.zip"
# download.file(url = url, destfile = "msoa-cents.zip", method = "curl")
#
# url = "https://geoportal.statistics.gov.uk/Docs/Boundaries/Workplace_zones_(E+W)_2011_Population_Weighted_Centroids.zip"
# download.file(url = url, destfile = "wpz-cents.zip", method = "curl")
#
# url = "https://geoportal.statistics.gov.uk/Docs/Boundaries/Output_areas_(E+W)_2011_Population_Weighted_Centroids_V2.zip"
# download.file(url = url, destfile = "oa-cents.zip", method = "curl")
#
# zips <- list.files(path = ".", pattern = "*.zip")
# dir.create("bigdata/centroids")
# for(i in zips){
#   unzip(zipfile = i, exdir = "bigdata/centroids/")
# }
# file.remove(zips)

cents_msoa <- shapefile("bigdata/centroids/MSOA_2011_EW_PWC.shp")
# plot(cents_msoa)
