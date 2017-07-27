
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(ggplot2)
library(ggthemes)



shinyServer(function(input, output, session) {
  #Creates a map
  output$map <- renderLeaflet({leaflet(NFL2016stats) %>%
      addProviderTiles(providers$Stamen.Toner) %>%
      setView(lng = -83.67, lat = 38.93, zoom = 4)
  })
  
  #reset the view
  observe({
    input$reset_button
    leafletProxy("map") %>% setView(lng = -83.67, lat = 38.93, zoom = 4)
  })
  
  
  #Returns teams within range
  TeamBounds <- reactive({
    if (is.null(input$map_bounds))
      return(NFL2016stats[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(NFL2016stats,
           latitude >= latRng[1] & latitude <= latRng[2] &
             longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  #scatterplot
  output$scatterNFL2016 <- renderPlot({
    # If no zipcodes are in view, don't plot
    if (nrow(TeamBounds()) == 0)
      return(NULL)
    
    print(xyplot(Rank ~ PointsPerGame, data = TeamBounds(),
                 xlim = range(NFL2016stats$Rank), ylim = range(NFL2016stats$PointsPerGame)))
  })
  
  #observations
  observe({
    colorBy <- input$color
    sizeBy <- input$size
    
    colorData <- NFL2016stats[[colorBy]]
    
    
    pal <- colorNumeric("magma", colorData, reverse = TRUE)
    
    
    if(sizeBy == "Rank"){
      radius <- rank(-NFL2016stats[[sizeBy]])/length(NFL2016stats[[sizeBy]]) * 150000
    } 
    else {
      radius <- NFL2016stats[[sizeBy]] / max(NFL2016stats[[sizeBy]]) * 150000
    }
    
    leafletProxy("map", data = NFL2016stats) %>%
      clearShapes() %>%
      addCircles(lng = ~longitude,lat = ~latitude, radius= radius, layerId = ~Team,
                 stroke=FALSE, fillOpacity=0.7, fillColor=pal(colorData)) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                layerId="colorLegend")
    
  })
  
  #creating the map popups 
  showPopup <- function(Team, latitude, longitude) {
    selectedTeam <- NFL2016stats[NFL2016stats$Team == Team,]
    content <- as.character(tagList(
      tags$h4(selectedTeam$Team),
      tags$h4("Rank:", as.integer(selectedTeam$Rank)),
      sprintf("Super Bowl Wins: %s",selectedTeam$SuperbowlWin), tags$br(),
      sprintf("Points Per Game: %s", selectedTeam$PointsPerGame), tags$br(),
      sprintf("Yards Per Game: %s", selectedTeam$YardsPerGame)
    ))
    leafletProxy("map") %>% addPopups(longitude, latitude, content, layerId = Team)
  }
  
  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      showPopup(event$id, event$lat, event$lng)
    })
  })
  
  output$scatterNFL2016 <- renderPlot({
    # If no zipcodes are in view, don't plot
    if (nrow(TeamBounds()) == 0)
      return(NULL)
    
    print(xyplot(PointsPerGame ~ Rank, data = TeamBounds(), xlim = range(NFL2016stats$Rank), ylim = range(NFL2016stats$PointsPerGame)))
  })
  
  output$superbowlhist <- renderPlot({
    
    if (nrow(TeamBounds()) == 0)
      return(NULL)
    
    sumwins <- sum(TeamBounds()$SuperbowlWin)
    
    barplot(sumwins,
            main = "Superbowl Wins (visible teams)",
            ylab = "Wins",
            ylim = c(0,50),
            col = 'blue',
            border = 'white')
  })
  
  
  output$NFLtable <- DT::renderDataTable({
    df <- datatable %>%
      filter(
        is.null(input$teams) | Team %in% input$teams,
        Rank >= input$minRank,
        Rank <= input$maxRank)
  })
  
  output$InteractiveScatter <- renderPlot({
    xvar <- input$xaxis
    yvar <- input$yaxis
    
    xdata <- NFL2016stats[[xvar]]
    ydata <- NFL2016stats[[yvar]]
    
    Conference <- NFL2016stats$Conference
    
    Division <- NFL2016stats$Division
    
    tempdf <- data.frame(xdata, ydata, Conference, Division)
    
    groupchoice <- input$cluster

    
    
    if(groupchoice == "Division") {
      ggplot(data = tempdf,aes(xdata, ydata, color = Division, shape = Conference)) +
        geom_point(cex = 5) +
        xlim(range(xdata)) +
        ylim(range(ydata)) +
        xlab(xvar) +
        ylab(yvar) +
        scale_color_manual(values = c("navy","dodgerblue3","steelblue2","turquoise1", "orangered3", "firebrick3", "violetred2", "red")) +
        theme_wsj()
    } else {ggplot(data = tempdf,aes(xdata, ydata, color = Conference, shape = Conference)) +
        geom_point(cex = 5) +
        xlim(range(xdata)) +
        ylim(range(ydata)) +
        xlab(xvar) +
        ylab(yvar) +
        scale_color_manual(values = c("dodgerblue3", "firebrick3")) +
        theme_wsj()
      }
    
    
    
  })
  
  
  
  
})


