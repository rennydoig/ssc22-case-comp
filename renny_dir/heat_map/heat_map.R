# Project: SSC 2022 Case Study Competition
# Purpose: Use leaflet package to produce heat map
# Date: March 31, 2022
# Author: Renny Doig


# Preliminaries ----------------------------------------------------------------

rm(list=ls())
library(tidyverse)
library(sf)
library(leaflet)
library(rgdal)

# load in data
data <- st_read("../ookla-canada-speed-tiles.shp")
data <- readOGR(dsn="../ookla-canada-speed-tiles.shp", layer="ookla-canada-speed-tiles")

# function for merging year and quarter into one time variable
merge_time <- Vectorize(function(year, quarter){
  as.numeric(as.character(year)) + (as.numeric(substr(quarter, 2, 2))-1)/4 - 2019})

# directory for grouped shapefiles
group_dir <- "../shapefiles_by_grouping/"


# Reformat data ----------------------------------------------------------------

data <- st_transform(data, "+init=epsg:4326")


data_lf <- data %>%
  mutate(time = merge_time(year, quarter),
         avg_d_mbps = avg_d_kbps / 1024,
         avg_u_mbps = avg_u_kbps / 1024) %>%
  filter(time == 0)


# generate and save grouped shapefiles
groupings <- c("DAUID", "CDUID")
for( gr in groupings )
{
  cat("Grouping by", gr)
  # gr_id <- filter(data, PRUID==10)[c(gr,"conn_type")]
  temp <- data %>%
    filter(year=="2021" & quarter=="Q4") %>%
    select(c(avg_d_kbps, avg_u_kbps, tests, conn_type, gr)) %>%
    group_by(across(all_of(c("conn_type", gr)))) %>%
    summarise(avg_d_mbps = sum(tests * avg_d_kbps) / (1024*sum(tests)),
              avg_u_mbps = sum(tests * avg_u_kbps) / (1024*sum(tests)),
              .groups = "keep")
  writeOGR(temp, dsn = paste0(group_dir, gr, ".shp"), layer = gr,
           driver = "ESRI Shapefile" )
  st_write(temp, dsn=paste0(gr, ".shp"), layer=gr, 
           driver = "ESRI Shapefile")
  cat("- Done. \n")
}


data_agg <- data %>%
  select(c(avg_d_kbps, avg_u_kbps, tests, year, quarter, conn_type, CDUID, 
           DAUID, PRUID, SACTYPE, DA_POP, PCUID, PCTYPE, PCCLASS)) %>%
  mutate(avg_d_mbps = avg_d_kbps / 1024,
         avg_u_mbps = avg_u_kbps / 1024,
         time = merge_time(year, quarter),
         .keep = "unused") %>%
  group_by(conn_type, time, CDUID) %>%
  summarise(avg_d_mbps = sum(tests * avg_d_mbps) / sum(tests),
            avg_u_mbps = sum(tests * avg_u_mbps) / sum(tests),
            .groups="keep")


# Generate heat map ------------------------------------------------------------


# initialize leaflet map
canada <- geojsonio::geojson_read("https://github.com/johan/world.geo.json/blob/master/countries/CAN.geo.json", what = "sp")

base_map <- leaflet(canada) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles("MapBox", options = providerTileOptions(
    id = "mapbox.light",
    accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')))


# add our polygon data to the map

pal <- colorNumeric(palette="Reds", domain=temp$avg_d_mbps)

leaflet(filter(temp, time==0)) %>%
  addTiles() %>%
  addPolygons(color= ~pal(avg_d_mbps), weight=2, highlight=highlightOptions(weight = 5, color = "white",
                                                                            bringToFront = TRUE))




