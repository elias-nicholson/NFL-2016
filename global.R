if (!require(readr))
  install.packages("readr")
if (!require(dplyr))
  install.packages("dplyr")
if (!require(sp))
  install.packages("sp")
if (!require(shiny))
  install.packages("shiny")
if (!require(leaflet))
  install.packages("leaflet")


library(readr)
library(dplyr)
library(sp)

NFL2016stats <- read_csv("NFL2016stats.csv")

NFL2016stats$Conference <- as.factor(NFL2016stats$Conference)
NFL2016stats$Division <- as.factor(NFL2016stats$Division)

datatable <- NFL2016stats %>%
  select(
    Team = Team,
    Rank = Rank,
    "Points Per Game" = `PointsPerGame`,
    "Total Points" = `TotalPoints`,
    "Plays From Scrimmage" = `PlaysFromScrimmage`,
    "Yards Per Game" = `YardsPerGame`,
    "Yards Per Play" = `YardsPerPlay`,
    "1st Down Per Game" = `1stDownPerGame`,
    "3rd Down Made" = `3rdDownMade`,
    "3rd Down Attempted" = `3rdDownAttempted`,
    "3rd Down Percent" = `3rdDownPercent`,
    "4th Down Made" = `4thDownMade`,
    "4th Down Attempted" = `4thDownAttempted`,
    "4th Down Percent" = `4thDownPercent`,
    "Total Penalties" = `Penalties`,
    "Penalty Yards" = `PenaltyYards`,
    "Total Fumbles" = `Fumbles`,
    "Fumbles Lost" = `FumblesLost`,
    "Turn Overs" = `TurnOvers`,
    "Superbowl Wins" = `SuperbowlWin`,
    "Superbowl Losses" = `SuperbowlLoss`,
    "Superbowl Percent Win" = `SuperbowlPercent`,
    "Superbowl Points" = `SuperbowlPoints`,
    "Superbowl Opposing Points" = `SuperbowlOpposingPoints`)



