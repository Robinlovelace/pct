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

# Individual-level data
ind <- read.spss(paste0(data_dir, "individual.sav"))
ind <- as_data_frame(ind)
ind <- select(ind, SurveyYear, IndividualID, HouseholdID, PSUID, age = Age_B01ID, Sex_B01ID, BicycleFreq_B01ID, WalkFreq_B01ID, OwnCycle_B01ID, Cycle12_B01ID, CycRoute_B01ID, disab_travel= MobDiffSum_B01ID)

# House-level data
houses <- as.data.frame(read.spss(paste0(data_dir, "household.sav")))
houses <- select(houses, SurveyYear, HouseholdID, PSUID, HHoldGOR_B02ID, NumBike, NumCar, CycLane_B01ID)

# PSUID-level data
psuid <- as.data.frame(read.spss(paste0(data_dir, "psu.sav")))

# # Sampling: a representative sample of the nts dataset
# set.seed(22)
# psuid <- filter(psuid, 1:nrow(psuid) %in% sample(nrow(psuid), size = nrow(psuid) / 10)) # a 10% sample!


# Sampling - filter by PSUID statistical region for microsimulation
# replace with another e.g. "London Boroughs" - see summary(psuid$PSUStatsReg_B01ID)
# psuid <- filter(psuid, PSUStatsReg_B01ID == "Yorkshire/Humberside, Metropolitan")

# Joining the levels together
all <- inner_join(houses, psuid, by = "PSUID")
ind <- inner_join(ind, all, by = "HouseholdID") # 7,000 individuals in Yorkshire non-met
tsam <- inner_join(trips, ind)

saveRDS(tsam, "pct-data/tsam.Rds") # save input data (saves loading NTS data)
tsam <- readRDS("pct-data/tsam.Rds") # load Rds data (read.spss is very slow!)