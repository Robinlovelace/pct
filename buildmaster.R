la <- "coventry"

library(knitr)
knitr::knit2html(
  input = "load.Rmd",
  output = file.path("pct-data", la, "model-output.html"),
  envir = globalenv()
  )
