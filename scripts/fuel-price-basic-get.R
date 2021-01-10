library(pdftools)
library(rvest)
library(glue)
library(dplyr)
library(purrr)
library(tidyr)
library(stringr)
library(here)
library(digest)
library(janitor)

# Parses HTML data. Subsequent data are in PDF and difficult to automate.

source(here(file.path("R", "fuel-type.R")))

# Data source: http://www.energy.gov.za/files/esources/petroleum/petroleum_arch.html.
#
# Other data sources:
#
# - http://www.energy.gov.za/files/media/SA%20FUEL%20SALES%20VOLUME/Petroleum-Products-Retail-Prices.xlsx

# ---------------------------------------------------------------------------------------------------------------------

download_data <- function(url) {
  filename = digest(url)
  #
  if (str_detect(url, "\\.pdf$")) {
    extension = "pdf"
    mode = "wb"
  } else {
    extension = "html"
    mode = "w"
  }
  #
  filename = file.path(tempdir(), paste(filename, extension, sep = "."))

  if (!file.exists(filename)) {
    message(glue("* Saving to {filename}."))
    download.file(url, filename, mode = mode, quiet = TRUE)
  } else {
    message(glue("* File {filename} already exists."))
  }

  filename
}

basic_fuel_price_html <- function(url) {
  message("* Downloading HTML.")
  filename <- download_data(url)

  message("* Extracting basic fuel price from HTML.")

  print(filename)

  # Sort out funky HTML.
  #
  html <- readLines(filename) %>%
    paste(collapse = "\n") %>%
    str_replace("</html>[:space:]*<html[^>]*>", "")

  # Parse HTML.
  #
  html <- read_html(html)

  table <- html %>%
    html_nodes(xpath = "//table[not(descendant::table) and @border='1']") %>%
    .[[1]] %>%
    html_table(fill = TRUE)

  colnames(table) <- table[2,] %>% make_clean_names()
  #
  table <- table[c(-1, -2),]
  #
  year <- colnames(table)[[1]] %>% str_extract("[[:digit:]]{4}") %>% as.integer()

  colnames(table)[[1]] <- "month"

  table$year <- year

  table %>%
    mutate(
      year = year,
      month = str_to_title(month)
    ) %>%
    select(year, month, everything()) %>%
    # Remove "na" column (if exists).
    select(-one_of("na")) %>%
    filter(
      month %in% month.abb
    )
}

# ---------------------------------------------------------------------------------------------------------------------

YEARS <- tribble(
  ~year, ~url,
  # HTML
  1986, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1986.html",
  1987, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1987.html",
  1988, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1988.html",
  1989, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1989.html",
  1990, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1990.html",
  1991, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1991.html",
  1992, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1992.html",
  1993, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1993.html",
  1994, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1994.html",
  1995, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1995.html",
  1996, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1996.html",
  1997, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1997.html",
  1998, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1998.html",
  1999, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1999.html",
  2000, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2000.html",
  2001, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2001.html",
  2002, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2002.html",
  2003, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2003.html",
  2004, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2004.html",
  2005, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2005.html",
  2006, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2006.html",
  2007, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2007.html",
  2008, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2008.html",
  2009, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2009.html",
  2010, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_2010.html",
)

fuel_price_basic <- YEARS %>%
  pmap_df(function(year, url) {
    message(year, " - ", url)

    basic_fuel_price_html(url)
  })

fuel_price_basic <- fuel_price_basic %>%
  pivot_longer(-c(year, month), names_to = "fuel", values_to = "price") %>%
  mutate(
    price = ifelse(price == "" | price == "N/A", NA, price),
    price = as.numeric(price)
  ) %>%
  filter(!is.na(price))

# EXCHANGE RATE -------------------------------------------------------------------------------------------------------

fuel_price_usd_exchange_rate <- fuel_price_basic %>%
  filter(str_detect(fuel, "exchange")) %>%
  rename(zar_per_usd = price) %>%
  select(-fuel)

write_csv(fuel_price_usd_exchange_rate, here(file.path("data-raw", "fuel-price-usd-exchange-rate.csv")))

fuel_price_basic <- fuel_price_basic %>%
  filter(!str_detect(fuel, "exchange"))

# CRUDE OIL -----------------------------------------------------------------------------------------------------------

fuel_price_brent_crude <- fuel_price_basic %>%
  filter(str_detect(fuel, "average_dated_brent_crude")) %>%
  rename(brent_crude_avg = price) %>%
  select(-fuel)

write_csv(fuel_price_brent_crude, here(file.path("data-raw", "fuel-price-brent-crude.csv")))

fuel_price_basic <- fuel_price_basic %>%
  filter(!str_detect(fuel, "average_dated_brent_crude"))

# ---------------------------------------------------------------------------------------------------------------------

fuel_price_basic <- fuel_price_basic %>%
  mutate(
    fuel = ifelse(fuel == "illum_paraffin", LABEL_ILLUMINATING_PARAFFIN, fuel),
    fuel = ifelse(str_detect(fuel, "diesel_0_005_percent"), LABEL_DIESEL_0_005, fuel),
    fuel = ifelse(str_detect(fuel, "diesel_0_05_percent") , LABEL_DIESEL_0_05, fuel),
    fuel = ifelse(str_detect(fuel, "diesel_0_3_percent"),   LABEL_DIESEL_0_3, fuel),
    fuel = ifelse(str_detect(fuel, "diesel_0_5_percent"),   LABEL_DIESEL_0_5, fuel),
    fuel = ifelse(fuel == "diesel",                         LABEL_DIESEL_0_5, fuel),
    fuel = ifelse(str_detect(fuel, "91_unleaded"),          LABEL_PETROL_91_UNLEADED, fuel),
    fuel = ifelse(str_detect(fuel, "93_unleaded"),          LABEL_PETROL_93_UNLEADED, fuel),
    fuel = ifelse(str_detect(fuel, "95_unleaded"),          LABEL_PETROL_95_UNLEADED, fuel),
    fuel = ifelse(str_detect(fuel, "petrol_97"),            LABEL_PETROL_97, fuel),
    fuel = ifelse(str_detect(fuel, "petrol_95"),            LABEL_PETROL_95, fuel),
    fuel = ifelse(str_detect(fuel, "petrol_93"),            LABEL_PETROL_93, fuel),
    fuel = ifelse(str_detect(fuel, "petrol_87"),            LABEL_PETROL_87, fuel),
    month = factor(month, levels = month.abb, ordered = TRUE)
  ) %>%
  arrange(year, month, fuel)

fuel_price_basic %>%
  inner_join(fuel_type, by = c(fuel="label")) %>%
  select(-fuel) %>%
  pivot_wider(names_from = "column", values_from = "price") %>%
  write_csv(here(file.path("data-raw", "fuel-price-basic.csv")), na = "")

# ---------------------------------------------------------------------------------------------------------------------


