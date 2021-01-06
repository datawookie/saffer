library(rvest)
library(dplyr)
library(purrr)
fuel <-read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
  html_nodes('#box-table:nth-child(1) td')
dates <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
  html_nodes('thead td+ td , thead td+ td')%>%html_text()
values  <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
  html_nodes('tbody td+ td')%>%html_text()

province <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
  html_nodes('tbody+ thead strong , tbody:nth-child(2) tr:nth-child(1) strong') %>%
  html_text()  %>% unique()
fuel_type <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
  html_nodes('tr+ tr strong')%>%html_text() %>% unique()



fuel_price <- fuel %>%
  map(function(fuel){
    div = fuel
    tibble(dates <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
        html_nodes('thead td+ td , thead td+ td')%>% html_text()
      prices  <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
        html_nodes('tbody td+ td')%>%html_text()
       province <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
        html_nodes('tbody+ thead strong , tbody:nth-child(2) tr:nth-child(1) strong') %>%
        html_text()  %>% unique()
      fuel_type <- read_html(paste0('https://www.sapia.org.za/Overview/Old-fuel-prices')) %>%
        html_nodes('tr+ tr strong')%>%html_text() %>% unique()
    )}) %>% bind_rows()
