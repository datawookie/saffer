# Data source: http://www.statssa.gov.za/census/census_2001/SubPlace.zip

library(readxl)
library(dplyr)

PATH_RAW_DATA = here::here("data-raw/sub-places.xls")

sub_places <- read_xls(PATH_RAW_DATA) %>%
  setNames(c("sub_place_code", "sub_place", "municipality_code", "municipality",
           "district_code", "district", "province_code", "province"))

usethis::use_data(sub_places, overwrite = TRUE)
