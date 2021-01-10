library(dplyr)

LABEL_PETROL_87                  <- "87"
LABEL_PETROL_93                  <- "93"
LABEL_PETROL_95                  <- "95"
LABEL_PETROL_97                  <- "97"
LABEL_PETROL_91_UNLEADED         <- "91 ULP"
LABEL_PETROL_93_UNLEADED         <- "93 ULP"
LABEL_PETROL_95_UNLEADED         <- "95 ULP"
LABEL_PETROL_93_LEAD_REPLACEMENT <- "93 LRP"
LABEL_PETROL_95_LEAD_REPLACEMENT <- "95 LRP"
LABEL_DIESEL_0_3                 <- "Diesel 0.3%"
LABEL_DIESEL_0_5                 <- "Diesel 0.5%"
LABEL_DIESEL_0_05                <- "Diesel 0.05%"
LABEL_DIESEL_0_005               <- "Diesel 0.005%"
LABEL_ILLUMINATING_PARAFFIN      <- "Illuminating Paraffin"
LABEL_LPG                        <- "Liquefied Petroleum Gas"

fuel_type_labels <- c(
  LABEL_PETROL_87,
  LABEL_PETROL_93,
  LABEL_PETROL_95,
  LABEL_PETROL_97,
  LABEL_PETROL_91_UNLEADED,
  LABEL_PETROL_93_UNLEADED,
  LABEL_PETROL_95_UNLEADED,
  LABEL_PETROL_93_LEAD_REPLACEMENT,
  LABEL_PETROL_95_LEAD_REPLACEMENT,
  LABEL_DIESEL_0_3,
  LABEL_DIESEL_0_5,
  LABEL_DIESEL_0_05,
  LABEL_DIESEL_0_005,
  LABEL_ILLUMINATING_PARAFFIN,
  LABEL_LPG
)

#' Fuel Types
#'
fuel_type <- YEARS <- tribble(
  ~label, ~column,
  LABEL_PETROL_87,             "petrol 87",
  LABEL_PETROL_93,             "petrol 93",
  LABEL_PETROL_95,             "petrol 95",
  LABEL_PETROL_97,             "petrol 97",
  LABEL_PETROL_91_UNLEADED,    "petrol 91 unleaded",
  LABEL_PETROL_93_UNLEADED,    "petrol 93 unleaded",
  LABEL_PETROL_95_UNLEADED,    "petrol 95 unleaded",
  LABEL_DIESEL_0_3,            "diesel 0_3%",
  LABEL_DIESEL_0_5,            "diesel 0.5%",
  LABEL_DIESEL_0_05,           "diesel 0.05%",
  LABEL_DIESEL_0_005,          "diesel 0.005%",
  LABEL_ILLUMINATING_PARAFFIN, "illuminating paraffin",
  LABEL_LPG,                   "lpg"
) %>%
  mutate(column = janitor::make_clean_names(column))
