# # # # #
# setup #
# # # # #

source("set-up.R") # load required packages

# # # # # # # # # # # #
# Load the test data  #
# (Available online)  #
# # # # # # # # # # # #

# Load the geographical data
leeds <- readRDS("pct-data/leeds/leeds-msoas-simple.Rds")
cents <- gCentroid(leeds, byid = T) # centroids of the zones

# Load flow data - see leeds-all.R to see how this was created
fleeds <- read.csv("pct-data/leeds/msoa-flow-leeds-all.csv")
fleeds$dist <- fleeds$dist / 1000

# Compare estimated and actual number of cyclists
# plot(fleeds$Bicycle, fleeds$pc)
cor(fleeds$Bicycle, fleeds$pc)

# Prepare for aggregate flow analysis
flow <- fleeds
flow <- rename(flow, All = All.categories..Method.of.travel.to.work )
flow$pcycle <- flow$Bicycle / flow$All * 100
