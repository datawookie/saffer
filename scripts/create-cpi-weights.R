# A script to extract the StatsSA consumer price index weights

# LOAD RESOURCES ----------------------------------------------------------

library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(pdftools)
library(readxl)

# DEFINE CONSTANTS --------------------------------------------------------

# Source: http://www.statssa.gov.za/cpi/documents/The_South_African_CPI_sources_and_methods_May2017.pdf
FILE = here::here("data-raw/cpi-sources-methods-weights.pdf")

RDA_CPI_WEIGHTS = here::here("data/cpi-weights.rda")

COLUMN_BREAKS = c(82, 132, 267, 394, 572, 675)
PAGE_RANGE = 49:86

# SCRAPE DOCUMENT ---------------------------------------------------------

raw_weights <- pdf_data(FILE)

# Get relevant page range
table <- map_dfr(PAGE_RANGE, ~ raw_weights[.x] %>%
                   as.data.frame() %>%
                   # Remove text that doesn't belong in table
                   filter(height >= 8 & height <= 10) %>%
                   # Fix exceptions caused by 'en' dashes
                   mutate(y = ifelse(str_detect(text, "–"), y + 2, y))  %>%
                   # Need to make sure that tables are correctly ordered.
                   arrange(y, x)) %>%
  # Remove most column headers
  filter(y > 130)

product_code <- table %>%
  filter(x >= COLUMN_BREAKS[2] & x < COLUMN_BREAKS[3]) %>%
  # Codes are made up entirely of digits
  filter(str_detect(text, "[[:digit:]]+")) %>%
  select(product_code = text)

indicator_product <- table %>%
  filter(x >= COLUMN_BREAKS[3] & x < COLUMN_BREAKS[4]) %>%
  # Remove one stray column header
  filter(!text %in% c("Indicator", "product")) %>%
  # Some rather complex rules to get multi-line records into one row
  mutate(index = ifelse(x == 267 & (y - lag(y) > 12 | y - lag(y) < 0), row_number(), NA),
         index = ifelse(row_number() == 1, row_number(), index)) %>%
  fill(index) %>%
  group_by(index) %>%
  mutate(indicator_product = paste(text, collapse = " ")) %>%
  group_by(index) %>%
  slice(1) %>%
  ungroup() %>%
  arrange(index) %>%
  select(indicator_product)

provincial_baskets <- table %>%
  filter(x >= COLUMN_BREAKS[4] & x < COLUMN_BREAKS[5]) %>%
  filter(!text %in% c("Provincial", "baskets")) %>%
  # Get provincial basket text into a single row
  mutate(index = ifelse(x < 400, row_number(), NA)) %>%
  fill(index) %>%
  group_by(index) %>%
  mutate(provincial_baskets = paste(text, collapse = " ")) %>%
  group_by(index) %>%
  slice(1) %>%
  arrange(index) %>%
  ungroup() %>%
  select(provincial_baskets) %>%
  # Clean up text
  mutate(provincial_baskets = str_replace_all(provincial_baskets, " ", ""),
         provincial_baskets = str_replace_all(provincial_baskets, ",", ", "),
         provincial_baskets = str_replace_all(provincial_baskets, "Allprovinces", "All provinces"))

coicop_code <- table %>%
  filter(x >= COLUMN_BREAKS[1] & x < COLUMN_BREAKS[2]) %>%
  # Remove one stray column header
  filter(!text %in% c("code", "COICOP")) %>%
  # Remove records (headers) that have blank fields in other columns
  filter(nchar(text) > 3) %>%
  select(coicop_code = text)

total_country_weight <- table %>%
  filter(x >= COLUMN_BREAKS[5] & x < COLUMN_BREAKS[6]) %>%
  # Cooerce to numeric and then remove NAs to get rid of stray text
  filter(!is.na(as.numeric(text))) %>%
  select(total_country_weight = text)

headline_weight <- table %>%
  filter(x >= COLUMN_BREAKS[6]) %>%
  select(headline_weight = text)

# Put all the columns together
cpi_weights <- data.frame(
  coicop_code = coicop_code,
  # Need to remove the first record in each row - anomaly in raw data
  total_country_weight = total_country_weight[-1,],
  # Need to remove the first record in each row - anomaly in raw data
  headline_weight = headline_weight[-1, ]
) %>%
  filter(nchar(coicop_code) == 8) %>%
  bind_cols(
    product_code = product_code,
    indicator_product = indicator_product,
    provincial_baskets = provincial_baskets
  ) %>%
  select(coicop_code, product_code, indicator_product,
         provincial_baskets, total_country_weight, headline_weight)

# WRITE DATA --------------------------------------------------------------
save(cpi_weights, file = RDA_CPI_WEIGHTS)
