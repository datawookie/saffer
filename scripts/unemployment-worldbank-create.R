library(purrr)

result <- GET('https://api.worldbank.org/v2/countries/ZA/indicators/SL.UEM.TOTL.ZS?per_page=10000&format=JSON')

content <- content(result)

metadata <- content[[1]]
data <- content[[2]]

extract_data_year <- function(datum) {
  tibble(
    country_id = datum$country$id,
    country_iso3 = datum$countryiso3code,
    country_name = datum$country$value,
    year = as.integer(datum$date),
    unemployed_percent = ifelse(is.null(datum$value), NA, datum$value)
  )
}

unemployment_sa <- map_dfr(data, extract_data_year) %>%
  filter(!is.na(unemployed_percent))

usethis::use_data(unemployment_sa, overwrite = TRUE)
