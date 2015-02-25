# Load public access flow data
# Set file location (will vary - download files from here:
# https://wicid.ukdataservice.ac.uk/cider/wicid/downloads.php)
f <- "bigdata/public-flow-data-msoa/wu03ew_v2.csv"
flowm <- read.csv(f) # load public msoa-level flow data