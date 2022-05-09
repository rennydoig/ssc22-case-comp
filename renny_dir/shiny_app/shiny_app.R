# Project: SSC 2022 Case Study Competition
# Purpose: Shiny app for viewing data and results
# Date:    May 5, 2022
# Author:  Renny Doig


# Preliminaries ----------------------------------------------------------------

rm(list=ls())
library(shiny)
library(tidyverse)
library(sf)
library(leaflet)

# function for merging year and quarter into one time variable
merge_time <- Vectorize(function(year, quarter){
  as.numeric(as.character(year)) + (as.numeric(substr(quarter, 2, 2))-1)/4 - 2019})

# Load in data -----------------------------------------------------------------

#leaflet-ready data
data_sf <- st_read("../ookla-canada-speed-tiles.shp")
data_sf <- st_transform(data_sf, "+init=epsg:4326")

data_lf <- data_sf %>%
  mutate(time = merge_time(year, quarter),
         avg_d_mbps = avg_d_kbps / 1024,
         avg_u_mbps = avg_u_kbps / 1024) %>%
  filter(time == 0)

temp <- filter(data_lf, PRUID==10)

pal <- colorNumeric(palette="Reds", domain=temp$avg_d_mbps)


# Create the shiny app ---------------------------------------------------------

ui <- fluidPage(
  leafletOutput("map")
)

server <- function(input, output, session){
  lf <- leaflet(temp) %>%
    addTiles() %>%
    addPolygons(color= ~pal(avg_d_mbps), weight=2, highlight=highlightOptions(weight = 5, color = "white",
                                                                              bringToFront = TRUE))
  
  output$map <- renderLeaflet(lf)
}

shinyApp(ui = ui, server=server)