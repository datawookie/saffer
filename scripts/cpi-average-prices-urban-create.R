library(dplyr)
library(readr)
library(tidyr)

cpi_average_prices_all_urban <- read.csv(
  file.path(here::here(
    "data-raw",
    "CPI_average_prices_all_urban.csv"
    )),
  sep=";",
  dec=",",
  na.strings='..',
  comment = "#")

cpi_average_prices_all_urban <- cpi_average_prices_all_urban[
  complete.cases(
    cpi_average_prices_all_urban$H04
    ),
  ]

cpi_average_prices_urban <- select(cpi_average_prices_all_urban,
                                  -c("H01", "H02", "H03", "H05", "H06", "H07"))

cpi_average_prices_urban <- cpi_average_prices_urban %>%
  unite("product", H04:H08, remove = TRUE, sep=' ')

cpi_average_prices <- cpi_average_prices_urban %>%
  pivot_longer(-product,
               names_to = "date", values_to = "price")

cpi_average_prices <- separate(cpi_average_prices,
                              col = date,
                              into = c("month", "year"),
                              sep = "\\.")

usethis::use_data(cpi_average_prices, overwrite = TRUE)

