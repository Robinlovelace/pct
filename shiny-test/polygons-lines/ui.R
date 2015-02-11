library(shiny)
library(leaflet)
fluidPage(
  titlePanel("FixMyPath"),
  sidebarLayout(
    sidebarPanel("User input", width = 3
            ,checkboxGroupInput("display", label = "Display",
              choices = c("zones", "centroids", "some-lines", "all-lines"),
              selected = "zones"),
            selectInput("viewout", "Output to view", choices = c("Highest cycle counts", "Lowest number who cycle", "Highest potential", "Greatest extra cycling potential"))

    ),
    mainPanel(leafletOutput('myMap'))
  ))