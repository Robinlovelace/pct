la <- "manchester"

library(knitr)
knit(
  input = "load.Rmd",
  output = paste0("pct-data/", la, "/model-output.html"),
  envir = globalenv()
  )
