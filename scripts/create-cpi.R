library(dplyr)
library(tabulizer)

cpi_raw <- extract_tables(file = "http://www.statssa.gov.za/publications/P0141/CPIHistory.pdf?",
                          output = "data.frame")

cpi_data <- bind_rows(cpi_raw) %>%
  mutate(year = coalesce(X, Year))

cpi_wide <- select(cpi_data,
                   -c("X", "Average", "Year"))

cpi <- cpi_wide  %>%
  pivot_longer(-year,
               names_to = "month", values_to = "cpi")

usethis::use_data(cpi, overwrite = TRUE)
