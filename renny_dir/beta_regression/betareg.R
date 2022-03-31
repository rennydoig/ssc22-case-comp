# Project: SSC 2022 Case Study Competition
# Purpose: Fit beta regression model to aggregated data
# Date: March 30, 2022
# Author: Renny Doig


# Preliminaries ----------------------------------------------------------------

rm(list=ls())
library(tidyverse)
library(rstan)

# read in raw data
data <- read_csv("../ookla-canada-speed-tiles.csv")

# function for merging year and quarter into one time variable
merge_time <- Vectorize(function(year, quarter){
  year + (as.numeric(substr(quarter, 2, 2))-1)/4 - 2019})


# Aggregate data ---------------------------------------------------------------

# aggregated by census division

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



# Reformat data for Stan -------------------------------------------------------

target_d <- 50
target_u <- 10

data_agg <- data_agg %>%
  mutate(prop_d = min(avg_d_mbps / target_d, 1),
         prop_u = min(avg_u_mbps / target_u, 1),
         conn_bin = ifelse(conn_type=="fixed", 1, 0),
         conn_t_int = time * conn_bin)

# number of observations
n <- nrow(data_agg)

# stan data
stan_data <- list(n = n,
                  y = data_agg$prop_d,
                  x = cbind(rep(1, n), data_agg$time, data_agg$conn_bin, data_agg$conn_t_int))



# Run Stan ---------------------------------------------------------------------

options(mc.cores=4)

# initialization function
init_func <- function(){
  list(beta = rnorm(4, 0, 1),
       alpha = rnorm(4, 0, 1),
       phi = runif(1, 0, 10))
}

fit <- stan(file="betareg.stan", data=stan_data, chains=4,
            init = init_func, seed=2)

save.image("betareg_fit.RData")