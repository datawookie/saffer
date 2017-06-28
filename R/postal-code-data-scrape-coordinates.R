if (FALSE) {
  library(rvest)
  library(dplyr)
  library(stringr)

  URL = "http://www.geonames.org/postalcode-search.html?q=%s&country=ZA"

  codes = levels(postalcodes$streetcode)

  RSLEEP = 15

  scrape.code <- function(code) {
    while(TRUE) {
      html <- tryCatch(read_html(sprintf(URL, code)), error = function(e) e)
      #
      if ("error" %in% class(html)) {
        cat("-> retrying...\n")
        Sys.sleep(rpois(1, RSLEEP))
      } else break
    }
    #
    # Find coordinates convert to numeric matrix.
    #
    coordinates <- html %>% html_nodes("td > a > small") %>%
      html_text() %>%
      str_split("/") %>%
      lapply(as.numeric)
    coordinates <- do.call(rbind, coordinates)
    #
    if(is.null(nrow(coordinates))) stop("No data for code ", code, ".")
    #
    colnames(coordinates) <- c("lat", "lon")
    #
    # There can be multiple entries, so calculate the mean.
    #
    colMeans(coordinates) %>% as.list %>% data.frame %>% mutate(code = code) %>% select(code, everything())
  }

  code.coordinates <- lapply(codes, function(code) {
    cat(code, "\n")
    tryCatch(scrape.code(code), error = function(e) NULL)
  })
  #
  # Filter out missing entries.
  #
  code.coordinates = Filter(function(x) !is.null(x), code.coordinates)
  #
  postalcodes_geo = do.call(rbind, code.coordinates)

  library(devtools)

  use_data(postalcodes_geo, overwrite = TRUE)
}
