# Project settings - libraries you'll need to load
# NB: devtools allows installation of the latest packages
if(!require(devtools)) install.packages("devtools")
if(!require(stplanr)) install_github("robinlovelace/stplanr")
if(!require(geojsonio)) install_github("ropensci/geojsonio")
pkgs <- c(
  "ggmap",
  "tmap",
  "foreign", # loads external data
  "rgdal",   # for loading and saving geo* data
  "dplyr",   # for manipulating data rapidly
  "rgeos",   # GIS functionality
  "raster",  # GIS functions
  "maptools", # GIS functions
  "stplanr", # Sustainable transport planning with R
  "geojsonio" # loads geojsons
  )
# Which packages do we require?
reqs <- as.numeric(lapply(pkgs, require, character.only = TRUE))
# Install packages we require
if(sum(!reqs) > 0) install.packages(pkgs[!reqs])
# Load publicly available test data

# Option 1: clone the repository directly - if you have git installed
# system2("git", args=c("clone", "git@github.com:Robinlovelace/pct-data.git", "--depth=1"))

# Option 2: download and unzip the pct-data repository
# download.file("https://github.com/Robinlovelace/pct-data/archive/master.zip", destfile = "pct-data.zip", method = "wget")
# unzip("pct-data.zip", exdir = "pct-data")
# list.files(pattern = "pct") # check the data's been downloaded

# Option 3: download data manually from https://github.com/Robinlovelace/pct-data/archive/master.zip

cckey <- Sys.getenv('CS_API_KEY')
