#' Dataset of Crime in South Africa
#'
#' A dataset containing the number of crimes committed, per category of crime, in a given province and police station.
#' Includes data collected from 2005 to 2015.
#'
#' @docType data
#'
#' @usage data(crime)
#'
#' @format A data frame with 339471 records and 5 variables:
#' \describe{
#'   \item{Province}{South African Province;}
#'   \item{Station}{Police Station in Respective Province;}
#'   \item{Category}{Types of Crime Committed;}
#'   \item{Year}{Year in which Crimes were Committed;}
#'   \item{Crime_Rate}{Number of Crimes Committed in a Given Year;}
#' }
#' @export
#' @source
#' These data were downloaded from Kaggle user Stephan Wessels, retrievable here: https://www.kaggle.com/slwessels/crime-statistics-for-south-africa.
"crime"

if(FALSE) {
  library(tidyr)

  crime <- read.csv("../data-raw/crime.csv") %>%
    gather(year, count, -Province, -Station, -Category) %>%
    mutate(year = substr(year, 2, 5) %>% as.numeric()) %>%
    setNames(tolower(names(.)))

  devtools::use_data(crime, overwrite = TRUE)
}
