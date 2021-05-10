# A script to extract the StatsSA food price index weights and component history

# LOAD RESOURCES ----------------------------------------------------------

library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(pdftools)
library(readxl)

# Source: http://www.statssa.gov.za/cpi/documents/The_South_African_CPI_sources_and_methods_May2017.pdf
FILE_WEIGHTS = here::here("data-raw/cpi-sources-methods-weights.pdf")

# Source: http://www.statssa.gov.za/timeseriesdata/Excel/P0141%20-%20CPI(5%20and%208%20digit)%20from%20Jan%202017%20(202103).zip
FILE_HISTORY = here::here("data-raw/food-price-index-history.xlsx")

# FOOD PRICE INDEX WEIGHTS ------------------------------------------------

raw_weights <- pdf_data(FILE_WEIGHTS)

# Get relevant page range
table <- map_dfr(49:58, ~ raw_weights[.x]) %>%
  # Remove text that doesn't belong in table
  filter(height == 8) %>%
  # Remove most column headers
  filter(y > 130)

COLUMN_BREAKS = c(82, 132, 267, 394, 572, 675)

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
  select(indicator_product) %>%
  # Clean up text
  mutate(indicator_product = str_to_lower(indicator_product) %>%
           str_replace_all(" -|- | - ", " ") %>%
           str_replace_all("\\s\\s", " ") %>%
           str_replace_all(",(?=\\w)", ", ") %>%
           str_replace_all("(?<=\\w)\\(", " (") %>%
           str_replace_all("-(?=frozen|fresh)", " ") %>%
           str_replace_all("\\(\\s", "(") %>%
           str_replace_all("\\(eg", "(e.g.") %>%
           str_replace_all("etc\\)", "etc.)")
           )

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
  mutate(text = as.numeric(text)) %>%
  filter(!is.na(text)) %>%
  select(total_country_weight = text)

headline_weight <- table %>%
  filter(x >= COLUMN_BREAKS[6]) %>%
  select(headline_weight = text)

# Put all the columns together
weights_food_beverages <- data.frame(
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
         provincial_baskets, total_country_weight, headline_weight) %>%
  filter(coicop_code != "02.1.1.1")

# FOOD PRICE INDEX HISTORY ------------------------------------------------

raw_history <- read_excel(FILE_HISTORY)
