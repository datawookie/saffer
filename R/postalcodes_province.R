#' Find province from Postal Code.
#'
#' @source \url{https://en.wikipedia.org/wiki/List_of_postal_codes_in_South_Africa}
#'
#' @export
postalcodes_province <- function(code) {
  if(is.na(code) || is.null(code)) return(NA)

  if (class(code) == "character") code = as.integer(code)

  if ((code >= 1 && code <= 299) || (code >= 1400 && code <= 2199)) {
    return("Gauteng")
  } else if ((code >= 300 && code <= 499) || (code >= 2500 && code <= 2899)) {
    return("North West")
  } else if (code >= 500 && code <= 999) {
    return("Limpopo")
  } else if ((code >= 1000 && code <= 1399) || (code >= 2200 && code <= 2499)) {
    return("Mpumalanga")
  } else if (code >= 2900 && code <= 4730) {
    return("KwaZulu-Natal")
  } else if (code >= 4731 && code <= 6499) {
    return("Eastern Cape")
  } else if (code >= 6500 && code <= 8099) {
    return("Western Cape")
  } else if (code >= 8100 && code <= 8999) {
    return("Northern Cape")
  } else if (code >= 9300 && code <= 9999) {
    return("Free State")
  }
}
