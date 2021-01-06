library(tidyr)

crime <- read.csv(here::here("data-raw/crime.csv")) %>%
  gather(year, count, -Province, -Station, -Category) %>%
  mutate(year = substr(year, 2, 5) %>% as.numeric()) %>%
  setNames(tolower(names(.)))

usethis::use_data(crime, overwrite = TRUE)
