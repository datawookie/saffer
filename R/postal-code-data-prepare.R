if (FALSE) {
  postalcodes <- read.delim(file.path("data-raw", "postalcodes.csv"), sep = ";", stringsAsFactors = FALSE, comment.char = "#")

  library(dplyr)

  postalcodes <- mutate(postalcodes,
                        BoxCode = ifelse(is.na(BoxCode), NA, sprintf("%04d", BoxCode)),
                        StreetCode = ifelse(is.na(StreetCode), NA, sprintf("%04d", StreetCode))
  ) %>% mutate(
    Province = factor(sapply(ifelse(is.na(StreetCode), BoxCode, StreetCode), postalcodes_province))
  ) %>% select(-id) %>% select(Province, Area, Suburb, everything())

  names(postalcodes) <- tolower(names(postalcodes))

  library(devtools)

  use_data(postalcodes, overwrite = TRUE)
}
