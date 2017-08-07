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
  "Superbowl Losses" = "SuperbowlLoss",
  "Superbowl Percent Win" = "SuperbowlPercent",
  "Superbowl Points" = "SuperbowlPoints",
  "Superbowl Opposing Points" = "SuperbowlOpposingPoints")


shinyUI(fluidPage(
  
  navbarPage("NFL 2016 Data in ColoR", id = "nav",
             
             tabPanel("Interactive Data Map",
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
             
             
             
             tabPanel("PlotR",
                      fluidRow(
                        column(4,
                               selectInput("xaxis","X-Axis", vars, selected = "Rank")
                        ),
                        column(4,
                               selectInput("yaxis", "Y-Axis", vars, selected = "Rank")
                        ),
                        column(2,
                               radioButtons("cluster","Cluster Choice", choices = list("none","Conference","Division"), selected = "none")),
                        column(2,
                               radioButtons("regression", "Regression Type",choices = c("none","linear","loess"), selected = "none"))
                      ),
                      plotOutput("InteractiveScatter"),
                      
                      h3(textOutput("correlation"), align = "center")
             ),
             
             tabPanel("Data",
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

             
             
             tabPanel("Information", theme = "solarized.css",
                      sidebarLayout(position = "right",
                        sidebarPanel(
                                     h2("Contact Information",style = "color:white"),
                                     hr(),
                                     h3("Email:"),
                                     h3("efn3@hood.edu"),
                                     h3("GitHub:"),
                                     h3("elias-nicholson")
                                     ),
                        mainPanel(
                      fluidRow(
                        column(8, align = "center", offset = 2,  style = "color:white",
                               h1("Application Features"))
                      ),
                      fluidRow(
                        column(6, align = "center", offset = 3,
                               h3("Spatial Mapping"))
                      ),
                      fluidRow(
                        column(8, align = "center", offset = 2,
                               p("The spatial map included in this app allows users to view the data regionally and take the location into account.
                                 The primary feature of the page is the map in which the points representing the locations of the teams can be adjusted 
                                 in size and color. This feature can be accessed via the draggable panel located on the right side of the screen. The second
                                 feature of this page includes two plots which are reactive to the points which are in view on the screen. The first reactive plot 
                                 is a scatterplot representing the team ranks versus their points per game. The second of the reactive plots is a barplot which
                                 increases or decreases dependent upon the number of Superbowl wins the visible teams contain."))
                      ),
                      fluidRow(
                        column(6, align = "center", offset = 3,
                               h3("Interactive Data Table"))
                      ),
                      fluidRow(
                        column(8, align = "center", offset = 2,
                               p("The interactive data table feature allows users a few different ways to sort and filter their data.
                                 The primary method for filtering this data that is used in the app is the selection of the team/s. This can be done 
                                 by either typing or selecting the team/s which are desired in the dropdown menu. The primary method of sorting that the 
                                 data table  utiliizes is ascending or descending sorting by any of the variables contatined in the data table.
                                 This sorting feature can be utilized by clicking the up/down arrows which are located next to each of the variables."))
                               ),
                      fluidRow(
                        column(6, align = "center", offset = 3,
                               h3("PlotR"))
                      ),
                      fluidRow(
                        column(8, align = "center", offset = 2,
                               p("The interactive plot has several different ways that the data can be viewed. The first feature of the plot is the choice in the 
                                 variables plotted. The variables can be selected via dropdown menu. The next feature is adjusting the grouping of the points. Two 
                                 different forms of grouping available is grouping by conference or grouping by division. The next feature available is the option
                                 to view trends in two different ways. The first way to view trends is through the linear model; the linear model relays information 
                                 for each group pertaining to the formula and the R-squared value. The second way to view the trends is through the loess model; the
                                 loess model which bases its fitting on localized subsets to allow for more accurate modeling of curves."))
                               ),
                      fluidRow(
                        column(8, align = "center", offset = 2,
                               h5("Acknowledgements: Data gathered from the National Football League, cascading style sheet generated by bootswatch, and map generated by OpenStreetMap"))
                      )
                        )
                      )
                      
                      
                      
             ),
             
             
             conditionalPanel("false", icon("crosshair"))
  )
  
  
  
  
)
)
