codes <- read.delim(file.path("data-raw", "postalcodes.csv"), sep = ";", stringsAsFactors = FALSE)

library(dplyr)

codes <- mutate(codes,
              BoxCode = as.integer(ifelse(BoxCode == "", NA, BoxCode)),
              StreetCode = as.integer(ifelse(StreetCode == "", NA, StreetCode))
              ) %>% select(-id) %>% select(Area, Suburb, everything())

names(codes) <- tolower(names(codes))

library(devtools)

use_data(codes, overwrite = TRUE)
