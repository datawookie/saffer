library(rvest)
library(tidyverse)

URL <- "https://www.rebtel.com/en/international-calling-guide/phone-codes/south-africa/"

html <- read_html(URL)

city <- html %>%
  html_nodes(".pull-left") %>%
  html_text()

codes <- html %>%
  html_nodes(".pull-right") %>%
  html_text()

dialing_codes <- data.frame(city, codes)

usethis::use_data(dialing_codes)
