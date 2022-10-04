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
get_aggregate_table <- function(region, covariates=NULL){
  temp <- data %>%
    filter(year==2021 && quarter=="Q4") %>%
    mutate(avg_d_mbps = avg_d_kbps / 1024,
           avg_u_mbps = avg_u_kbps / 1024,
           .keep = "unused") %>%
    group_by(across(all_of(c("conn_type", region)))) %>%
    summarise(avg_d_mbps = sum(tests * avg_d_mbps) / sum(tests),
              avg_u_mbps = sum(tests * avg_u_mbps) / sum(tests),
              prop_d = min(avg_d_mbps / target_d, 1),
              prop_u = min(avg_u_mbps / target_u, 1),
              .groups="keep")
  
  if(!is.null(covariates))
    temp <- left_join(temp, covariates, by=region)
  
  return(temp)
}

get_summary_table <- function(region, conn, inc_urban){
  
  if(inc_urban){
    temp <- data
  } else {
    temp <- filter(data, is.na(PCCLASS))
  }
  
  if(conn==1){
    temp <- filter(temp, conn_type=="mobile")
  } else if(conn==2){
    temp <- filter(temp, conn_type=="fixed")
  }
  
  temp %>%
    filter(year==2021 & quarter=="Q4") %>%
    mutate(d_thresh = avg_d_kbps >= target_d * 1024,
           u_thresh = avg_u_kbps >= target_u * 1024,
           .keep = "unused") %>%
    group_by(across(all_of(c("conn_type", region)))) %>%
    summarise(prop_u = sum(tests * u_thresh) / sum(tests),
              prop_d = sum(tests * d_thresh) / sum(tests),
              n_tests = sum(tests),
              .groups="keep") %>%
    mutate(se_d = prop_d * (1-prop_d) / n_tests,
           se_u = prop_u * (1-prop_u) / n_tests)
}



# Create the shiny app ---------------------------------------------------------

ui <- fluidPage(
  titlePanel("SSC 2022 Case Competition"),
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      radioButtons("region",
                   "Summary Region",
                   list(`Census Division`="CDUID", `Disemination Area`="DAUID", `Province`="PRUID")),
      radioButtons("connection",
                   "Connection Type",
                   list(`Mobile`=1, `Fixed`=2, `Both`=3)),
      radioButtons("pop_centre",
                   "Include urban regions?",
                   list(Yes=T, No=F))
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      DT::dataTableOutput("table"),
      textOutput("test")
      
    )
  )
)

server <- function(input, output, session){
  # tb <- get_table("CDUID")
  output$test <- renderText(input$region)
  output$table <- DT::renderDataTable({
    datatable(get_summary_table(input$region, input$connection, input$pop_centre))
  })
  
  # output$histo <- renderPlot(hist(rnorm(100, bins=intput$bins)))
}


shinyApp(ui = ui, server=server)



