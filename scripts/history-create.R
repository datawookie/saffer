library(jsonlite)
library(here)
library(dplyr)
library(tidyr)

HISTORY_JSON <- here(file.path("data-raw", "history.json"))

history <- read_json(HISTORY_JSON, simplifyVector = TRUE) %>%
  tibble() %>%
  mutate(
    id = row_number(),
    date = as.Date(date)
    ) %>%
  select(id, everything())

history_tagged <- history %>%
  select(-details) %>%
  mutate(
  id = row_number(),
  tags = lapply(tags, function(tags) {
    data.frame(
      tag = tolower(tags),
      present = TRUE
    )
  })
) %>%
  unnest(cols = c(tags)) %>%
  pivot_wider(
    names_from = tag,
    values_from = present,
    values_fill = FALSE
  )

usethis::use_data(history, history_tagged, overwrite = TRUE)
