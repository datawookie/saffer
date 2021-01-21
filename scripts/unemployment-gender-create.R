library(readr)

unemployment_gender <- read_delim(
  file.path(
    "data-raw",
    "unemployment-gender.csv"
    ),
  locale=locale(decimal_mark = ","),
  delim = ";",
  comment = "#"
  )

usethis::use_data(unemployment_gender, overwrite = TRUE)
