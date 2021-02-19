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
#'   \item{province}{South African Province;}
#'   \item{station}{Police Station in Respective Province;}
#'   \item{category}{Types of Crime Committed;}
#'   \item{year}{Year in which Crimes were Committed;}
#'   \item{count}{Number of Crimes Committed in a Given Year;}
#' }
#'
#' @source
#' These data were downloaded from Kaggle user Stephan Wessels, retrievable here: https://www.kaggle.com/slwessels/crime-statistics-for-south-africa.
"crime"
