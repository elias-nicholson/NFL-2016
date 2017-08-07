if (!require(shiny))
  install.packages("shiny")
if (!require(leaflet))
  install.packages("leaflet")
if (!require(RColorBrewer))
  install.packages("RColorBrewer")
if (!require(scales))
  install.packages("scales")
if (!require(lattice))
  install.packages("lattice")
if (!require(dplyr))
  install.packages("dplyr")
if (!require(ggplot2))
  install.packages("ggplot2")
if (!require(ggthemes))
  install.packages("ggthemes")
if (!require(ggpmisc))
  install.packages("ggpmisc")
if (!require(DT))
  install.packages("DT")
if (!require(readr))
  install.packages("readr")
if (!require(sp))
  install.packages("sp")

library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggpmisc)
library(DT)


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
    
    my.formula <- y ~ x
    
    
    if(groupchoice == "none") {
      nplot<- ggplot(data = tempdf,aes(xdata, ydata, color = "firebrick3")) +
        geom_point(cex = 5) +
        xlim(range(xdata)) +
        ylim(range(ydata)) +
        xlab(xvar) +
        ylab(yvar) +
        theme_wsj()
      if(input$regression == "none"){
        print(nplot)
      }
      if(input$regression == "linear"){
        print(nplot +
                geom_smooth(method = lm, se = FALSE, formula = my.formula) +
                stat_poly_eq(formula = my.formula,
                             eq.with.lhs = "italic(hat(y))~`=`~",
                             aes(label = paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~")), 
                             parse = TRUE, color = "black"))
      }
      if(input$regression == "loess"){
        print(nplot +
                geom_smooth(se = FALSE))
      }
      
    } 
    
    if(groupchoice == "Division") {
     dplot<- ggplot(data = tempdf,aes(xdata, ydata, color = Division, shape = Conference)) +
        geom_point(cex = 5) +
        xlim(range(xdata)) +
        ylim(range(ydata)) +
        xlab(xvar) +
        ylab(yvar) +
        scale_color_manual(values = c("navy","dodgerblue3","steelblue2","turquoise1", "orangered3", "firebrick3", "violetred2", "red")) +
        theme_wsj()
     if(input$regression == "none"){
       print(dplot)
     }
     if(input$regression == "linear"){
       print(dplot +
         geom_smooth(method = lm, se = FALSE, formula = my.formula) +
           stat_poly_eq(formula = my.formula,
                        eq.with.lhs = "italic(hat(y))~`=`~",
                        aes(label = paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~")), 
                        parse = TRUE))
     }
     if(input$regression == "loess"){
       print(dplot +
         geom_smooth(se = FALSE))
     }
     
    }
    
    if(groupchoice == "Conference") {
      cplot <-ggplot(data = tempdf,aes(xdata, ydata, color = Conference, shape = Conference)) +
        geom_point(cex = 5) +
        xlim(range(xdata)) +
        ylim(range(ydata)) +
        xlab(xvar) +
        ylab(yvar) +
        scale_color_manual(values = c("dodgerblue3", "firebrick3")) +
        theme_wsj()
      if(input$regression == "none"){
        print(cplot)
      }
      if(input$regression == "linear"){
        print(cplot +
          geom_smooth(method = lm, se = FALSE, formula = my.formula) +
            stat_poly_eq(formula = my.formula,
                         eq.with.lhs = "italic(hat(y))~`=`~",
                         aes(label = paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~")), 
                         parse = TRUE))
      }
      if(input$regression == "loess"){
        print(cplot +
          geom_smooth(se = FALSE))
      }
      
    }
  })
  
output$correlation <- renderText({
  xvar <- input$xaxis
  yvar <- input$yaxis
  
  xdata <- NFL2016stats[[xvar]]
  ydata <- NFL2016stats[[yvar]]
  
  corval <- cor(xdata, ydata)
  
  sprintf("The correlation coefficient is %.7s", corval)
  
})

})
