library(rvest)
library(tidyverse)
# library(purrr)

URL <- "https://www.sapia.org.za/Overview/Old-fuel-prices"

html <- read_html(URL)

tables <- html %>%
  html_nodes(".Normal table:first-child")

extract_table <- function(table) {
  table <- table %>%
    html_table() %>%
    setNames(
      c("label", month.abb)
    )

  # Interpolate region.
  #
  table$region <- ifelse(table$label %in% c("COASTAL", "GAUTENG"), table$label, NA)
  #
  table <- table %>% fill(region)

  table <- table %>%
    mutate(
      # Clean up label.
      label = label %>% str_replace("\\(.*\\)( \\*+)?", ""),
      label = str_squish(label),
      label = ifelse(is.na(region), "fuel", label),
      region = ifelse(is.na(region), "region", region)
    )

  # Get column names from first row.
  colnames(table) <- table[1,]
  table <- table[-1,]

  # Drop rows without data.
  #
  table <- table %>% filter(fuel != region)

  table %>%
    pivot_longer(
      matches("[[:digit:]]{2}-[[:alpha:]]{3}-[[:digit:]]{2}"),
      names_to = "date",
      values_to = "price"
      ) %>%
    mutate(
      region = str_to_lower(region),
      date = as.Date(strptime(date, "%d-%b-%y")),
      price = str_replace(price, ",", "."),
      price = str_replace(price, " ", ""),
      price = ifelse(price == "", NA, price),
      price = as.numeric(price)
    )
}
fuelprice <- map_df(tables, extract_table) %>%
  arrange(fuel, region, date) %>%
  na.omit()

usethis::use_data(fuelprice)
