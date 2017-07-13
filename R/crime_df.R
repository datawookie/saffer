#' Documentation of Tidying Original Crime Data
#'
#' The documentation that records the tidying of crime data, as retrieved from Kaggle, in order to fit SAfeR functionality.
#'
#'
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
#' @examples
#' mean_crime("Cape Town Central", data = crime)
#'

if(FALSE) {
  # "crime" object is downloaded from https://www.kaggle.com/slwessels/crime-statistics-for-south-africa
  # Tidy the dataset by turning column values into row values
  crime <- gather(crime, Year, Crime_Rate, -Province, -Station, -Category)
  # Fix row values into single years
  crime$Year <- substr(crime$Year, 2, 5) %>% as.numeric()
  # Save data into repository
  devtools::use_data(crime, overwrite = TRUE)
}
