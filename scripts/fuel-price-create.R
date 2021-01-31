library(rvest)
library(tidyverse)
library(lubridate)
library(here)
library(readr)

source(here(file.path("R", "fuel-type.R")))

# Data from http://www.energy.gov.za/files/esources/petroleum/petroleum_arch.html

FUEL_PRICE_CSV <- "fuel-price.csv"

col_names <- read_delim(
  here::here("data-raw", FUEL_PRICE_CSV),
  delim = ";",
  col_names = FALSE,
  col_types = rep("c", 23) %>% paste0(collapse = ""),
  n_max = 2
) %>%
  pivot_longer(everything()) %>%
  na.omit() %>%
  group_by(name) %>%
  summarise(
    value = paste(value, collapse = " | "),
    .groups = "drop"
  ) %>%
  mutate(
    name = as.integer(str_replace(name, "^X", ""))
  ) %>%
  arrange(name) %>%
  pull(value)

fuel_price_old <- read_delim(
  here::here("data-raw", FUEL_PRICE_CSV),
  delim = ";",
  skip = 2,
  col_names = col_names,
  col_types = "icidddddddddddddddddddd"
) %>%
  mutate(
    # Fill in missing day.
    day = ifelse(is.na(day), 1, day),
    date = as.Date(strptime(paste(day, month, year), "%d %b %Y"))
  ) %>%
  pivot_longer(
    -c(year, month, day, date)
  ) %>%
  na.omit() %>%
  rename(
    price = value
  ) %>%
  separate(name, c("region", "fuel"), sep = "[[:space:]]+\\|[[:space:]]+")

rm(col_names)

# ---------------------------------------------------------------------------------------------------------------------

FUEL_LEVELS <- c(
  "91 ULP",
  "93",
  "93 LRP",
  "93 ULP",
  "95 LRP",
  "95 ULP",
  "97",
  "97 ULP",
  "Diesel 0.3%",
  "Diesel 0.05%",
  "Diesel 0.005%",
  "Illuminating Paraffin",
  "Liquefied Petroleum Gas"
)

fuel_price <- fuel_price %>%
  mutate(
    fuel = factor(fuel, levels = FUEL_LEVELS)
  )

usethis::use_data(fuel_price, overwrite = TRUE)

