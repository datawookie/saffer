library(jsonlite)
library(here)

HISTORY_JSON <- here(file.path("data-raw", "history.json"))

history <- read_json(HISTORY_JSON, simplifyVector = TRUE)

usethis::use_data(history, overwrite = TRUE)
