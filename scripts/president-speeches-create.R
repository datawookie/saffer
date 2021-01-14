library(tidyverse)
library(glue)
library(rvest)
library(here)
library(digest)
library(httr)
library(cld3)

BASE_URL <- "http://www.thepresidency.gov.za"

SPEECHES_CATALOG_CSV <- here(file.path("data-raw", "president-speeches.csv"))

DATA_FOLDER = here("data-raw", "president-speeches")
#
if (!dir.exists(DATA_FOLDER)) {
  dir.create(DATA_FOLDER, showWarnings = FALSE, recursive = TRUE)
}

# CATALOG -------------------------------------------------------------------------------------------------------------

if (!file.exists(SPEECHES_CATALOG_CSV)) {
  get_speeches <- function(year, page) {
    data = list(
      view_name = 'speeches',
      view_display_id = 'page',
      view_args = '',
      view_path = 'speeches',
      view_base_path = 'speeches',
      pager_element = '0',
      "field_speech_date_value[value][year]" = year,
      items_per_page = '20',
      page = page
    )

    result <- POST(file.path(BASE_URL, "views/ajax"), body = data)

    html <- content(result)[[3]]$data

    html <- read_html(html)

    speeches <- html %>% html_nodes(".views-row .views-column")

    speeches %>%
      map_dfr(function(speech) {
        tibble(
          date = speech %>% html_node(".date-display-single") %>% html_text(),
          href = speech %>% html_node("a") %>% html_attr("href"),
          title = speech %>% html_node("a") %>% html_text()
        )
      })
  }

  get_speeches <- insistently(get_speeches, rate = rate_backoff(pause_base = 5, max_times = 5))

  # get_speeches(2020, 0)
  # get_speeches(2020, 1)
  # get_speeches(2020, 8)
  # get_speeches(2020, 9)

  speeches <- list()

  YEARS <- 2016:2021

  for (year in YEARS) {
    page <- 0
    #
    while (TRUE) {
      message(glue("Retrieving page {page} for {year}."))
      speeches_page <- get_speeches(year, page)
      #
      if (!nrow(speeches_page)) {
        message(glue("No more speeches for {year}."))
        break
      } else {
        message(glue("Adding {nrow(speeches_page)} speeches."))
        speeches <- c(speeches, list(speeches_page))
      }

      page <- page + 1
    }
  }

  speeches <- bind_rows(speeches)

  speeches <- speeches %>%
    mutate(
      href = paste0(BASE_URL, href),
      date = strptime(date, "%d %B %Y") %>% as.Date(),
      hash = map_chr(href, digest)
    ) %>%
    mutate(
      position = str_extract(title, regex("(Deputy )?(moPoresidente|Phuresidente|Muphuresidennde|President)", ignore_case = TRUE)) %>% str_squish(),
      position = case_when(
        str_detect(position, regex("^(moPoresidente|Phuresidente|Muphuresidennde|President)$", ignore_case = TRUE)) ~ "President",
        TRUE ~ position,
      ),
      person = str_extract(title, "((Jacob |JG )?Zuma|(Cyril )?Ramaphosa)"),
      person = case_when(
        str_detect(person, "Zuma") ~ "Jacob Zuma",
        str_detect(person, "Ramaphosa") ~ "Cyril Ramaphosa",
        TRUE ~ NA_character_
      )
    ) %>%
    select(date, position, person, everything())
} else {
  speeches <- read_delim(SPEECHES_CATALOG_CSV, delim = ";")
}

# SPEECHES ------------------------------------------------------------------------------------------------------------

get_speech <- function(href) {
  retrieve_page <- function(href) {
    read_html(href)
  }

  retrieve_page <- insistently(retrieve_page, rate = rate_backoff(pause_base = 5, max_times = 5))

  html <- retrieve_page(href)

  text <- html %>%
    html_nodes(".field-items") %>%
    html_nodes(".field-item.even[property='content:encoded'] div, .field-item.even[property='content:encoded']") %>%
    html_text() %>%
    str_squish()

  # Remove empty elements.
  # text <- ifelse(text == "", "\n", text)

  # Concatenate to single string.
  paste(text, collapse = "\n")
}

speeches <- speeches %>%
  mutate(
    text = map2_chr(hash, href, function(hash, href) {
      message(glue("* {hash}"))
      filename = file.path(DATA_FOLDER, paste(hash, "txt", sep = "."))

      # Check if file exists.
      #
      message(glue("  - Checking if {filename} exists."))
      if (file.exists(filename)) {
        message("  - Loading from file.")
        text <- readLines(filename, warn = FALSE) %>% paste(collapse = " ")
      } else {
        message(glue("  - Retrieving."))
        text <- get_speech(href)
        message(glue("  - Writing to file."))
        cat(text, file = filename)
      }

      text
    })
  )

# Identify language.
#
speeches <- speeches %>%
  mutate(
    language = detect_language(text)
  ) %>%
  select(date, position, person, language, everything())

president_speeches <- speeches %>%
  select(-href, -hash) %>%
  arrange(date)

usethis::use_data(president_speeches, overwrite = TRUE)

speeches %>%
  select(-text) %>%
  write_delim(SPEECHES_CATALOG_CSV, delim = ";")
