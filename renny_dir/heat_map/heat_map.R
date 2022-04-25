# Project: SSC 2022 Case Study Competition
# Purpose: Use leaflet package to produce heat map
# Date: March 31, 2022
# Author: Renny Doig


# Preliminaries ----------------------------------------------------------------

rm(list=ls())
library(tidyverse)
library(sf)
library(leaflet)

# load in data
data <- st_read("../ookla-canada-speed-tiles.shp")

# function for merging year and quarter into one time variable
merge_time <- Vectorize(function(year, quarter){
  as.numeric(year) + (as.numeric(substr(quarter, 2, 2))-1)/4 - 2019})



# Reformat data ----------------------------------------------------------------

data <- st_transform(data, "+init=epsg:4326")

data_lf <- data %>%
  mutate(time = merge_time(year, quarter),
         avg_d_mbps = avg_d_kbps / 1024,
         avg_u_mbps = avg_u_kbps / 1024) %>%
  filter(time == 0)



# Generate heat map ------------------------------------------------------------

pal <- colorNumeric(palette="Blues", domain=data_lf$avg_d_mbps)

leaflet()
  addTiles() %>%
  addPolygons(data=data_lf, stroke=F, smoothFactor=0.2, fillOpacity=1, color= ~pal(avg_d_mbps))




