library(knitr)

la_all <-
   c("Bolton|Bury|Manchester|Oldham|Rochdale|Salford|Stockport|Tameside|Trafford|Wigan",
     "Blackpool")

for(i in la_all){
  la <- i
  knitr::knit2html(
    input = "load.Rmd",
    output = file.path("pct-data/", la, "/model-output.html"),
    envir = globalenv()
  )
}


