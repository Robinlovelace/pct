library(knitr)

la_all <- c("devon", "norfolk")

for(la in la_all){
  knitr::knit2html(
    input = "load.Rmd",
    output = file.path("pct-data", la, "model-output.html"),
    envir = globalenv()
  )
}


