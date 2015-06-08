la <- "manchester"

library(knitr)
knitr::knit2html(
  input = "load.Rmd",
  output = paste0("pct-data/", la, "/model-output.html"),
  envir = globalenv()
  )
