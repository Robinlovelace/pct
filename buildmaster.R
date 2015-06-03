la <- "manchester"

library(knitr)
knit(
  input = "load.Rmd",
  output = file.path("pct-data", la, "model-output.html"),
  envir = globalenv()
  )
