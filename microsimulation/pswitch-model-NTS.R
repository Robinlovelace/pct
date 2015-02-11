# # # # # # # # # # # # # # # # # # # # #
# Propensity to cycle based on NTS data #
# # # # # # # # # # # # # # # # # # # # #

# Dependencies: libraries we'll be using
source("set-up.R") # installs pctpack package
pkgs <- c("foreign", "dplyr", "birk")
lapply(pkgs, library, character.only = TRUE)

# # # # # # # # # # # # # #
# Stage 1: Load the data  #
# # # # # # # # # # # # # #

# # Set the data directory for the NTS data in spss format
data_dir <- "/media/robin/data/data/UKDA-5340-spss/spss/spss19/"
#
# # Data source: National Travel Survey
# # Source: http://discover.ukdataservice.ac.uk/series/?sn=2000037
# trips <- read.spss(paste0(data_dir, "trip.sav")) # memisc::spss.system.file fails
# trips <- as_data_frame(trips) # 3.3 million rows of trip-level data
# # Massively reduce dataset's size by saving only relevant variables
# trips <- dplyr::select(trips, SurveyYear, TripID, DayID, IndividualID, HouseholdID, PSUID, NumStages, MainMode_B04ID, TripPurpose_B04ID, TripTotalTime, JD)
# trips <- rename(trips, modetrp = MainMode_B04ID, purp = TripPurpose_B04ID)
#
# # The individual-level data
# ind <- read.spss(paste0(data_dir, "individual.sav"))
# ind <- as_data_frame(ind)
# ind <- select(ind, SurveyYear, IndividualID, HouseholdID, PSUID, Age_B01ID, Sex_B01ID, BicycleFreq_B01ID, WalkFreq_B01ID, OwnCycle_B01ID, Cycle12_B01ID, CycRoute_B01ID, TravDiffSum_B01ID)
#
# # House-level data
# houses <- as.data.frame(read.spss(paste0(data_dir, "household.sav")))
# houses <- select(houses, SurveyYear, HouseholdID, PSUID, HHoldGOR_B02ID, NumBike, NumCar, CycLane_B01ID)
#
# # PSUID-level data
# psuid <- as.data.frame(read.spss(paste0(data_dir, "psu.sav")))
#
# # Sampling - filter by PSUID statistical region for microsimulation
# # replace with another e.g. "London Boroughs" - see summary(psuid$PSUStatsReg_B01ID)
# psuid <- filter(psuid, PSUStatsReg_B01ID == "Yorkshire/Humberside, Metropolitan")
#
# # Joining the levels together
# all <- inner_join(houses, psuid, by = "PSUID")
# ind <- inner_join(ind, all, by = "HouseholdID") # 7,000 individuals in Yorkshire non-met
# tsam <- inner_join(trips, ind)

# saveRDS(tsam, "pct-data/tsam.Rds") # save input data (saves loading NTS data)
tsam <- readRDS("pct-data/tsam.Rds")

tsam$dkm <- conv_unit(tsam$JD, mi, km) # set distance to km

params <- read.csv("input-data/dd_UrbanGenderCubic.csv") # dd paramets from NTS (Anna Goodman)
par_male_urb <- as.numeric(params[1, 2:5])
par_female_urb <- as.numeric(params[4, 2:5])

# Test these distance decay params:
d = seq(0,50,0.1)
plot(d, log_cubic(d, par = par_male_urb), ylim = c(0., 0.1)) # test plots
lines(d, log_cubic(d, par = par_female_urb), ylim = c(0., 0.1)) # test plots

# Probability of switching to cycling by group
tsam$pswitch <- 0 # create probability variable
tsam$pswitch[tsam$Sex_B01ID == "Male"] <-
  log_cubic(tsam$JD[tsam$Sex_B01ID == "Male"], par_male_urb)
tsam$pswitch[tsam$Sex_B01ID == "Female"] <-
  log_cubic(tsam$JD[tsam$Sex_B01ID == "Female"], par_female_urb)

tsam$pswitch[tsam$JD > 20] <- 0 # Remove ridiculously huge numbers!
summary(tsam$pswitch)

# Set probability of trips that are impossible to cycle to 0
tsam$pswitch[ tsam$mode == "Walk"] <- 0 # probability of switch for walkers = 0



