# Project settings - libraries you'll need to load
pkgs <- c("rgdal", "dplyr", "rgeos")
lapply(pkgs, library, character.only = TRUE)

# Load publicly available test data

# Option 1: clone the repository directly - if you have git installed
# system("git clone git@github.com:Robinlovelace/pct-data.git")

# Option 2: download and unzip the pct-data repository
# download.file("https://github.com/Robinlovelace/pct-data/archive/master.zip", destfile = "pct-data.zip", method = "wget")
# unzip("pct-data.zip", exdir = "pct-data")
# list.files(pattern = "pct") # check the data's been downloaded

# Option 3: download data manually from https://github.com/Robinlovelace/pct-data/archive/master.zip
