library(shiny)
library(leaflet)

vars <- c(
  "Rank" = "Rank",
  "Points Per Game" = "PointsPerGame",
  "Total Points" = "TotalPoints",
  "Plays From Scrimmage" = "PlaysFromScrimmage",
  "Yards Per Game" = "YardsPerGame",
  "Yards Per Play" = "YardsPerPlay",
  "1st Down Per Game" = "1stDownPerGame",
  "3rd Down Made" = "3rdDownMade",
  "3rd Down Attempted" = "3rdDownAttempted",
  "3rd Down Percent" = "3rdDownPercent",
  "4th Down Made" = "4thDownMade",
  "4th Down Attempted" = "4thDownAttempted",
  "4th Down Percent" = "4thDownPercent",
  "Total Penalties" = "Penalties",
  "Penalty Yards" = "PenaltyYards",
  "Total Fumbles" = "Fumbles",
  "Fumbles Lost" = "FumblesLost",
  "Turn Overs" = "TurnOvers",
  "Superbowl Wins" = "SuperbowlWin",
  "Superbowl Losses" = "SuperbowlLosse",
  "Superbowl Percent Win" = "SuperbowlPercent",
  "Superbowl Points" = "SuperbowlPoints",
  "Superbowl Opposing Points" = "SuperbowlOpposingPoints")

shinyUI(fluidPage(
  
  navbarPage("NFL 2016 Data in ColoR", id = "nav",
             tabPanel("Interactive Data MapR",
                      tags$head(
                        # Include our custom CSS
                        includeCSS("solarized.css")
                      ),
                      
                      div(class="outer",
                          
                          tags$head(
                            # Include our custom CSS
                            includeCSS("styles.css"),
                            includeScript("activemap2.js")
                          ),
                          
                          leafletOutput("map", width="100%", height="100%"),
                          
                          # Shiny versions prior to 0.11 should use class="modal" instead.
                          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                        width = 330, height = "auto",
                                        
                                        h2("Explorer"),
                                        
                                        selectInput("size","Size", vars, selected = "Rank"),
                                        
                                        selectInput("color","Color", vars, selected = "PointsPerGame"),
                                        
                                        plotOutput("scatterNFL2016", height = 200),
                                        
                                        plotOutput("superbowlhist", height = 250),
                                        
                                        actionButton("reset_button", "Reset View")
                                        
                                        
                                        
                                        
                          )
                      )
             ),
             
             tabPanel("Team Data FindR",
                      fluidRow(
                        column(3,
                               selectInput("teams", "Teams", c("All Teams"="",structure(NFL2016stats$Team, names = NFL2016stats$Team )), multiple=TRUE)
                        )
                      ),
                      fluidRow(
                        column(3,
                               numericInput("minRank", "Min Rank", min=1, max=32, value=1)
                        ),
                        column(3,
                               numericInput("maxRank", "Max Rank", min=1, max=32, value=32)
                        )
                      ),
                      hr(),
                      DT::dataTableOutput("NFLtable")
             ),
             
             
             tabPanel("PlotR",
                      fluidRow(
                        column(4, 
                               selectInput("xaxis","X-Axis", vars, selected = "Rank")
                        ),
                        column(4, 
                               selectInput("yaxis", "Y-Axis", vars, selected = "YardsPerGame")
                        ),
                        column(4,
                               radioButtons("cluster","Cluster Choice", choices = list("Conference","Division"), selected = "Division"))
                      ),
                      plotOutput("InteractiveScatter")
             ),
             
             
             conditionalPanel("false", icon("crosshair"))
  )
)
)

