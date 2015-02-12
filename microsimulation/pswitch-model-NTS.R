# # # # # # # # # # # # # # # # # # # # #
# Propensity to cycle based on NTS data #
# # # # # # # # # # # # # # # # # # # # #

# Dependencies: libraries we'll be using
source("set-up.R") # installs pctpack package
pkgs <- c("foreign", "dplyr", "birk", "ggplot2")
lapply(pkgs, library, character.only = TRUE)

# # # # #
# TODO  #
# # # # #
# Add age-dependency of dd function

# # # # # # # # # # # # # #
# Stage 1: Load the data  #
# # # # # # # # # # # # # #

# # Set the data directory for the NTS data in spss format
# data_dir <- "/media/robin/data/data/UKDA-5340-spss/spss/spss19/"
#
# # Data source: National Travel Survey
# # Source: http://discover.ukdataservice.ac.uk/series/?sn=2000037
# trips <- read.spss(paste0(data_dir, "trip.sav")) # memisc::spss.system.file fails
# trips <- as_data_frame(trips) # 3.3 million rows of trip-level data
# # Massively reduce dataset's size by saving only relevant variables
# trips <- dplyr::select(trips, SurveyYear, TripID, DayID, IndividualID, HouseholdID, PSUID, NumStages, trips, modetrp = MainMode_B04ID, purp = TripPurpose_B04ID, TripTotalTime, JD)
#
# # Individual-level data
# ind <- read.spss(paste0(data_dir, "individual.sav"))
# ind <- as_data_frame(ind)
# ind <- select(ind, SurveyYear, IndividualID, HouseholdID, PSUID, age = Age_B01ID, Sex_B01ID, BicycleFreq_B01ID, WalkFreq_B01ID, OwnCycle_B01ID, Cycle12_B01ID, CycRoute_B01ID, disab_travel= MobDiffSum_B01ID)
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
#
# saveRDS(tsam, "pct-data/tsam.Rds") # save input data (saves loading NTS data)
tsam <- readRDS("pct-data/tsam.Rds") # load Rds data (read.spss is very slow!)

# tsam$dkm <- conv_unit(tsam$JD, mi, km) # set distance to km, if needed

# # # # # # # # # # # # # # # # #
# Probability of switching mode #
# # # # # # # # # # # # # # # # #

# Load pre-calculated distance decay parameters
params <- read.csv("input-data/dd_UrbanGenderCubic.csv") # dd paramets from NTS (Anna Goodman)
par_male_urb <- as.numeric(params[1, 2:5])
par_female_urb <- as.numeric(params[4, 2:5])

# Probability of switching to cycling by group (e.g. age)
tsam$pswitch <- 0 # create probability variable
tsam$pswitch[tsam$Sex_B01ID == "Male"] <-
  log_cubic(tsam$JD[tsam$Sex_B01ID == "Male"], par_male_urb)
tsam$pswitch[tsam$Sex_B01ID == "Female"] <-
  log_cubic(tsam$JD[tsam$Sex_B01ID == "Female"], par_female_urb)

tsam$pswitch[tsam$pswitch > 20] <- 0 # Remove ridiculously huge numbers!
summary(tsam$pswitch)

# Probability of switch by mode
tsam$pswitch[tsam$mode == "Bicycle"] <- 0

# Set probability of trips that are impossible to cycle to 0
tsam$pswitch[ tsam$mode == "Walk"] <- 0 # probability of switch for walkers = 0
tsam$age2 <- age_recat2(tsam$age)
tsam$difficulty_travel <- disab_recat(tsam$disab_travel)
tsam$pswitch[tsam$difficulty_travel == "Yes"] <- 0 # disability -> cannot cycle

# # # # # # # # # # # # # # # # # # #
# Model those switching to cycling  #
# # # # # # # # # # # # # # # # # # #

set.seed(666) # ensure results are reproducible
random_num <- runif(n = nrow(tsam), min = 0, max = 1) # random number
tsam$now_cycle <- tsam$pswitch > random_num # new cycle trips

tnowcycle <- tsam[tsam$now_cycle, ] # subset new cycle trips (for analysis)

# # # # # # #
# Analysis  #
# # # # # # #

sum(tsam$mode == "Bicycle") # original number of cyclists
sum(tsam$now_cycle) # number of additional cyclists

# This is just and example: see other R scripts for more on analysis
# Distance of new vs existing bicycle trips
ggplot(tsam) +
  geom_histogram(aes(JD, fill = mode)) +
  xlim(c(NA,20)) +
  facet_wrap(~ ifelse(now_cycle, "Now cycled", "Unchanged") , scales = "free")

