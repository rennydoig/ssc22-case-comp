rm(list=ls())

## DOWNLOAD
lmm <- read_csv("../Daisy_dir/pred_download_LMM_2019_2030.csv")
arm <- read_csv("../olga_dir/pred_download_ARIMA_2019_2030.csv")
ens <- read_csv("../Daisy_dir/pred_download_ENS_2019_2030.csv")


lmm1 <- select(lmm, CDUID, SACTYPE, is_rural, conn_type, `2021Q4`, `2026Q1`, `2030Q1`)
arm1 <- select(arm, CDUID, SACTYPE, is_rural, conn_type, `2021Q4`, `2026Q1`, `2030Q1`)
ens1 <- select(ens, CDUID, SACTYPE, is_rural, conn_type, `2021Q4`, `2026Q1`, `2030Q1`)

down <- inner_join(lmm1, arm1,
           by=c("CDUID", "SACTYPE", "is_rural", "conn_type"),
           suffix = c(".lmm", ".arm")) %>%
  inner_join(ens1, by=c("CDUID", "SACTYPE", "is_rural", "conn_type"))

write_csv(down, "download_pred.csv")


## UPLOAD
lmm <- read_csv("../Daisy_dir/pred_upload_LMM_2019_2030.csv")
arm <- read_csv("../olga_dir/pred_upload_ARIMA_2019_2030.csv")
ens <- read_csv("../Daisy_dir/pred_upload_ENS_2019_2030.csv")


lmm1 <- select(lmm, CDUID, SACTYPE, is_rural, conn_type, `2021Q4`, `2026Q1`, `2030Q1`)
arm1 <- select(arm, CDUID, SACTYPE, is_rural, conn_type, `2021Q4`, `2026Q1`, `2030Q1`)
ens1 <- select(ens, CDUID, SACTYPE, is_rural, conn_type, `2021Q4`, `2026Q1`, `2030Q1`)

up <- inner_join(lmm1, arm1,
                   by=c("CDUID", "SACTYPE", "is_rural", "conn_type"),
                   suffix = c(".lmm", ".arm")) %>%
  inner_join(ens1, by=c("CDUID", "SACTYPE", "is_rural", "conn_type"))

write_csv(up, "upload_pred.csv")
