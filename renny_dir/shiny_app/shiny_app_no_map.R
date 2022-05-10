# Project: SSC 2022 Case Study Competition
# Purpose: Shiny app for viewing data and results - no map version
# Date:    May 9, 2022
# Author:  Renny Doig


# Preliminaries ----------------------------------------------------------------

rm(list=ls())
library(shiny)
library(tidyverse)
library(DT)

# read in raw data
data <- read_csv("../ookla-canada-speed-tiles.csv")



target_d <- 50
target_u <- 10

# covariates should have a row for each value of region 
get_table <- function(region, covariates=NULL){
  temp <- data %>%
    mutate(avg_d_mbps = avg_d_kbps / 1024,
           avg_u_mbps = avg_u_kbps / 1024,
           .keep = "unused") %>%
    group_by(across(all_of(c("conn_type", "year", "quarter", region)))) %>%
    summarise(avg_d_mbps = sum(tests * avg_d_mbps) / sum(tests),
              avg_u_mbps = sum(tests * avg_u_mbps) / sum(tests),
              prop_d = min(avg_d_mbps / target_d, 1),
              prop_u = min(avg_u_mbps / target_u, 1),
              .groups="keep")
  
  if(!is.null(covariates))
    temp <- left_join(temp, covariates, by=region)
  
  return(temp)
}



# Create the shiny app ---------------------------------------------------------

ui <- fluidPage(
  titlePanel("SSC 2022 Case Competition"),
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      # DT::dataTableOutput("table")
      plotOutput("histo")
      
    )
  )
)

server <- function(intput, output, session){
  tb <- get_table("CDUID")
  # tb <- head(iris)
  output$table <- DT::renderDataTable(datatable(head(tb)))
  
  output$histo <- renderPlot(histogram(rnorm(100, bins=intput$bins)))
}

shinyApp(ui = ui, server=server)


