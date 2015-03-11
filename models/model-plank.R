# Simple exponential decay function

dd_planck <- function(x, a, b, k){
  (a * x^b) / (exp(k * x))
}

x <- seq(0, 400, by = 0.1)

plot(x,dd_planck(x, a = 1, b = 0.3, k = 0.2))

output <- nls(mbike ~ mod_plank(mdist, a, b, k), data = gflow, start = list(a = 0.1, b = 0.3, k = 0.2))

df <- data.frame(mdist = x)

predict(object = output, df)

plot(gflow$mdist, gflow$mbike, ylim = c(0, 0.03), xlim = c(0, 400))
lines(x, predict(object = output, df))

glm(mbike ~ mod_plank(mdist, a, b, k), )