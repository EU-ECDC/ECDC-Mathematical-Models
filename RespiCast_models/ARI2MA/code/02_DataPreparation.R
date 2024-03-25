########################################
### Author: Lydia Champezou
### Date: December 2023
### Last update: March 2024
########################################

# ---- Keep the countries that report ----
max_date <- max(data_cases$truth_date)

countries <- vector()

for (i in 1:nrow(data_cases)) {
  if(data_cases$truth_date[i] == max_date)
    countries <- c(countries, data_cases$location[i])
}

data_cases <- data_cases %>% filter(location %in% countries)

unique(data_cases$location)

## ---- Order data truth data ----
data_cases <- data_cases[order(data_cases$location, data_cases$truth_date),]

## ---- Time series data ----
ts_bycountry_cases <- data_cases %>%
  select(year_week, location, value) %>%
  spread(location, value) %>%
  select(-1)

## ---- Handle Missing values ----
ts_bycountry_cases <- ts_bycountry_cases %>%
  fill(colnames(ts_bycountry_cases), .direction = "up")

ts_bycountry_cases <- ts_bycountry_cases %>%
  fill(colnames(ts_bycountry_cases), .direction = "down")

## ---- Important numbers ----
N_indicators <- 1 # cases (or deaths or hospitalizations)
N_quantiles <- 24 # 23 quantiles + point
N_weeks_ahead <- 4 # forecast for 4 weeks ahead
N_rows_per_country <- N_indicators*N_quantiles*N_weeks_ahead
N_countries <- length(unique(data_cases$location))

#N_countries_hosp <- length(unique(data_hosps$country_code))

## ---- Settings for forecast quantile ----
N <- 10000 #iterations
sim_arima_cases <- matrix(0, nrow = N, ncol = 4)
sim_arima_deaths <- matrix(0, nrow = N, ncol = 4)
sim_arima_hosps <- matrix(0, nrow = N, ncol = 4)

quants <- c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99)

quant_cases <- list()
df_cases <- list()

