<script type="text/javascript" src="http://www.math.union.edu/~dpvc/transfer/mathjax/mathjax-in-github.user.js"></script>

# pct: Propensity to cycle tool

This repository allows users to estimate the 'propensity to cycle' between
different origin-destination pairs.

The project is funded by the Department for Transport (DfT) so the initial
case studies will be taken from the UK. However, it is expected that the 
methods will be of use elsewhere. For that reason, attempts have been made
to make the examples generalisable. All examples presented here
are reproducible using code in this [repository](https://github.com/npct/pct)
and data stored in the [pct-data repository](https://github.com/npct/pct-data/).

# Further information

More information on the tool can be found in this press release:
http://www.cedar.iph.cam.ac.uk/

There is also a document that summarises the tool in slightly more detail,
available [here](https://www.dropbox.com/s/8gn715qg99ymdl2/National%20Propensity%20to%20Cycle%20Tool%20info%20sheet.pdf?dl=0).



## A simple example

If you run the following lines of code on your computer from within
[this folder](https://github.com/Robinlovelace/pct/archive/master.zip), you should get the same result. This demonstrates the results are reproducible.


```r
# system("git clone git@github.com:Robinlovelace/pct-data.git") # see set-up.R
source("set-up.R")
# load some flow data
fleeds <- read.csv("pct-data/leeds/sample-leeds-centre-dists.csv")
# load the zones
leeds <- readOGR("pct-data/leeds/", "leeds-central-sample")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "pct-data/leeds/", layer: "leeds-central-sample"
## with 25 features and 3 fields
## Feature type: wkbPolygon with 2 dimensions
```

Now we can estimate propensity to cycle, by using the distance
decay function from [(Iacono et al. 2010)](http://linkinghub.elsevier.com/retrieve/pii/S0966692309000210):


<img src="http://www.sciweavers.org/tex2img.php?eq=p%20%3D%20%5Calpha%20%5Ctimes%20e%5E%7B-%20%5Cbeta%20%5Ctimes%20d%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0" align="center" border="0" alt="p = \alpha \times e^{- \beta \times d}" width="117" height="24" />

where $\alpha$, the proportion of made for the shortest distances
and $\beta$, the rate of decay
are parameters to be calculated from empirical evidence. 

To implement this understanding in R code we can use the following function:


```r
# Distance-dependent mode switch probs
iac <- function(x, a = 0.3, b = 0.2){
  a * exp(1)^(-b * x)
}
```

Apply this function to openly accessible flow data:


```r
fleeds$p_cycle <- iac(fleeds$dist / 1000)
fleeds$n_cycle <- fleeds$p_cycle * fleeds$All.categories..Method.of.travel.to.work
fleeds$pc1 <- fleeds$n_cycle - fleeds$Bicycle
```

Now we can create a simple visualisation of the result:


```r
plot(leeds)

for(i in which(fleeds$Area.of.residence == leeds$geo_code[1])){
  from <- leeds$geo_code %in% fleeds$Area.of.residence[i]
  to <- leeds$geo_code %in% fleeds$Area.of.workplace[i]
  x <- coordinates(leeds[from, ])
  y <- coordinates(leeds[to, ])
  lines(c(x[1], y[1]), c(x[2], y[2]), lwd = fleeds$pc1[i] )
}
```

![](README_files/figure-html/unnamed-chunk-4-1.png) 

