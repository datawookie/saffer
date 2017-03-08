postalcodes <- read.delim(file.path("data-raw", "postalcodes.csv"), sep = ";", stringsAsFactors = FALSE, comment.char = "#")

library(dplyr)

postalcodes <- mutate(postalcodes,
                      BoxCode = ifelse(is.na(BoxCode), NA, sprintf("%04d", BoxCode)),
                      StreetCode = ifelse(is.na(StreetCode), NA, sprintf("%04d", StreetCode))
) %>% select(-id) %>% select(Area, Suburb, everything())

code.levels = na.exclude(union(postalcodes$BoxCode, postalcodes$StreetCode)) %>% sort

postalcodes <- mutate(postalcodes,
                      BoxCode = factor(BoxCode, levels = code.levels),
                      StreetCode = factor(StreetCode, levels = code.levels)
)

names(postalcodes) <- tolower(names(postalcodes))

library(devtools)

use_data(postalcodes, overwrite = TRUE)
