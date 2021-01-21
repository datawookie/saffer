library(readr)

unemployment_education <- read_delim(
  file.path(
    "data-raw",
    "unemployment-education.csv"
    ),
  locale = locale(decimal_mark = ","),
  delim = ";",
  comment = "#"
  )

usethis::use_data(unemployment_education, overwrite = TRUE)
