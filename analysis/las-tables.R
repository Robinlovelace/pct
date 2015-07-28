# Generate tables from las data

las$difference <- las$expected - las$Bicycle_All
las$pcycle_dif <- las$pcycle_exp - las$pcycle

las$expected <- round(las$expected)
las$shortcar <- las$shortcar * 100

t0 <- tail(las@data[order(las$pcycle),], 10)
t0 <- t0[10:1,]
t0$NAME
t0$expected

t0 <- select(t0, Name = NAME, `Current %` = pcycle, `Expected %` = pcycle_exp, `Current (n)` = Bicycle_All, `Expected (n)` = expected, `% short car` = shortcar)
kable(t0, digits = 1)

t0.1 <- head(las@data[order(las$pcycle),], 10)
t0.1$NAME
t0.1$expected

t0.1 <- select(t0.1, Name = NAME, `Current %` = pcycle, `Expected %` = pcycle_exp, `Current (n)` = Bicycle_All, `Expected (n)` = expected, `% short car` = shortcar)

kable(t0.1, digits = 2)

t1 <- tail(las@data[order(las$expected),], 10)
t1$NAME
t1$expected

t1 <- select(t1, Name = NAME, `Current %` = pcycle, `Expected %` = pcycle_exp, `Current (n)` = Bicycle_All, `Expected (n)` = expected, `% short car` = shortcar)
kable(t1, digits = 2)

t2 <- tail(las@data[order(las$pcycle_exp),], 10)
t2$NAME
t2$pcycle_exp

t3 <- tail(las@data[order(las$difference),], 10)
t3$NAME
t3$pcycle_exp

t4 <- tail(las@data[order(las$pcycle_dif),], 10)
t4$NAME
t4$pcycle_exp