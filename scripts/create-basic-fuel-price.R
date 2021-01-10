library(pdftools)
library(rvest)
library(glue)
library(dplyr)
library(purrr)
library(stringr)
library(digest)

# ---------------------------------------------------------------------------------------------------------------------

download_data <- function(url) {
  filename = digest(url)
  #
  if (str_detect(url, "\\.pdf$")) {
    extension = "pdf"
    mode = "wb"
  } else {
    extension = "html"
    mode = "w"
  }
  #
  filename = file.path(tempdir(), paste(filename, extension, sep = "."))


  if (!file.exists(filename)) {
    message(glue("* Saving to {filename}."))
    download.file(url, filename, mode = mode, quiet = TRUE)
  } else {
    message(glue("* File {filename} already exists."))
  }

  filename
}

basic_fuel_price_html <- function(url) {
  message("* Downloading HTML.")
  filename <- download_data(url)

  message("* Extracting basic fuel price from HTML.")

  html <- read_html(filename)
}

basic_fuel_price_pdf <- function(url) {
  message("* Downloading PDF.")
  filename <- download_data(url)

  message("* Extracting basic fuel price from PDF.")

  # txt <- pdf_text("basic-fuel-price.pdf")
  data <- pdf_data(filename)
}

# ---------------------------------------------------------------------------------------------------------------------

YEARS <- tribble(
  ~year, ~url,
  1986, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1986.html",
  1987, "http://www.energy.gov.za/files/esources/petroleum/Achieves_Petrol/petroleum_1987.html",
  2011, "http://www.energy.gov.za/files/esources/petroleum/Dec2011/BasicFuelPrice.pdf",
  2012, "http://www.energy.gov.za/files/esources/petroleum/December2012/Basic_Fuel_Price.pdf",
  2013, "http://www.energy.gov.za/files/esources/petroleum/Dec-2013/Basic-Fuel-Price.pdf",
  2014, "http://www.energy.gov.za/files/esources/petroleum/December2014/Basic-Fuel-Price.pdf"
)

YEARS %>%
  pmap_df(function(year, url) {
    message(year, " - ", url)

    if (str_detect(url, "pdf$")) {
      basic_fuel_price_pdf(url)
    } else {
      basic_fuel_price_html(url)
    }

    NULL
  })
