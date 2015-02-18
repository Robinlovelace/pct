pkgs <- c("shiny", "leaflet", "ggmap", "RColorBrewer")
lapply(pkgs, library, character.only = TRUE)

if(!grepl("fix", getwd())) old <- setwd("shiny-test/fixMyPath") # Set wd

# Load data
l <- readRDS("al.Rds")
lfast <- l[ l$color == "green", ]
lquiet <- l[ l$color == "red", ]

flows <- read.csv("al-flow.csv")
leeds <- readRDS("leeds-msoas-simple.Rds")

shinyServer(function(input, output){

  cents <- coordinates(leeds)
  cents <- SpatialPointsDataFrame(cents, data = leeds@data, match.ID = F)

  map <- leaflet() %>%
    addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png")

  zoom <- reactive({
    ifelse(is.null(input$map_zoom),11,input$map_zoom)
  })

  center <- reactive({
    if(is.null(input$map_bounds)) {
      c(-1.549167, 53.799722)
    } else {
      map_bounds <- input$map_bounds
      c((map_bounds$north + map_bounds$south)/2.0,(map_bounds$east + map_bounds$west)/2.0)
    }
  })

  output$map = renderLeaflet(map%>%
                                 addPolygons(data = leeds
                                             , fillOpacity = 0.4
                                             , opacity = (input$transp_zones)*.4
                                             , fillColor = leeds$color_pcycle
                                 ) %>%
                                 addPolylines(data = lfast, color = "red"
                                              , opacity = input$transp_fast
                                              , popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$fastest_distance_in_m / 1000, 1), round(flows$p_cycle * 100, 2))
                                 ) %>%
                                 addPolylines(data = lquiet, color = "green",
                                              , opacity = input$transp_fast
                                              , popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$quietest_distance_in_m / 1000, 1), round(flows$p_cycle * 100, 2))
                                 ) %>%
                                 addCircleMarkers(data = cents
                                                  , radius = 2
                                                  , color = "black"
                                                  , popup = sprintf("<b>Journeys by bike: </b>%s%%", round(leeds$pCycle * 100, 2))) %>%
                                 addGeoJSON(RJSONIO::fromJSON(sprintf("%s.geojson", input$feature))) %>%
                                 mapOptions(zoomToLimits = "first")
  )
})