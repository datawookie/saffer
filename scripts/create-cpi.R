library(dplyr)
library(readr)

cpi <- read_csv(file.path("data-raw", "consumer-price-index.csv"), comment = "#") %>%
  mutate(month = factor(month, levels = month.abb)) %>%
  arrange(year, month)

usethis::use_data(dialing_codes, overwrite = TRUE)
