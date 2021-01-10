library(readr)
library(tidyr)
library(here)

source(here(file.path("R", "fuel-type.R")))

fuel_price_usd_exchange_rate <- read_csv(here(file.path("data-raw", "fuel-price-usd-exchange-rate.csv")), comment = "#")
usethis::use_data(fuel_price_usd_exchange_rate, overwrite = TRUE)

fuel_price_brent_crude <- read_csv(here(file.path("data-raw", "fuel-price-brent-crude.csv"))) %>%
  mutate(
    month = factor(month, levels = month.abb)
  ) %>%
  arrange(year, month)
usethis::use_data(fuel_price_brent_crude, overwrite = TRUE)

fuel_price_basic <- read_csv(here(file.path("data-raw", "fuel-price-basic.csv"))) %>%
  pivot_longer(-c(year, month), names_to = "column", values_to = "price") %>%
  inner_join(fuel_type) %>%
  select(
    year, month, fuel = label, price
  ) %>%
  filter(!is.na(price)) %>%
  mutate(
    fuel = factor(fuel, levels = fuel_type_labels),
    month = factor(month, levels = month.abb)
  ) %>%
  arrange(year, month, fuel)
usethis::use_data(fuel_price_basic, overwrite = TRUE)
