# proportion of commuter trips by bike more than 20km

source("set-up.R")

# Set the data directory for the NTS data in spss format
# data_dir <- "private-data/spss19/"
data_dir <- "/media/robin/data/data/UKDA-5340-spss/spss/spss19/"
list.files(data_dir) # check which files are available

# Data source: National Travel Survey
# Source: http://discover.ukdataservice.ac.uk/series/?sn=2000037
trips <- read.spss(paste0(data_dir, "trip.sav")) # memisc::spss.system.file fails
trips <- as_data_frame(trips) # 3.3 million rows of trip-level data
names(trips)
# Massively reduce dataset's size by saving only relevant variables
trips <- dplyr::select(trips, SurveyYear, TripID, DayID, IndividualID, HouseholdID, PSUID, NumStages, modetrp = MainMode_B04ID, purp = TripPurpose_B04ID, TripTotalTime, JD, NumStages )

b <- filter(trips, modetrp == "Bicycle" & purp == "Commuting")
maxdis <- 20 / 1.61
hist(b$JD, xlim = c(0, maxdis))
sum(b$JD > maxdis) / nrow(b)
