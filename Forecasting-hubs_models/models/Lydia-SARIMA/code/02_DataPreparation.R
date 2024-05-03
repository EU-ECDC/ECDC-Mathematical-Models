#source("code/01_SetUp.R")

# ---- Keep the countries that report cases ----
max_date <- max(data_cases$date)

countries <- vector()

for (i in 1:nrow(data_cases)) {
  if(data_cases$date[i] == max_date)
    countries <- c(countries, data_cases$location[i])
}

data_cases <- data_cases %>% filter(location %in% countries)

# ---- Keep the countries that report deaths ----
max_date <- max(data_deaths$date)

countries <- vector()

for (i in 1:nrow(data_deaths)) {
  if(data_deaths$date[i] == max_date)
    countries <- c(countries, data_deaths$location[i])
}

data_deaths <- data_deaths %>% filter(location %in% countries)

# ---- Keep the countries that report hosps ----
max_date <- max(data_hosps$date)

countries <- vector()

for (i in 1:nrow(data_hosps)) {
  if(data_hosps$date[i] == max_date)
    countries <- c(countries, data_hosps$location[i])
}

data_hosps <- data_hosps %>% filter(location %in% countries)


# ---- Data truth data ----

## ---- Time series data ----
ts_bycountry_cases <- data_cases %>%
  select(date, location_name, value) %>%
  spread(location_name, value) %>%
  select(-1)

# ts_bycountry_cases <- data_cases[,c(1,3,4)] %>% # c(1,6,7) IF NO TRUTH DATA
#   pivot_wider(names_from = location_name, values_from = value) %>% # country, weekly_count IF NO TRUTH DATA
#   select(-1)

ts_bycountry_deaths <- data_deaths %>%
  select(date, location_name, value) %>%
  spread(location_name, value) %>%
  select(-1)

ts_bycountry_hosps <- data_hosps %>%
  select(date, location_name, value) %>%
  spread(location_name, value) %>%
  select(-1)

## ---- Handle Missing values ----
ts_bycountry_cases <- ts_bycountry_cases %>%
  fill(colnames(ts_bycountry_cases), .direction = "up")

ts_bycountry_cases <- ts_bycountry_cases %>%
  fill(colnames(ts_bycountry_cases), .direction = "down")


ts_bycountry_deaths <- ts_bycountry_deaths %>%
  fill(colnames(ts_bycountry_deaths), .direction = "up")

ts_bycountry_deaths <- ts_bycountry_deaths %>%
  fill(colnames(ts_bycountry_deaths), .direction = "down")

# # Remove countries that have less than 50% of cases (no NA)
# missing_values_prop <- colMeans(is.na(ts_bycountry_hosps))
# columns_to_remove <- names(missing_values_prop[missing_values_prop > 0.5])
# ts_bycountry_hosps <- ts_bycountry_hosps[, !names(ts_bycountry_hosps) %in% columns_to_remove]

ts_bycountry_hosps <- ts_bycountry_hosps %>%
  fill(colnames(ts_bycountry_hosps), .direction = "up")

ts_bycountry_hosps <- ts_bycountry_hosps %>%
  fill(colnames(ts_bycountry_hosps), .direction = "down")

## ---- Important numbers ----
N_indicators <- 1 # cases (or deaths or hospitalizations)
N_quantiles <- 24 # 23 quantiles + point
N_weeks_ahead <- 4 # forecast for 4 weeks ahead
N_rows_per_country <- N_indicators*N_quantiles*N_weeks_ahead
N_countries_cases <- length(unique(data_cases$location_name))
N_countries_deaths <- length(unique(data_deaths$location_name))
N_countries_hosp <- length(unique(data_hosps$location_name))
countries_cases <- unique(data_cases$location)
countries_deaths <- unique(data_deaths$location)
countries_hosps <- unique(data_hosps$location)

# ## ---- Complete hospitalizations with 0 in countries that don't report
# missing_columns <- setdiff(countries, names(ts_bycountry_hosps))
# ts_bycountry_hosps[, missing_columns] <- 0

## ---- Settings for forecast quantile ----
N <- 10000 #iterations
sim_arima_cases <- matrix(0, nrow = N, ncol = 4)
sim_arima_deaths <- matrix(0, nrow = N, ncol = 4)
sim_arima_hosps <- matrix(0, nrow = N, ncol = 4)

quants <- c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99)

quant_cases <- list()
df_cases <- list()

quant_deaths <- list()
df_deaths <- list()

quant_hosps <- list()
df_hosps <- list()
