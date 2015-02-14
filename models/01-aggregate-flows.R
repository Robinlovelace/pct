# # # # # # # # # # # # # # # # # # # #
# Estimating ECP from aggregate flows #
# # # # # # # # # # # # # # # # # # # #

# Load example flow data:
# source("case-studies/leeds-minitest.R")
source("case-studies/leeds.R")

# Parameterise distance decay
# Which flows have cycling as 0%?
sel <- flow$Bicycle > 0
logistic <- lm(log(flow$pcycle[sel]) ~ flow$dist[sel])
plot(flow$dist, flow$pcycle) # the problem with flow data: many 0's and 1's
plot(logistic)
summary(logistic)
logistic$coefficients[2]
exp(logistic$coefficients[1])

# Binning variables
flow <- flow[flow$dist < 20.5, ]
brks <- c(0, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 9.5, 12.5, 15.5, 20.5)
flow$binned_dist <- cut(flow$dist, breaks = brks, include.lowest = T)
summary(flow$binned_dist) # summaries binned distances

# Create aggregate variables
gflow <- group_by(flow, binned_dist) %>%
  summarise(mdist = mean(dist), mbike = mean(pcycle),
    total = sum(All.categories..Method.of.travel.to.work))

plot(gflow$mdist, gflow$mbike,
  xlab = "Distance (miles)", ylab = "Percent cycling")

mod_loglin <- lm(log(gflow$mbike) ~ gflow$mdist)
mod_logsqr <- lm(log(gflow$mbike) ~ gflow$mdist + I(gflow$mdist^2))
mod_logcub <- lm(log(gflow$mbike) ~ gflow$mdist + I(gflow$mdist^2) + I(gflow$mdist^3))

plot(gflow$mdist, gflow$mbike,
  xlab = "Distance (miles)", ylab = "Percent cycling")
lines(gflow$mdist, exp(mod_loglin$fitted.values), col = "blue")
lines(gflow$mdist, exp(mod_logsqr$fitted.values), col = "red")
lines(gflow$mdist, exp(mod_logcub$fitted.values), col = "green")
