library(shiny)
library(leaflet)
fluidPage(
  titlePanel("FixMyPath"),
  sidebarLayout(
    sidebarPanel("User input", width = 3
        , checkboxInput("transp_zones", label = "Transparency of zone boundaries", value = FALSE)
        , sliderInput("transp_fast", label = "Transparency of paths", min = 0, max = 1, value = 0.7)
        , selectInput("feature", "Features", choices = c("none", "cycleparking", "collisions", "bikeshops"))
        , selectInput("lines", "Select Lines", choices = c("Top 10", "Top 50", "Bottom 10", "Bottom 50"))
        , radioButtons("scenario", label = "Scenario", choices = list("Current level of cycling (clc)" = 1,
                                                                           "Potential level of cycling (plc)" = 2,
                                                                           "Extra cycling potential (ecp)" = 3), selected = 1)
    ),
    mainPanel("Welcome to",
              a(href = "https://robinlovelace.shinyapps.io/fixMyPath/", "fixMyPath"),
              p("fixMyPath is a shiny app written to facilitate better bicycle path planning in Leeds, the UK and eventually the world. If you'd like to get involved, please check-out, test and contribute-to the fully reproducible code..."),
              a(href = "https://github.com/Robinlovelace/pct/tree/master/shiny-test/fixMyPath_basic", strong("HERE!"), target="_blank"),
              leafletOutput('map', height = 600))
    ))
