library(shiny)
library(leaflet)
fluidPage(
  titlePanel("FixMyPath"),
  sidebarLayout(
    sidebarPanel("User input", width = 3
            ,checkboxGroupInput("display", label = "Display",
              choices = c("zones", "centroids", "some-lines", "all-lines"),
              selected = "zones"),
            selectInput("viewout", "Output to view", choices = c("Highest cycle counts", "Lowest number who cycle", "Highest potential", "Greatest extra cycling potential")),
      sliderInput("transp_zones", label = "Transparency of zone boundaries", min = 0, max = 1, value = 0.3)

    ),
    mainPanel(leafletOutput('myMap'))
  ))