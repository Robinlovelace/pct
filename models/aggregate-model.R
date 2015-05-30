# # # # # # # # # # # # # # # # # # # #
# Estimating ECP from aggregate flows #
# # # # # # # # # # # # # # # # # # # #

# set-up packages
source("set-up.R")

# Load example flow data with distance and centroids - various sources possible!
# requires flow level data in the following form:
# df <- tbl_df(flow)
#  df
# Source: local data frame [41,653 x 18]
#
# Area.of.residence Area.of.workplace All Work.mainly.at.or.from.home
# 1          E02001019         E02001019 472                           0
# 2          E02001019         E02001020  78                           0
# 3          E02001019         E02001021 101                           0
# ..               ...               ... ...                         ...
# Variables not shown: Underground..metro..light.rail..tram (int), Train (int), Bus..minibus.or.coach
# (int), Taxi (int), Motorcycle..scooter.or.moped (int), Driving.a.car.or.van (int),
# Passenger.in.a.car.or.van (int), Bicycle (int), On.foot (int),
# Other.method.of.travel.to.work (int), dist (dbl), clc (dbl)
# source("case-studies/leeds-minitest.R")
# source("case-studies/leeds.R")
# source("loading-data/load-flow.R")

# # # # # #
# Models  #
# # # # # #

# Estimate rate of cycling based on dd formula (see ?dd_logsqr)

# mod_logsqr <- glm(clc ~ dist + I(dist^0.5), data = flow, weights = All, family = "quasipoisson")

# mod_logsqr <- glm(clc ~ dist + I(dist^0.5) + avslope, data = flow, weights = All, family = "quasipoisson") # with hilliness

# mod_logsqr <- glm(clc ~ dist_fast + I(dist_fast^0.5) + avslope, data = flow, weights = All, family = "quasipoisson") # with hilliness + fastest distance


mod_logsqr <- glm(clc ~ dist_fast + I(dist_fast^0.5) + avslope + avslope * dist_fast, data = flow, weights = All, family = "quasipoisson")

mod_inf <- glm(clc ~ dist_fast + I(dist_fast^0.5) + avslope + distq_f + avslope * dist_fast, data = flow, weights = All, family = "quasipoisson")

# mod_logsqr <- glm(clc ~ dist_fast + I(dist_fast^0.5) + avslope + distq_f, data = flow, weights = All, family = "quasipoisson") # + quietness detour

cor(flow$clc, mod_logsqr$fitted.values)
cor(flow$clc, mod_inf$fitted.values)

summary(mod_logsqr)

flow$plc <- NA
flow$plc[!is.na(l$All)] <- mod_logsqr$fitted.values # create plc from model

# # # # # # # #
# Diagnostics #
# # # # # # # #

 summary(mod_logsqr) # goodness of fit
#
# # Binning variables and validation
# brks <- c(0, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 9.5, 12.5, 15.5, 20.5, 1000)
# flow$binned_dist <- cut(flow$dist, breaks = brks, include.lowest = T)
# summary(flow$binned_dist) # summaries binned distances
#
# # Create aggregate variables
# gflow <- group_by(flow, binned_dist) %>%
#   summarise(dist = mean(dist), mbike = mean(clc),
#     total = sum(All.categories..Method.of.travel.to.work))
#
# lines(gflow$dist, gflow$clc, col = "green", lwd = 3)
#
# plot(gflow$dist, gflow$clc,
#   xlab = "Distance (miles)", ylab = "Percent cycling")

# # # # # # # # # # # # # # #
# Alternative models of plc #
# # # # # # # # # # # # # # #

# mod_logsqr_nofam <- glm(clc ~ dist + I(dist^0.5), data = flow, weights = All) # no link -> poor fit
# mod_logsqr_qbin <- glm(clc ~ dist + I(dist^0.5), data = flow, weights = All, family = "quasibinomial") # exactly same fit as quasipoisson
# mod_logsqr_qpois <- glm(clc ~ dist + I(dist^0.5), data = flow, weights = All, family = "quasipoisson")
# mod_loglin <- lm(log(gflow$mbike) ~ gflow$dist)
# mod_logsqr <- lm(log(gflow$mbike) ~ gflow$dist + I(gflow$dist^2))
# mod_logcub <- lm(log(gflow$mbike) ~ gflow$dist + I(gflow$dist^2) + I(gflow$dist^3))
# mod_logsqr <- glm(clc ~ dist + I(dist^0.5), data = flow, weights = All, family = "poisson")
# mod_logsqr <- glm(clc ~ dist + I(dist^0.5), data = flow, weights = All, family = "poisson")
# mod_logsqr_lin <- lm(log(clc) ~ dist + I(dist^0.5), data = gflow, weights = total)
# mod_logsqr_lin_all <- lm(log(clc) ~ dist + I(dist^0.5), data = flow, weights = All)
# summary(mod_logsqr_lin)
#
# plot(gflow$dist, gflow$mbike,
#   xlab = "Distance (miles)", ylab = "Percent cycling")
# lines(gflow$dist, exp(mod_loglin$fitted.values), col = "blue")
# lines(gflow$dist, exp(mod_logsqr$fitted.values), col = "red")
# lines(gflow$dist, exp(mod_logcub$fitted.values), col = "green")
