#' Consumer Price Index for South Africa.
#'
#' @format A data frame with 3 variables:
#' \describe{
#'  \item{year}{}
#'  \item{month}{}
#'  \item{cpi}{Official inflation rate.}
#' }
"cpi"

if (FALSE) {
  cpi <- read.csv(file.path("data-raw", "consumer-price-index.csv"), stringsAsFactors = FALSE) %>%
    mutate(
      month = factor(month, labels = month.abb)
    )
  save(cpi, file = file.path("data", "cpi.rda"))
  rm(cpi)
}
