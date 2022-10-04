# Project: SSC 2022 Case Study Competition
# Purpose: Fit linear mixed effect model to Manitoba data
# Date: March 23, 2022
# Author: Renny Doig


# Preliminaries ----------------------------------------------------------------

rm(list=ls())
library(tidyverse)
library(lme4)


# Read and reformat data -------------------------------------------------------

data <- read_csv("ookla-canada-speed-tiles.csv")

# function for merging year and quarter into one time variable
merge_time <- Vectorize(function(year, quarter){
  year + (as.numeric(substr(quarter, 2, 2))-1)/4 - 2019})

# create dataset with quadkey info
quadkey_df <- data %>%
  select(quadkey, CDUID, DAUID, SACTYPE, PCTYPE) %>%
  distinct() %>%
  mutate(PCTYPE = ifelse(is.na(PCTYPE), 0, PCTYPE))

# create dataset for Manitoba
MB_data <- filter(data, PRNAME=="Manitoba") %>%
  mutate(total_mbps = avg_d_kbps / 1024 * tests,
         time = merge_time(year, quarter)) %>%
  group_by(quadkey, time) %>%
  summarise(avg_mbps = sum(total_mbps) / sum(tests)) %>%
  inner_join(quadkey_df, by="quadkey")


# summarise spread of tiles in DAs
tiles_summ <- MB_data %>%
  group_by(DAUID) %>%
  summarise(n_tiles = n())

boxplot(tiles_summ$n_tiles)
summary(tiles_summ$n_tiles)



# Fit a random effects model ---------------------------------------------------

# randomly select a DA
set.seed(1)
which_DA <- sample(MB_data$DAUID, 1)

# select only that DA; convert IDs to factors
data1 <- filter(MB_data, DAUID==which_DA)
summary(data1)
data1 <- mutate(data1, CDUID = as.factor(CDUID),
                DAUID = as.factor(DAUID),
                SACTYPE = as.factor(SACTYPE),
                PCTYPE = as.factor(PCTYPE))

# fit mixed effects model
fit_lme <- lmer(avg_mbps ~ time + (1|quadkey), data=data1)
summary(fit_lme)


## Now do a train/test split on that DA

# estimate prediction error
max_time <- max(data1$time)
data1_train <- slice(data1, which(data1$time<max_time))
data1_test <- slice(data1, which(data1$time==max_time))

# fit MEM on training data
fit_tr <- lmer(avg_mbps ~ time + (1|quadkey), data=data1_train)

# predict values for final time step
pred <- predict(fit_tr, data1_test)

# compare predictions
rbind(pred, data1_test$avg_mbps)

# RMSE
sqrt(mean((pred - data1_test$avg_mbps)^2))



# Fit LM for all DAs in MB -----------------------------------------------------

map_dfr(MB_data$DAUID, function(.da){
  dat_temp <- filter(MB_data, DAUID == .da) %>%
    mutate(CDUID = as.factor(CDUID),
           DAUID = as.factor(DAUID),
           SACTYPE = as.factor(SACTYPE),
           PCTYPE = as.factor(PCTYPE))
  tr <- filter(dat_temp, time<max_time)
  te <- filter(dat_temp, time==max_time)
  fit <- lm(avg_mbps ~ time, data=tr)
  pred <- predict(fit, te)
  
  pred_class <- ifelse(pred >= 50, 1, 0)
  true_class <- ifelse(pred >= 50, 1, 0)
  
  data.frame(RMSE = sqrt(sum((pred - te$avg_mbps)^2)),
             misclass = mean(pred_class != true_class),
             beta = coef(fit)['time'])
})



# Fit LME for all DAs in MB ----------------------------------------------------


map_dfr(MB_data$DAUID, function(.da){
  dat_temp <- filter(MB_data, DAUID == .da) %>%
    mutate(CDUID = as.factor(CDUID),
           DAUID = as.factor(DAUID),
           SACTYPE = as.factor(SACTYPE),
           PCTYPE = as.factor(PCTYPE))
  tr <- filter(dat_temp, time<max_time)
  te <- filter(dat_temp, time==max_time)
  fit <- lmer(avg_mbps ~ time + (1|quadkey), data=tr)
  pred <- predict(fit, te, allow.new.levels=T)
  
  pred_class <- ifelse(pred >= 50, 1, 0)
  true_class <- ifelse(pred >= 50, 1, 0)
  
  data.frame(RMSE = sqrt(sum((pred - te$avg_mbps)^2)),
             misclass = mean(pred_class == true_class),
             beta = coef(fit)$quadkey$time[1])
})

# ISSUES
# - One DA has only one quadkey, so the random effect of quadkey cannot be
#   estimated
# - Some DAs have final time quadkeys which are not present in the training set







